<?php
/**
 * Preenche pôster e id do TMDB dos filmes que ainda não têm (ex.: os 116 do seed).
 * Uso:  php scripts/preencher_posters.php
 * Requer TMDB_API_KEY no backend/.env e o banco com a migração 001 aplicada.
 * Pode ser executado várias vezes: só mexe em filmes com poster_url vazio.
 */

if (PHP_SAPI !== 'cli') {
    exit("Execute este script pela linha de comando.\n");
}

require_once __DIR__ . '/../config/env.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../vendor_autoload.php';

use App\Services\TmdbService;

$tmdb = new TmdbService();
if (!$tmdb->configurado()) {
    fwrite(STDERR, "Defina TMDB_API_KEY no arquivo backend/.env antes de rodar.\n");
    exit(1);
}

$pdo = obterConexao();
$filmes = $pdo->query('SELECT id, titulo, ano FROM filmes WHERE poster_url IS NULL ORDER BY id')->fetchAll();
$atualizar = $pdo->prepare('UPDATE filmes SET poster_url = :poster_url, tmdb_id = :tmdb_id WHERE id = :id');

echo count($filmes) . " filme(s) sem pôster.\n";
$ok = 0;
$semResultado = 0;
$erros = 0;

foreach ($filmes as $filme) {
    try {
        $ano = $filme['ano'] ? (int) $filme['ano'] : null;
        $achado = null;

        // 1ª tentativa com o ano; 2ª sem ano (o ano pode divergir entre bases).
        foreach ([$ano, null] as $anoBusca) {
            foreach ($tmdb->buscarFilmes($filme['titulo'], $anoBusca) as $r) {
                if (!empty($r['poster_url'])) {
                    $achado = $r;
                    break 2;
                }
            }
            if ($ano === null) {
                break;
            }
        }

        if ($achado) {
            $atualizar->execute([
                'poster_url' => $achado['poster_url'],
                'tmdb_id'    => $achado['tmdb_id'],
                'id'         => $filme['id'],
            ]);
            $ok++;
            echo "[ok] {$filme['titulo']}\n";
        } else {
            $semResultado++;
            echo "[sem resultado] {$filme['titulo']}\n";
        }
    } catch (RuntimeException $e) {
        $erros++;
        echo "[erro] {$filme['titulo']}: {$e->getMessage()}\n";
        if (str_contains($e->getMessage(), '401')) {
            exit(1); // chave inválida: não adianta continuar
        }
    }

    usleep(150000); // respeita o limite de requisições do TMDB
}

echo "\nConcluído: {$ok} atualizado(s), {$semResultado} sem resultado, {$erros} erro(s).\n";
