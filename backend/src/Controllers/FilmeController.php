<?php

namespace App\Controllers;

use App\Middleware\Auth;
use App\Models\FilmeModel;
use App\Models\GeneroModel;
use App\Services\TmdbService;
use App\Utils\Logger;
use App\Utils\Response;
use App\Utils\Validator;
use PDO;
use RuntimeException;

/**
 * Regras de acesso da entidade "filmes":
 *  - usuario: só enxerga e só pode alterar/excluir os próprios filmes.
 *  - admin: enxerga os filmes de todos os usuários; pode excluir qualquer um
 *           (moderação de catálogo), mas não edita filmes de terceiros.
 */
class FilmeController
{
    private FilmeModel $filmes;
    private GeneroModel $generos;
    private TmdbService $tmdb;

    public function __construct(PDO $pdo)
    {
        $this->filmes = new FilmeModel($pdo);
        $this->generos = new GeneroModel($pdo);
        $this->tmdb = new TmdbService();
    }

    public function listar(array $query): void
    {
        $usuario = Auth::exigirLogin();

        $filtros = [
            'busca'   => Validator::sanitizarTexto($query['busca'] ?? ''),
            'genero'  => $query['genero'] ?? null,
            'status'  => $query['status'] ?? 'todos',
            'ordenar' => $query['ordenar'] ?? 'titulo-asc',
        ];

        // Admin pode opcionalmente ver tudo (?todos=1); por padrão vê só os seus,
        // mesma experiência do usuário comum, mas com a opção de moderação.
        if ($usuario['papel'] !== 'admin' || empty($query['todos'])) {
            $filtros['usuario_id'] = $usuario['id'];
        }

        $pagina = max(1, (int) ($query['pagina'] ?? 1));
        $porPagina = min(50, max(1, (int) ($query['por_pagina'] ?? 20)));

        Response::sucesso($this->filmes->listar($filtros, $pagina, $porPagina));
    }

    public function buscarUm(int $id): void
    {
        $usuario = Auth::exigirLogin();
        $filme = $this->filmes->buscarPorId($id);

        if (!$filme) {
            Response::erro('Filme não encontrado.', 404);
        }

        if ($usuario['papel'] !== 'admin' && $filme['usuario_id'] !== $usuario['id']) {
            Logger::acessoNegado("GET /filmes/{$id}", $usuario['id']);
            Response::erro('Você não tem permissão para ver este filme.', 403);
        }

        Response::sucesso($filme);
    }

    public function criar(array $corpo): void
    {
        $usuario = Auth::exigirLogin();
        [$dados, $generoIds] = $this->validarEPrepararDados($corpo);

        $dados['usuario_id'] = $usuario['id'];
        $dados = $this->completarPosterAutomatico($dados);
        $id = $this->filmes->criar($dados, $generoIds);

        Logger::entidadeCriada('filme', $id);

        Response::sucesso($this->filmes->buscarPorId($id), 201);
    }

    public function atualizar(int $id, array $corpo): void
    {
        $usuario = Auth::exigirLogin();
        $filmeExistente = $this->filmes->buscarPorId($id);

        if (!$filmeExistente) {
            Response::erro('Filme não encontrado.', 404);
        }

        if ($filmeExistente['usuario_id'] !== $usuario['id']) {
            Logger::acessoNegado("PUT /filmes/{$id}", $usuario['id']);
            Response::erro('Você só pode editar os seus próprios filmes.', 403);
        }

        [$dados, $generoIds] = $this->validarEPrepararDados($corpo);
        $dados['cor_tema'] = $filmeExistente['cor_tema']; // mantém a cor ao editar
        $dados = $this->completarPosterAutomatico($dados);
        $this->filmes->atualizar($id, $dados, $generoIds);

        Response::sucesso($this->filmes->buscarPorId($id));
    }

    public function excluir(int $id): void
    {
        $usuario = Auth::exigirLogin();
        $filmeExistente = $this->filmes->buscarPorId($id);

        if (!$filmeExistente) {
            Response::erro('Filme não encontrado.', 404);
        }

        $ehDono = $filmeExistente['usuario_id'] === $usuario['id'];
        $ehAdmin = $usuario['papel'] === 'admin';

        if (!$ehDono && !$ehAdmin) {
            Logger::acessoNegado("DELETE /filmes/{$id}", $usuario['id']);
            Response::erro('Você não tem permissão para excluir este filme.', 403);
        }

        $this->filmes->excluir($id);
        Response::sucesso(['mensagem' => 'Filme excluído.']);
    }

    /**
     * Validação e sanitização comuns a criar() e atualizar().
     * @return array{0: array, 1: int[]}
     */
    private function validarEPrepararDados(array $corpo): array
    {
        $v = new Validator($corpo);
        $v->obrigatorio('titulo', 'Título')->tamanhoMaximo('titulo', 160, 'Título')
          ->tamanhoMaximo('diretor', 120, 'Diretor(a)')
          ->inteiro('ano', 'Ano')->intervalo('ano', 1900, 2100, 'Ano')
          ->inteiro('duracao', 'Duração')->intervalo('duracao', 1, 1000, 'Duração')->tamanhoMaximo('sinopse', 5000, 'Sinopse')
          ->tamanhoMaximo('poster_url', 500, 'URL do pôster')->urlHttps('poster_url', 'URL do pôster')
          ->inteiro('tmdb_id', 'ID do TMDB')->intervalo('tmdb_id', 1, 99999999, 'ID do TMDB')
          ->inteiro('nota', 'Avaliação')->intervalo('nota', 0, 5, 'Avaliação')
          ->emLista('status', ['assistido', 'quero-assistir'], 'Status');

        $v->listaNaoVazia('generos', 'gênero');
        $generosBrutos = $corpo['generos'] ?? [];

        if (!$v->valido()) {
            Response::erro('Dados inválidos.', 422, null, $v->obterErros());
        }

        $dados = [
            'titulo'   => Validator::sanitizarTexto($corpo['titulo']),
            'ano'      => $corpo['ano'] ?? null,
            'diretor'  => Validator::sanitizarTexto($corpo['diretor'] ?? ''),
            'duracao'  => $corpo['duracao'] ?? null,
            'sinopse'  => Validator::sanitizarTexto($corpo['sinopse'] ?? ''),
            'nota'     => (int) ($corpo['nota'] ?? 0),
            'status'   => $corpo['status'] ?? 'quero-assistir',
            'cor_tema' => $this->corTemaValidaOuAleatoria($corpo['cor_tema'] ?? null),
            'poster_url' => !empty($corpo['poster_url']) ? trim($corpo['poster_url']) : null,
            'tmdb_id'  => !empty($corpo['tmdb_id']) ? (int) $corpo['tmdb_id'] : null,
        ];

        $generoIds = $this->generos->obterIdsPorChaves($generosBrutos);

        return [$dados, $generoIds];
    }

    /**
     * Se o usuário não informou pôster e a chave do TMDB está configurada,
     * tenta achar o pôster pelo título/ano. Qualquer falha é ignorada: o
     * cadastro do filme nunca deve falhar por causa do TMDB.
     */
    private function completarPosterAutomatico(array $dados): array
    {
        if (!empty($dados['poster_url']) || !$this->tmdb->configurado()) {
            return $dados;
        }

        try {
            $ano = !empty($dados['ano']) ? (int) $dados['ano'] : null;
            foreach ($this->tmdb->buscarFilmes($dados['titulo'], $ano) as $resultado) {
                if (!empty($resultado['poster_url'])) {
                    $dados['poster_url'] = $resultado['poster_url'];
                    $dados['tmdb_id'] = $dados['tmdb_id'] ?? $resultado['tmdb_id'];
                    break;
                }
            }
        } catch (RuntimeException $e) {
            Logger::erroInterno('Falha ao buscar pôster automático', ['motivo' => $e->getMessage()]);
        }

        return $dados;
    }

    private function corTemaValidaOuAleatoria(?string $cor): string
    {
        $paleta = ['#3c6e91', '#4a5d3a', '#1f2d4d', '#255c5c', '#7a2020', '#8a6a3a'];
        if ($cor !== null && preg_match('/^#[0-9a-fA-F]{6}$/', $cor)) {
            return $cor;
        }
        return $paleta[array_rand($paleta)];
    }
}
