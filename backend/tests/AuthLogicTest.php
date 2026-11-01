<?php

function testesAuthLogic(): void
{
    echo "\n-- Autenticação (hash de senha) --\n";

    MiniTeste::rodar('senha correta deve validar contra a hash', function () {
        $hash = password_hash('minhaSenha123', PASSWORD_BCRYPT);
        MiniTeste::afirmarVerdadeiro(password_verify('minhaSenha123', $hash));
    });

    MiniTeste::rodar('senha incorreta não deve validar contra a hash', function () {
        $hash = password_hash('minhaSenha123', PASSWORD_BCRYPT);
        MiniTeste::afirmarFalso(password_verify('senhaErrada', $hash));
    });

    MiniTeste::rodar('hash nunca deve ser igual à senha em texto claro', function () {
        $hash = password_hash('outraSenha', PASSWORD_BCRYPT);
        MiniTeste::afirmarFalso($hash === 'outraSenha');
    });
}
