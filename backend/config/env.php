<?php
/**
 * Carregador minimalista de .env — evita expor credenciais no código-fonte
 * sem depender de bibliotecas externas (vlucas/phpdotenv etc.).
 */

function carregarEnv(string $caminhoArquivo): void
{
    if (!is_file($caminhoArquivo)) {
        return;
    }

    $linhas = file($caminhoArquivo, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    foreach ($linhas as $linha) {
        $linha = trim($linha);

        if ($linha === '' || str_starts_with($linha, '#')) {
            continue;
        }

        if (!str_contains($linha, '=')) {
            continue;
        }

        [$chave, $valor] = explode('=', $linha, 2);
        $chave = trim($chave);
        $valor = trim($valor);

        // Remove aspas simples/duplas ao redor do valor, se houver
        $valor = trim($valor, "\"'");

        if (!array_key_exists($chave, $_ENV)) {
            $_ENV[$chave] = $valor;
            putenv("$chave=$valor");
        }
    }
}

carregarEnv(__DIR__ . '/../.env');

/**
 * Helper de leitura com valor padrão.
 */
function env(string $chave, $padrao = null)
{
    $valor = $_ENV[$chave] ?? getenv($chave);
    return $valor !== false && $valor !== null ? $valor : $padrao;
}
