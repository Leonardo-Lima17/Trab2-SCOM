<?php

/**
 * Mini framework de testes (sem dependências externas) para manter o
 * projeto executável com "php" puro, sem exigir `composer install`.
 * Se preferir, é simples migrar estes mesmos casos para PHPUnit depois.
 */

class MiniTeste
{
    private static int $total = 0;
    private static int $falhas = 0;
    private static string $testeAtual = '';

    public static function rodar(string $nome, callable $funcao): void
    {
        self::$testeAtual = $nome;
        self::$total++;

        try {
            $funcao();
            echo "  [OK] {$nome}\n";
        } catch (Throwable $e) {
            self::$falhas++;
            echo "  [FALHOU] {$nome}\n        -> {$e->getMessage()}\n";
        }
    }

    public static function afirmarVerdadeiro($valor, string $mensagem = ''): void
    {
        if ($valor !== true) {
            throw new RuntimeException($mensagem ?: 'Esperava true, recebeu ' . var_export($valor, true));
        }
    }

    public static function afirmarFalso($valor, string $mensagem = ''): void
    {
        if ($valor !== false) {
            throw new RuntimeException($mensagem ?: 'Esperava false, recebeu ' . var_export($valor, true));
        }
    }

    public static function afirmarIgual($esperado, $obtido, string $mensagem = ''): void
    {
        if ($esperado !== $obtido) {
            $msg = $mensagem ?: sprintf(
                'Esperava %s, obteve %s',
                var_export($esperado, true),
                var_export($obtido, true)
            );
            throw new RuntimeException($msg);
        }
    }

    public static function resumo(): int
    {
        $ok = self::$total - self::$falhas;
        echo "\nResumo: {$ok}/" . self::$total . " testes passaram.\n";
        return self::$falhas === 0 ? 0 : 1;
    }
}
