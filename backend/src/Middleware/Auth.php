<?php

namespace App\Middleware;

use App\Utils\Logger;
use App\Utils\Response;

/**
 * Middleware de autenticação por sessão segura e controle de acesso (RBAC
 * simplificado com dois perfis: 'admin' e 'usuario').
 */
class Auth
{
    /**
     * Interrompe a requisição com 401 se não houver sessão autenticada.
     * Caso contrário, devolve os dados do usuário logado.
     */
    public static function exigirLogin(): array
    {
        if (empty($_SESSION['usuario_id'])) {
            Response::erro('Autenticação necessária. Faça login para continuar.', 401);
        }

        return [
            'id'    => (int) $_SESSION['usuario_id'],
            'nome'  => $_SESSION['usuario_nome'],
            'papel' => $_SESSION['usuario_papel'],
        ];
    }

    /**
     * Igual a exigirLogin(), mas também exige um papel específico.
     */
    public static function exigirPapel(string $papelExigido, string $rotaAtual = ''): array
    {
        $usuario = self::exigirLogin();

        if ($usuario['papel'] !== $papelExigido) {
            Logger::acessoNegado($rotaAtual, $usuario['id']);
            Response::erro('Você não tem permissão para acessar este recurso.', 403);
        }

        return $usuario;
    }
}
