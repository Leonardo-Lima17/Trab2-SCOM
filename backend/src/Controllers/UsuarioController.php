<?php

namespace App\Controllers;

use App\Middleware\Auth;
use App\Models\UsuarioModel;
use App\Utils\Response;
use PDO;

/**
 * Endpoints restritos ao perfil 'admin' para gestão básica de usuários.
 */
class UsuarioController
{
    private UsuarioModel $usuarios;

    public function __construct(PDO $pdo)
    {
        $this->usuarios = new UsuarioModel($pdo);
    }

    public function listar(): void
    {
        Auth::exigirPapel('admin', 'GET /usuarios');
        Response::sucesso($this->usuarios->listarTodos());
    }
}
