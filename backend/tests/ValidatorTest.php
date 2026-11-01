<?php

require_once __DIR__ . '/../src/Utils/Validator.php';

use App\Utils\Validator;

function testesValidator(): void
{
    echo "\n-- Validator --\n";

    MiniTeste::rodar('campo obrigatório vazio deve falhar', function () {
        $v = new Validator(['titulo' => '']);
        $v->obrigatorio('titulo', 'Título');
        MiniTeste::afirmarFalso($v->valido());
        MiniTeste::afirmarIgual('Título é obrigatório.', $v->obterErros()['titulo']);
    });

    MiniTeste::rodar('campo obrigatório preenchido deve passar', function () {
        $v = new Validator(['titulo' => 'Duna']);
        $v->obrigatorio('titulo', 'Título');
        MiniTeste::afirmarVerdadeiro($v->valido());
    });

    MiniTeste::rodar('e-mail inválido deve falhar', function () {
        $v = new Validator(['email' => 'nao-e-um-email']);
        $v->email('email', 'E-mail');
        MiniTeste::afirmarFalso($v->valido());
    });

    MiniTeste::rodar('e-mail válido deve passar', function () {
        $v = new Validator(['email' => 'aluno@unesp.br']);
        $v->email('email', 'E-mail');
        MiniTeste::afirmarVerdadeiro($v->valido());
    });

    MiniTeste::rodar('nota fora do intervalo (0-5) deve falhar', function () {
        $v = new Validator(['nota' => 9]);
        $v->intervalo('nota', 0, 5, 'Avaliação');
        MiniTeste::afirmarFalso($v->valido());
    });

    MiniTeste::rodar('nota dentro do intervalo (0-5) deve passar', function () {
        $v = new Validator(['nota' => 4]);
        $v->intervalo('nota', 0, 5, 'Avaliação');
        MiniTeste::afirmarVerdadeiro($v->valido());
    });

    MiniTeste::rodar('sanitizarTexto remove tags HTML (proteção XSS)', function () {
        $sujo = '<script>alert(1)</script>Interestelar';
        $limpo = Validator::sanitizarTexto($sujo);
        MiniTeste::afirmarIgual('alert(1)Interestelar', $limpo);
    });

    MiniTeste::rodar('URL de pôster https válida deve passar', function () {
        $v = new Validator(['poster_url' => 'https://image.tmdb.org/t/p/w342/abc.jpg']);
        $v->urlHttps('poster_url', 'URL do pôster');
        MiniTeste::afirmarVerdadeiro($v->valido());
    });

    MiniTeste::rodar('URL de pôster http ou javascript: deve falhar', function () {
        $http = new Validator(['poster_url' => 'http://exemplo.com/a.jpg']);
        $http->urlHttps('poster_url', 'URL do pôster');
        MiniTeste::afirmarFalso($http->valido());

        $js = new Validator(['poster_url' => 'javascript:alert(1)']);
        $js->urlHttps('poster_url', 'URL do pôster');
        MiniTeste::afirmarFalso($js->valido());
    });
}
