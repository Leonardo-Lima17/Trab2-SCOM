<?php
$caminho = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if (str_starts_with($caminho, '/api')) {
    require __DIR__ . '/public/index.php';
    return true;
}

return false; // qualquer outra coisa: serve o arquivo estático do frontend