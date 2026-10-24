<?php

namespace App\Models;

use PDO;

class GeneroModel
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function listarTodos(): array
    {
        $stmt = $this->pdo->query('SELECT id, chave, nome FROM generos ORDER BY nome ASC');
        return $stmt->fetchAll();
    }

    /**
     * Converte um array de chaves (ex.: ['acao', 'drama']) nos IDs
     * correspondentes na tabela generos. Chaves inexistentes são ignoradas.
     */
    public function obterIdsPorChaves(array $chaves): array
    {
        if (empty($chaves)) {
            return [];
        }

        $marcadores = implode(',', array_fill(0, count($chaves), '?'));
        $stmt = $this->pdo->prepare("SELECT id FROM generos WHERE chave IN ($marcadores)");
        $stmt->execute(array_values($chaves));

        return array_map('intval', array_column($stmt->fetchAll(), 'id'));
    }
}
