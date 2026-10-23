<?php

namespace App\Utils;

/**
 * Escaping de saída — usado sempre que um valor fornecido pelo usuário
 * for refletido em alguma resposta (proteção contra XSS refletido).
 * Como a API retorna JSON, json_encode já escapa por padrão; esta classe
 * existe para qualquer ponto que gere HTML (ex.: páginas de erro) e para
 * documentar explicitamente a estratégia de proteção pedida no enunciado.
 */
class Html
{
    public static function escapar(?string $valor): string
    {
        return htmlspecialchars($valor ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}
