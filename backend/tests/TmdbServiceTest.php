<?php

require_once __DIR__ . '/../src/Services/TmdbService.php';

use App\Services\TmdbService;

function testesTmdb(): void
{
    echo "\n-- TMDB (mapeamento de gêneros) --\n";

    MiniTeste::rodar('ids conhecidos do TMDB viram chaves do CineArquivo', function () {
        MiniTeste::afirmarIgual(['acao', 'ficcao'], TmdbService::mapearGeneros([28, 878]));
    });

    MiniTeste::rodar('gêneros duplicados são removidos (Suspense e Mistério)', function () {
        MiniTeste::afirmarIgual(['suspense'], TmdbService::mapearGeneros([53, 9648]));
    });

    MiniTeste::rodar('gêneros sem equivalente são ignorados', function () {
        MiniTeste::afirmarIgual([], TmdbService::mapearGeneros([27, 99999]));
    });
}
