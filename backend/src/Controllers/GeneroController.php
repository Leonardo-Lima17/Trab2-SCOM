<?php

namespace App\Controllers;

use App\Models\GeneroModel;
use App\Utils\Response;
use PDO;

class GeneroController
{
    private GeneroModel $generos;

    public function __construct(PDO $pdo)
    {
        $this->generos = new GeneroModel($pdo);
    }

    public function listar(): void
    {
        Response::sucesso($this->generos->listarTodos());
    }
}
