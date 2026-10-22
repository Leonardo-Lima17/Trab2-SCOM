<?php

namespace App\Controllers;

use App\Models\UsuarioModel;
use App\Utils\Logger;
use App\Utils\Response;
use App\Utils\Validator;
use PDO;

class AuthController
{
    private UsuarioModel $usuarios;

    public function __construct(PDO $pdo)
    {
        $this->usuarios = new UsuarioModel($pdo);
    }

    public function registrar(array $corpo): void
    {
        $v = new Validator($corpo);
        $v->obrigatorio('nome', 'Nome')->tamanhoMaximo('nome', 120, 'Nome')
          ->obrigatorio('email', 'E-mail')->email('email', 'E-mail')->tamanhoMaximo('email', 160, 'E-mail')
          ->obrigatorio('senha', 'Senha')->tamanhoMinimo('senha', 8, 'Senha')->tamanhoMaximo('senha', 72, 'Senha');

        if (!$v->valido()) {
            Response::erro('Dados inválidos.', 422, null, $v->obterErros());
        }

        $nome = Validator::sanitizarTexto($corpo['nome']);
        $email = mb_strtolower(trim($corpo['email']));
        $senha = $corpo['senha'];

        if ($this->usuarios->buscarPorEmail($email)) {
            Response::erro('Já existe uma conta com este e-mail.', 409, null, ['email' => 'E-mail já cadastrado.']);
        }

        $senhaHash = password_hash($senha, PASSWORD_BCRYPT);
        $id = $this->usuarios->criar($nome, $email, $senhaHash, 'usuario');

        Logger::entidadeCriada('usuario', $id);

        $this->iniciarSessaoUsuario($id, $nome, 'usuario');

        Response::sucesso([
            'id' => $id, 'nome' => $nome, 'email' => $email, 'papel' => 'usuario',
        ], 201);
    }

    public function login(array $corpo): void
    {
        $v = new Validator($corpo);
        $v->obrigatorio('email', 'E-mail')->obrigatorio('senha', 'Senha');

        if (!$v->valido()) {
            Response::erro('Informe e-mail e senha.', 422, null, $v->obterErros());
        }

        $email = mb_strtolower(trim($corpo['email']));
        $senha = $corpo['senha'];

        $usuario = $this->usuarios->buscarPorEmail($email);

        if (!$usuario || !password_verify($senha, $usuario['senha_hash'])) {
            Logger::falhaAutenticacao($email);
            Response::erro('E-mail ou senha incorretos.', 401);
        }

        Logger::loginSucesso($email);
        $this->iniciarSessaoUsuario($usuario['id'], $usuario['nome'], $usuario['papel']);

        Response::sucesso([
            'id' => $usuario['id'], 'nome' => $usuario['nome'],
            'email' => $usuario['email'], 'papel' => $usuario['papel'],
        ]);
    }

    public function logout(): void
    {
        $_SESSION = [];
        session_destroy();
        Response::sucesso(['mensagem' => 'Sessão encerrada.']);
    }

    public function eu(): void
    {
        if (empty($_SESSION['usuario_id'])) {
            Response::erro('Nenhuma sessão ativa.', 401);
        }

        Response::sucesso([
            'id'    => $_SESSION['usuario_id'],
            'nome'  => $_SESSION['usuario_nome'],
            'papel' => $_SESSION['usuario_papel'],
        ]);
    }

    private function iniciarSessaoUsuario(int $id, string $nome, string $papel): void
    {
        session_regenerate_id(true); // previne fixação de sessão
        $_SESSION['usuario_id'] = $id;
        $_SESSION['usuario_nome'] = $nome;
        $_SESSION['usuario_papel'] = $papel;
    }
}
