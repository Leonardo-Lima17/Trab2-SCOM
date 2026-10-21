<?php
/**
 * Utilitário de linha de comando: gera a hash bcrypt de uma senha.
 * Uso: php gerar_hash.php "minhaSenha123"
 *
 * Use o resultado para substituir o valor de senha_hash do usuário
 * admin em database/schema.sql (ou para criar novos usuários direto
 * no banco, se precisar).
 */

if ($argc < 2) {
    fwrite(STDERR, "Uso: php gerar_hash.php \"senha\"\n");
    exit(1);
}

echo password_hash($argv[1], PASSWORD_BCRYPT) . PHP_EOL;
