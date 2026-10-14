<?php
/**
 * Conexão PDO única (padrão singleton simples) com MySQL/MariaDB.
 * Toda a aplicação acessa o banco através desta função — nenhum outro
 * arquivo deve abrir uma conexão própria.
 */

require_once __DIR__ . '/env.php';

function obterConexao(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = env('DB_HOST', '127.0.0.1');
    $porta = env('DB_PORT', '3306');
    $banco = env('DB_NAME', 'cinearquivo');
    $usuario = env('DB_USER', 'root');
    $senha = env('DB_PASS', '');

    $dsn = "mysql:host={$host};port={$porta};dbname={$banco};charset=utf8mb4";

    $opcoes = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false, // força prepared statements reais
    ];

    try {
        $pdo = new PDO($dsn, $usuario, $senha, $opcoes);
    } catch (PDOException $e) {
        // Nunca expor credenciais/erro bruto do banco ao cliente
        throw new RuntimeException('Falha ao conectar ao banco de dados.', 0, $e);
    }

    return $pdo;
}
