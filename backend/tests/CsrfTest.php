<?php

require_once __DIR__ . '/../src/Utils/Csrf.php';

use App\Utils\Csrf;

function testesCsrf(): void
{
    echo "\n-- CSRF --\n";

    MiniTeste::rodar('token gerado deve validar corretamente', function () {
        $_SESSION = [];
        $token = Csrf::gerarToken();
        MiniTeste::afirmarVerdadeiro(Csrf::validar($token));
    });

    MiniTeste::rodar('token incorreto não deve validar', function () {
        $_SESSION = [];
        Csrf::gerarToken();
        MiniTeste::afirmarFalso(Csrf::validar('token-forjado-invalido'));
    });

    MiniTeste::rodar('token ausente (null) não deve validar', function () {
        $_SESSION = [];
        Csrf::gerarToken();
        MiniTeste::afirmarFalso(Csrf::validar(null));
    });
}
