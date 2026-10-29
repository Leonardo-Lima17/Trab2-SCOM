<?php

namespace App\Services;

use RuntimeException;

/**
 * Cliente mínimo da API do TMDB (The Movie Database).
 * A chave fica no .env (TMDB_API_KEY) e as chamadas saem sempre do servidor,
 * nunca do navegador — a chave não é exposta ao usuário.
 */
class TmdbService
{
    private const BASE_URL = 'https://api.themoviedb.org/3';
    private const BASE_IMAGEM = 'https://image.tmdb.org/t/p/w342';

    /** IDs de gênero do TMDB => chaves de gênero usadas no CineArquivo. */
    private const MAPA_GENEROS = [
        28    => 'acao',
        12    => 'aventura',
        16    => 'animacao',
        35    => 'comedia',
        80    => 'crime',
        18    => 'drama',
        14    => 'fantasia',
        36    => 'historia',
        10402 => 'musical',
        10749 => 'romance',
        878   => 'ficcao',
        53    => 'suspense',
        9648  => 'suspense',
    ];

    private string $chave;

    public function __construct(?string $chave = null)
    {
        $this->chave = $chave ?? (string) env('TMDB_API_KEY', '');
    }

    public function configurado(): bool
    {
        return $this->chave !== '';
    }

    /**
     * Converte IDs de gênero do TMDB em chaves do CineArquivo (sem repetição).
     * @param int[] $idsTmdb
     * @return string[]
     */
    public static function mapearGeneros(array $idsTmdb): array
    {
        $chaves = [];
        foreach ($idsTmdb as $id) {
            $chave = self::MAPA_GENEROS[(int) $id] ?? null;
            if ($chave !== null) {
                $chaves[$chave] = true;
            }
        }
        return array_keys($chaves);
    }

    public function buscarFilmes(string $titulo, ?int $ano = null): array
    {
        $parametros = [
            'query'         => $titulo,
            'language'      => 'pt-BR',
            'include_adult' => 'false',
        ];
        if ($ano) {
            $parametros['year'] = $ano;
        }

        $dados = $this->requisitar('/search/movie', $parametros);

        return array_map([$this, 'normalizar'], array_slice($dados['results'] ?? [], 0, 8));
    }

    public function recomendacoesDoFilme(int $tmdbId): array
    {
        $dados = $this->requisitar("/movie/{$tmdbId}/recommendations", [
            'language' => 'pt-BR',
            'page'     => 1,
        ]);

        return array_map([$this, 'normalizar'], $dados['results'] ?? []);
    }

    private function normalizar(array $filme): array
    {
        $dataLancamento = (string) ($filme['release_date'] ?? '');

        return [
            'tmdb_id'    => (int) $filme['id'],
            'titulo'     => (string) ($filme['title'] ?? ''),
            'ano'        => strlen($dataLancamento) >= 4 ? (int) substr($dataLancamento, 0, 4) : null,
            'sinopse'    => (string) ($filme['overview'] ?? ''),
            'poster_url' => !empty($filme['poster_path']) ? self::BASE_IMAGEM . $filme['poster_path'] : null,
            'generos'    => self::mapearGeneros($filme['genre_ids'] ?? []),
        ];
    }

    /**
     * @throws RuntimeException em falha de rede, chave inválida ou resposta inesperada
     */
    private function requisitar(string $caminho, array $parametros): array
    {
        if (!$this->configurado()) {
            throw new RuntimeException('TMDB_API_KEY não configurada.');
        }

        $parametros['api_key'] = $this->chave;
        $url = self::BASE_URL . $caminho . '?' . http_build_query($parametros);

        [$status, $corpo] = function_exists('curl_init')
            ? $this->requisitarComCurl($url)
            : $this->requisitarComStream($url);

        if ($status === 401) {
            throw new RuntimeException('Chave do TMDB inválida (HTTP 401).');
        }
        if ($status !== 200 || $corpo === false || $corpo === '') {
            throw new RuntimeException("Falha ao consultar o TMDB (HTTP {$status}).");
        }

        $json = json_decode($corpo, true);
        if (!is_array($json)) {
            throw new RuntimeException('Resposta inválida do TMDB.');
        }

        return $json;
    }

    private function requisitarComCurl(string $url): array
    {
        $ch = curl_init($url);
        $opcoes = [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 8,
            CURLOPT_CONNECTTIMEOUT => 4,
            CURLOPT_HTTPHEADER     => ['Accept: application/json'],
        ];

        $bundle = (string) env('TMDB_CA_BUNDLE', '');
        if ($bundle !== '') {
            $opcoes[CURLOPT_CAINFO] = $bundle;
        }

        curl_setopt_array($ch, $opcoes);
        $corpo = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);

        if ($corpo === false) {
            $erro = curl_error($ch);
            curl_close($ch);
            throw new RuntimeException('Erro de conexão com o TMDB: ' . $erro);
        }

        curl_close($ch);
        return [$status, $corpo];
    }

    private function requisitarComStream(string $url): array
    {
        $contexto = stream_context_create([
            'http' => ['method' => 'GET', 'timeout' => 8, 'ignore_errors' => true,
                       'header' => "Accept: application/json\r\n"],
        ]);

        $corpo = @file_get_contents($url, false, $contexto);
        $status = 0;
        foreach ($http_response_header ?? [] as $linha) {
            if (preg_match('#^HTTP/\S+\s+(\d{3})#', $linha, $m)) {
                $status = (int) $m[1];
            }
        }

        return [$status, $corpo];
    }
}
