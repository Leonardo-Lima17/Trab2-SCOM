<?php

/**
 * Autoloader minimalista (equivalente simplificado ao autoload PSR-4 do
 * Composer), para não exigir `composer install` só para rodar o projeto.
 * Mapeia o namespace "App\" para a pasta src/.
 *
 * Se preferir usar Composer normalmente, basta rodar `composer init` e
 * `composer dump-autoload` com o mapeamento "App\\": "src/" no composer.json,
 * e trocar o require deste arquivo por vendor/autoload.php no index.php.
 */

spl_autoload_register(function (string $classe): void {
    $prefixo = 'App\\';
    $diretorioBase = __DIR__ . '/src/';

    if (!str_starts_with($classe, $prefixo)) {
        return;
    }

    $classeRelativa = substr($classe, strlen($prefixo));
    $arquivo = $diretorioBase . str_replace('\\', '/', $classeRelativa) . '.php';

    if (is_file($arquivo)) {
        require $arquivo;
    }
});
