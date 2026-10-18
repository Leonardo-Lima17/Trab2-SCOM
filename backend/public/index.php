<?php

/**
 * Front controller único da API do CineArquivo.
 * Todas as requisições passam por aqui (ver .htaccess) e são roteadas
 * para o Controller correspondente, de acordo com método HTTP + URL.
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/env.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../vendor_autoload.php'; // autoload simples, ver arquivo

use App\Controllers\AuthController;
use App\Controllers\FilmeController;
use App\Controllers\GeneroController;
use App\Controllers\RecomendacaoController;
use App\Controllers\UsuarioController;
use App\Utils\Csrf;
use App\Utils\Logger;
use App\Utils\Response;

// ---------------------------------------------------------
// Sessão segura
// ---------------------------------------------------------
session_name(env('SESSION_NAME', 'cinearquivo_sessao'));
session_set_cookie_params([
    'lifetime' => (int) env('SESSION_LIFETIME', 7200),
    'path'     => '/',
    'httponly' => true,     // JS não acessa o cookie de sessão
    'samesite' => 'Lax',    // mitigação adicional de CSRF
    'secure'   => (($_SERVER['HTTPS'] ?? '') !== ''), // true em produção com HTTPS
]);
session_start();

// ---------------------------------------------------------
// CORS: com cookies de sessão (credentials) o navegador NÃO aceita "*".
// Por isso devolvemos a própria origem, mas só se estiver na lista permitida.
// Configure FRONTEND_ORIGINS no .env (separadas por vírgula).
// ---------------------------------------------------------
$origensPermitidas = array_map('trim', explode(',', env(
    'FRONTEND_ORIGINS',
    'http://localhost:5500,http://127.0.0.1:5500,http://localhost:5501,http://127.0.0.1:5501'
)));
$origemRequisicao = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origemRequisicao, $origensPermitidas, true)) {
    header("Access-Control-Allow-Origin: {$origemRequisicao}");
    header('Access-Control-Allow-Credentials: true');
    header('Vary: Origin');
}
header('Access-Control-Allow-Headers: Content-Type, X-CSRF-Token');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ---------------------------------------------------------
// Tratamento centralizado de erros não previstos
// ---------------------------------------------------------
set_exception_handler(function (Throwable $e): void {
    Logger::erroInterno($e->getMessage(), ['tipo' => get_class($e)]);
    Response::erro('Erro interno do servidor.', 500, $e->getMessage() . ' em ' . $e->getFile() . ':' . $e->getLine());
});

// ---------------------------------------------------------
// Corpo da requisição (JSON) + query string
// ---------------------------------------------------------
$metodo = $_SERVER['REQUEST_METHOD'];
$corpoBruto = file_get_contents('php://input');
$corpo = [];
if ($corpoBruto !== '' && str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/json')) {
    $corpo = json_decode($corpoBruto, true) ?? [];
}
$query = $_GET;

// Métodos que alteram estado exigem token CSRF válido
$metodosProtegidos = ['POST', 'PUT', 'DELETE'];
$rotaCsrfIsenta = str_ends_with(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/auth/login')
    || str_ends_with(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/auth/registrar');

if (in_array($metodo, $metodosProtegidos, true) && !$rotaCsrfIsenta) {
    $tokenRecebido = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? null;
    if (!Csrf::validar($tokenRecebido)) {
        Response::erro('Token CSRF ausente ou inválido.', 419);
    }
}

// ---------------------------------------------------------
// Roteamento simples baseado em caminho + método
// ---------------------------------------------------------
$caminho = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
// Remove o prefixo até .../public, se o projeto estiver em subpasta
$caminho = preg_replace('#^.*/public#', '', $caminho);
$caminho = rtrim($caminho, '/');
$segmentos = explode('/', trim($caminho, '/')); // ex.: ['api', 'filmes', '12']

$pdo = obterConexao();

// /api/csrf — devolve o token para o front guardar antes de enviar formulários
if ($caminho === '/api/csrf' && $metodo === 'GET') {
    Response::sucesso(['token' => Csrf::gerarToken()]);
}

// /api/tmdb/buscar e /api/recomendacoes
if ($caminho === '/api/tmdb/buscar' && $metodo === 'GET') {
    (new RecomendacaoController($pdo))->buscarNoTmdb($query);
}
if ($caminho === '/api/recomendacoes' && $metodo === 'GET') {
    (new RecomendacaoController($pdo))->listar();
}

// /api/auth/...
if (($segmentos[1] ?? '') === 'auth') {
    $controller = new AuthController($pdo);
    $acao = $segmentos[2] ?? '';

    match (true) {
        $acao === 'registrar' && $metodo === 'POST' => $controller->registrar($corpo),
        $acao === 'login' && $metodo === 'POST'     => $controller->login($corpo),
        $acao === 'logout' && $metodo === 'POST'    => $controller->logout(),
        $acao === 'eu' && $metodo === 'GET'         => $controller->eu(),
        default => Response::erro('Rota não encontrada.', 404),
    };
}

// /api/generos
if (($segmentos[1] ?? '') === 'generos' && $metodo === 'GET') {
    (new GeneroController($pdo))->listar();
}

// /api/usuarios (admin)
if (($segmentos[1] ?? '') === 'usuarios' && $metodo === 'GET') {
    (new UsuarioController($pdo))->listar();
}

// /api/filmes  e  /api/filmes/{id}
if (($segmentos[1] ?? '') === 'filmes') {
    $controller = new FilmeController($pdo);
    $id = isset($segmentos[2]) ? (int) $segmentos[2] : null;

    match (true) {
        $id === null && $metodo === 'GET'  => $controller->listar($query),
        $id === null && $metodo === 'POST' => $controller->criar($corpo),
        $id !== null && $metodo === 'GET'    => $controller->buscarUm($id),
        $id !== null && $metodo === 'PUT'    => $controller->atualizar($id, $corpo),
        $id !== null && $metodo === 'DELETE' => $controller->excluir($id),
        default => Response::erro('Rota não encontrada.', 404),
    };
}

Response::erro('Rota não encontrada.', 404);
