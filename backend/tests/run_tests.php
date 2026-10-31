<?php

/**
 * Executa toda a suíte de testes automatizados do backend.
 * Uso:  php tests/run_tests.php
 *
 * Retorna código de saída 0 se todos os testes passarem, 1 caso contrário
 * (útil para integrar em CI / hooks de Git).
 */

require_once __DIR__ . '/MiniTeste.php';
require_once __DIR__ . '/ValidatorTest.php';
require_once __DIR__ . '/AuthLogicTest.php';
require_once __DIR__ . '/CsrfTest.php';
require_once __DIR__ . '/TmdbServiceTest.php';

echo "Executando testes automatizados do CineArquivo...\n";

testesValidator();
testesAuthLogic();
testesCsrf();
testesTmdb();

exit(MiniTeste::resumo());
