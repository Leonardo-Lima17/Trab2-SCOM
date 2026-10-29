<?php

namespace App\Controllers;

use App\Middleware\Auth;
use App\Models\FilmeModel;
use App\Services\TmdbService;
use App\Utils\Logger;
use App\Utils\Response;
use App\Utils\Validator;
use PDO;
use RuntimeException;

/**
 * Endpoints de apoio ao catálogo:
 *  - GET /api/tmdb/buscar?q=...   busca de filmes (pôster, sinopse, ano) no TMDB
 *  - GET /api/recomendacoes       sugestões de filmes para o usuário logado
 *
 * Recomendações combinam duas fontes:
 *  1) TMDB: filmes parecidos com os que o usuário assistiu e avaliou com nota >= 4;
 *  2) comunidade: filmes de outros usuários nos gêneros que ele avalia bem.
 */
class RecomendacaoController
{
    private const LIMITE_RECOMENDACOES = 12;
    private const SEMENTES_TMDB = 3;
    private const POR_SEMENTE = 6;

    private FilmeModel $filmes;
    private TmdbService $tmdb;

    public function __construct(PDO $pdo)
    {
        $this->filmes = new FilmeModel($pdo);
        $this->tmdb = new TmdbService();
    }

    public function buscarNoTmdb(array $query): void
    {
        Auth::exigirLogin();

        $termo = Validator::sanitizarTexto($query['q'] ?? '');
        if (mb_strlen($termo) < 2 || mb_strlen($termo) > 120) {
            Response::erro('Informe de 2 a 120 caracteres para a busca.', 422, null, ['q' => 'Termo de busca inválido.']);
        }

        if (!$this->tmdb->configurado()) {
            Response::erro('A busca de pôsteres não está configurada neste servidor.', 503);
        }

        try {
            Response::sucesso($this->tmdb->buscarFilmes($termo));
        } catch (RuntimeException $e) {
            Logger::erroInterno('Falha na busca do TMDB', ['motivo' => $e->getMessage()]);
            Response::erro('Não foi possível consultar o TMDB agora. Tente novamente.', 502, $e->getMessage());
        }
    }

    public function listar(): void
    {
        $usuario = Auth::exigirLogin();
        $itens = [];

        if ($this->tmdb->configurado()) {
            try {
                $itens = $this->recomendarViaTmdb($usuario['id']);
            } catch (RuntimeException $e) {
                // Recomendação é um extra: se o TMDB falhar, seguimos com a comunidade.
                Logger::erroInterno('Falha nas recomendações do TMDB', ['motivo' => $e->getMessage()]);
            }
        }

        $faltam = self::LIMITE_RECOMENDACOES - count($itens);
        if ($faltam > 0) {
            foreach ($this->filmes->recomendarInterno($usuario['id'], $faltam) as $f) {
                $itens[] = [
                    'tmdb_id'    => $f['tmdb_id'] !== null ? (int) $f['tmdb_id'] : null,
                    'titulo'     => $f['titulo'],
                    'ano'        => $f['ano'] !== null ? (int) $f['ano'] : null,
                    'sinopse'    => (string) $f['sinopse'],
                    'poster_url' => $f['poster_url'],
                    'generos'    => $f['generos'],
                    'motivo'     => 'Popular entre outros usuários do CineArquivo',
                ];
            }
        }

        Response::sucesso(['itens' => $itens]);
    }

    /**
     * @throws RuntimeException se o TMDB falhar
     */
    private function recomendarViaTmdb(int $usuarioId): array
    {
        $sementes = $this->filmes->melhoresComTmdb($usuarioId, self::SEMENTES_TMDB);
        if (empty($sementes)) {
            return [];
        }

        $jaTem = $this->filmes->catalogoDoUsuario($usuarioId);
        $resultado = [];
        $idsUsados = [];

        foreach ($sementes as $semente) {
            $adicionados = 0;
            foreach ($this->tmdb->recomendacoesDoFilme((int) $semente['tmdb_id']) as $r) {
                if ($adicionados >= self::POR_SEMENTE || count($resultado) >= self::LIMITE_RECOMENDACOES) {
                    break;
                }
                if (isset($idsUsados[$r['tmdb_id']])
                    || in_array($r['tmdb_id'], $jaTem['tmdb_ids'], true)
                    || in_array(mb_strtolower($r['titulo']), $jaTem['titulos'], true)
                    || empty($r['poster_url'])) {
                    continue;
                }

                $idsUsados[$r['tmdb_id']] = true;
                $r['motivo'] = 'Porque você gostou de ' . $semente['titulo'];
                $resultado[] = $r;
                $adicionados++;
            }
        }

        return $resultado;
    }
}
