<?php

namespace App\Models;

use PDO;

class UsuarioModel
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function buscarPorEmail(string $email): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, nome, email, senha_hash, papel FROM usuarios WHERE email = :email LIMIT 1'
        );
        $stmt->execute(['email' => $email]);
        $usuario = $stmt->fetch();
        return $usuario ?: null;
    }

    public function buscarPorId(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, nome, email, papel, criado_em FROM usuarios WHERE id = :id LIMIT 1'
        );
        $stmt->execute(['id' => $id]);
        $usuario = $stmt->fetch();
        return $usuario ?: null;
    }

    public function criar(string $nome, string $email, string $senhaHash, string $papel = 'usuario'): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO usuarios (nome, email, senha_hash, papel) VALUES (:nome, :email, :senha_hash, :papel)'
        );
        $stmt->execute([
            'nome'       => $nome,
            'email'      => $email,
            'senha_hash' => $senhaHash,
            'papel'      => $papel,
        ]);
        return (int) $this->pdo->lastInsertId();
    }

    public function listarTodos(): array
    {
        $stmt = $this->pdo->query(
            'SELECT id, nome, email, papel, criado_em FROM usuarios ORDER BY nome ASC'
        );
        return $stmt->fetchAll();
    }
}
