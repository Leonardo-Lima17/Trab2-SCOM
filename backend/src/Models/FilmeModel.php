<?php

namespace App\Models;

use PDO;

/**
 * Camada de acesso a dados da entidade principal (filmes).
 * Toda consulta usa prepared statements — nenhuma interpolação direta
 * de valores vindos do cliente é feita na string SQL.
 */
class FilmeModel
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Lista filmes com filtros opcionais, ordenação e paginação.
     *
     * @param array $filtros  ['usuario_id' => int|null, 'busca' => string, 'genero' => string,
     *                         'status' => string, 'ordenar' => string]
     * @param int   $pagina   1-based
     * @param int   $porPagina
     */
    public function listar(array $filtros, int $pagina = 1, int $porPagina = 20): array
    {
        $condicoes = [];
        $parametros = [];

        if (!empty($filtros['usuario_id'])) {
            $condicoes[] = 'f.usuario_id = :usuario_id';
            $parametros['usuario_id'] = $filtros['usuario_id'];
        }

                if (!empty($filtros['busca'])) {
            // Com prepares nativos o mesmo nome de parâmetro não pode se repetir
            $condicoes[] = '(f.titulo LIKE :busca_titulo OR f.diretor LIKE :busca_diretor)';
            $termo = '%' . $filtros['busca'] . '%';
            $parametros['busca_titulo'] = $termo;
            $parametros['busca_diretor'] = $termo;
        }

        if (!empty($filtros['status']) && $filtros['status'] !== 'todos') {
            $condicoes[] = 'f.status = :status';
            $parametros['status'] = $filtros['status'];
        }

        if (!empty($filtros['genero'])) {
            $condicoes[] = 'EXISTS (
                SELECT 1 FROM filme_generos fg
                INNER JOIN generos g ON g.id = fg.genero_id
                WHERE fg.filme_id = f.id AND g.chave = :genero
            )';
            $parametros['genero'] = $filtros['genero'];
        }

        $whereSql = empty($condicoes) ? '' : 'WHERE ' . implode(' AND ', $condicoes);

        $colunasOrdenaveis = [
            'titulo-asc' => 'f.titulo ASC',
            'ano-desc'   => 'f.ano DESC',
            'ano-asc'    => 'f.ano ASC',
            'nota-desc'  => 'f.nota DESC',
        ];
        $ordemSql = $colunasOrdenaveis[$filtros['ordenar'] ?? ''] ?? 'f.titulo ASC';

        $offset = max(0, ($pagina - 1) * $porPagina);

        $sql = "SELECT f.id, f.usuario_id, f.titulo, f.ano, f.diretor, f.duracao,
                       f.sinopse, f.nota, f.status, f.cor_tema, f.poster_url, f.tmdb_id, f.criado_em
                FROM filmes f
                {$whereSql}
                ORDER BY {$ordemSql}
                LIMIT :limite OFFSET :offset";

        $stmt = $this->pdo->prepare($sql);
        foreach ($parametros as $chave => $valor) {
            $stmt->bindValue(":{$chave}", $valor);
        }
        $stmt->bindValue(':limite', $porPagina, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $filmes = $stmt->fetchAll();

        // Contagem total (para paginação no front-end)
        $sqlTotal = "SELECT COUNT(*) AS total FROM filmes f {$whereSql}";
        $stmtTotal = $this->pdo->prepare($sqlTotal);
        foreach ($parametros as $chave => $valor) {
            $stmtTotal->bindValue(":{$chave}", $valor);
        }
        $stmtTotal->execute();
        $total = (int) $stmtTotal->fetch()['total'];

        // Anexa os gêneros de cada filme (evita N+1 fazendo uma única query extra)
        if (!empty($filmes)) {
            $ids = array_column($filmes, 'id');
            $generosPorFilme = $this->buscarGenerosPorFilmes($ids);
            foreach ($filmes as &$filme) {
                $filme['generos'] = $generosPorFilme[$filme['id']] ?? [];
            }
            unset($filme);
        }

        return ['itens' => $filmes, 'total' => $total, 'pagina' => $pagina, 'por_pagina' => $porPagina];
    }

    public function buscarPorId(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema, poster_url, tmdb_id, criado_em
             FROM filmes WHERE id = :id LIMIT 1'
        );
        $stmt->execute(['id' => $id]);
        $filme = $stmt->fetch();

        if (!$filme) {
            return null;
        }

        $generos = $this->buscarGenerosPorFilmes([$id]);
        $filme['generos'] = $generos[$id] ?? [];

        return $filme;
    }

    public function criar(array $dados, array $generoIds): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema, poster_url, tmdb_id)
             VALUES (:usuario_id, :titulo, :ano, :diretor, :duracao, :sinopse, :nota, :status, :cor_tema, :poster_url, :tmdb_id)'
        );
        $stmt->execute([
            'usuario_id' => $dados['usuario_id'],
            'titulo'     => $dados['titulo'],
            'ano'        => $dados['ano'] ?: null,
            'diretor'    => $dados['diretor'] ?: 'Não informado',
            'duracao'    => $dados['duracao'] ?: null,
            'sinopse'    => $dados['sinopse'] ?: null,
            'nota'       => $dados['nota'] ?? 0,
            'status'     => $dados['status'],
            'cor_tema'   => $dados['cor_tema'] ?? '#333952',
            'poster_url' => $dados['poster_url'] ?? null,
            'tmdb_id'    => $dados['tmdb_id'] ?? null,
        ]);

        $filmeId = (int) $this->pdo->lastInsertId();
        $this->sincronizarGeneros($filmeId, $generoIds);

        return $filmeId;
    }

    public function atualizar(int $id, array $dados, array $generoIds): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE filmes SET titulo = :titulo, ano = :ano, diretor = :diretor,
                duracao = :duracao, sinopse = :sinopse, nota = :nota,
                status = :status, cor_tema = :cor_tema,
                poster_url = :poster_url, tmdb_id = :tmdb_id
             WHERE id = :id'
        );
        $ok = $stmt->execute([
            'titulo'   => $dados['titulo'],
            'ano'      => $dados['ano'] ?: null,
            'diretor'  => $dados['diretor'] ?: 'Não informado',
            'duracao'  => $dados['duracao'] ?: null,
            'sinopse'  => $dados['sinopse'] ?: null,
            'nota'     => $dados['nota'] ?? 0,
            'status'   => $dados['status'],
            'cor_tema' => $dados['cor_tema'] ?? '#333952',
            'poster_url' => $dados['poster_url'] ?? null,
            'tmdb_id'  => $dados['tmdb_id'] ?? null,
            'id'       => $id,
        ]);

        $this->sincronizarGeneros($id, $generoIds);

        return $ok;
    }

    public function excluir(int $id): bool
    {
        $stmt = $this->pdo->prepare('DELETE FROM filmes WHERE id = :id');
        return $stmt->execute(['id' => $id]);
    }

    public function pertenceAoUsuario(int $filmeId, int $usuarioId): bool
    {
        $stmt = $this->pdo->prepare(
            'SELECT 1 FROM filmes WHERE id = :id AND usuario_id = :usuario_id LIMIT 1'
        );
        $stmt->execute(['id' => $filmeId, 'usuario_id' => $usuarioId]);
        return (bool) $stmt->fetchColumn();
    }

    /**
     * Filmes que o usuário assistiu e avaliou bem (nota >= 4) e que têm vínculo
     * com o TMDB — servem de "semente" para as recomendações.
     */
    public function melhoresComTmdb(int $usuarioId, int $limite): array
    {
        $stmt = $this->pdo->prepare(
            "SELECT titulo, tmdb_id FROM filmes
             WHERE usuario_id = :usuario_id AND status = 'assistido'
               AND nota >= 4 AND tmdb_id IS NOT NULL
             ORDER BY nota DESC, atualizado_em DESC
             LIMIT :limite"
        );
        $stmt->bindValue(':usuario_id', $usuarioId, PDO::PARAM_INT);
        $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Títulos (minúsculos) e ids do TMDB que o usuário já tem, para não
     * recomendar o que ele já cadastrou.
     * @return array{titulos: string[], tmdb_ids: int[]}
     */
    public function catalogoDoUsuario(int $usuarioId): array
    {
        $stmt = $this->pdo->prepare('SELECT titulo, tmdb_id FROM filmes WHERE usuario_id = :usuario_id');
        $stmt->execute(['usuario_id' => $usuarioId]);

        $titulos = [];
        $tmdbIds = [];
        foreach ($stmt->fetchAll() as $linha) {
            $titulos[] = mb_strtolower($linha['titulo']);
            if ($linha['tmdb_id'] !== null) {
                $tmdbIds[] = (int) $linha['tmdb_id'];
            }
        }
        return ['titulos' => $titulos, 'tmdb_ids' => $tmdbIds];
    }

    /**
     * Recomendação "interna": filmes de OUTROS usuários, em gêneros que o
     * usuário avalia bem (nota >= 4), que ele ainda não tem. Se ele ainda não
     * avaliou nada, cai para os filmes mais bem avaliados da comunidade.
     */
    public function recomendarInterno(int $usuarioId, int $limite): array
    {
        $baseSql = "SELECT MIN(f.id) AS id, f.titulo, MAX(f.ano) AS ano,
                           MAX(f.sinopse) AS sinopse, MAX(f.poster_url) AS poster_url,
                           MAX(f.tmdb_id) AS tmdb_id
                    FROM filmes f
                    WHERE f.usuario_id <> :uid1
                      AND f.titulo NOT IN (SELECT titulo FROM filmes WHERE usuario_id = :uid2)";

        $porGenero = $baseSql . "
                      AND EXISTS (
                        SELECT 1 FROM filme_generos fg
                        WHERE fg.filme_id = f.id AND fg.genero_id IN (
                          SELECT fg2.genero_id FROM filme_generos fg2
                          INNER JOIN filmes m ON m.id = fg2.filme_id
                          WHERE m.usuario_id = :uid3 AND m.status = 'assistido' AND m.nota >= 4
                        )
                      )
                    GROUP BY f.titulo
                    ORDER BY COUNT(*) DESC, AVG(f.nota) DESC
                    LIMIT :limite";

        $stmt = $this->pdo->prepare($porGenero);
        $stmt->bindValue(':uid1', $usuarioId, PDO::PARAM_INT);
        $stmt->bindValue(':uid2', $usuarioId, PDO::PARAM_INT);
        $stmt->bindValue(':uid3', $usuarioId, PDO::PARAM_INT);
        $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
        $stmt->execute();
        $linhas = $stmt->fetchAll();

        if (empty($linhas)) {
            $geral = $baseSql . "
                    GROUP BY f.titulo
                    ORDER BY AVG(f.nota) DESC, COUNT(*) DESC
                    LIMIT :limite";
            $stmt = $this->pdo->prepare($geral);
            $stmt->bindValue(':uid1', $usuarioId, PDO::PARAM_INT);
            $stmt->bindValue(':uid2', $usuarioId, PDO::PARAM_INT);
            $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
            $stmt->execute();
            $linhas = $stmt->fetchAll();
        }

        if (empty($linhas)) {
            return [];
        }

        $generosPorFilme = $this->buscarGenerosPorFilmes(array_map('intval', array_column($linhas, 'id')));
        foreach ($linhas as &$linha) {
            $linha['generos'] = $generosPorFilme[$linha['id']] ?? [];
        }
        unset($linha);

        return $linhas;
    }

    /**
     * Remove todos os vínculos de gênero do filme e recria com a lista atual.
     * Mais simples e seguro do que calcular diff para um formulário pequeno.
     */
    private function sincronizarGeneros(int $filmeId, array $generoIds): void
    {
        $stmtDelete = $this->pdo->prepare('DELETE FROM filme_generos WHERE filme_id = :filme_id');
        $stmtDelete->execute(['filme_id' => $filmeId]);

        if (empty($generoIds)) {
            return;
        }

        $stmtInsert = $this->pdo->prepare(
            'INSERT INTO filme_generos (filme_id, genero_id) VALUES (:filme_id, :genero_id)'
        );
        foreach (array_unique($generoIds) as $generoId) {
            $stmtInsert->execute(['filme_id' => $filmeId, 'genero_id' => $generoId]);
        }
    }

    /**
     * @param int[] $filmeIds
     * @return array<int, string[]> mapa filme_id => lista de chaves de gênero
     */
    private function buscarGenerosPorFilmes(array $filmeIds): array
    {
        if (empty($filmeIds)) {
            return [];
        }

        $marcadores = implode(',', array_fill(0, count($filmeIds), '?'));
        $sql = "SELECT fg.filme_id, g.chave
                FROM filme_generos fg
                INNER JOIN generos g ON g.id = fg.genero_id
                WHERE fg.filme_id IN ($marcadores)";

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(array_values($filmeIds));

        $mapa = [];
        foreach ($stmt->fetchAll() as $linha) {
            $mapa[$linha['filme_id']][] = $linha['chave'];
        }

        return $mapa;
    }
}
