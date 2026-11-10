<?php
/**
 * Utilitário de linha de comando: gera a hash bcrypt de uma senha.
 * Uso: php gerar_hash.php "minhaSenha123"
 *
 * Use o resultado em um UPDATE na coluna senha_hash do usuário desejado
 * (ex.: o admin), direto no banco. Nunca grave a hash real no schema.sql.
 */

if ($argc < 2) {
    fwrite(STDERR, "Uso: php gerar_hash.php \"senha\"\n");
    exit(1);
}

echo password_hash($argv[1], PASSWORD_BCRYPT) . PHP_EOL;
