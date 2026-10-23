<?php

namespace App\Utils;

/**
 * Proteção CSRF simples baseada em token armazenado na sessão.
 * O front-end busca o token em GET /api/csrf e o reenvia no header
 * "X-CSRF-Token" em toda requisição que muda estado (POST/PUT/DELETE).
 */
class Csrf
{
    public static function gerarToken(): string
    {
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }

    public static function validar(?string $tokenRecebido): bool
    {
        if (empty($_SESSION['csrf_token']) || $tokenRecebido === null) {
            return false;
        }
        return hash_equals($_SESSION['csrf_token'], $tokenRecebido);
    }
}
