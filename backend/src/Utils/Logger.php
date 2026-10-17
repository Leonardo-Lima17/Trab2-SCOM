<?php

namespace App\Utils;

/**
 * Observabilidade básica: grava eventos da aplicação em arquivo de log
 * com timestamp. Cobre os eventos mínimos pedidos no enunciado:
 * login bem-sucedido, falha de autenticação, criação de entidade, erro interno.
 */
class Logger
{
    private static string $arquivoLog = __DIR__ . '/../../logs/app.log';

    private static function escrever(string $nivel, string $mensagem, array $contexto = []): void
    {
        $timestamp = date('Y-m-d H:i:s');
        $contextoTexto = empty($contexto) ? '' : ' ' . json_encode($contexto, JSON_UNESCAPED_UNICODE);
        $linha = "[{$timestamp}] [{$nivel}] {$mensagem}{$contextoTexto}" . PHP_EOL;

        // Cria a pasta de logs se não existir (evita warning em instalação nova)
        $pasta = dirname(self::$arquivoLog);
        if (!is_dir($pasta)) {
            mkdir($pasta, 0775, true);
        }

        file_put_contents(self::$arquivoLog, $linha, FILE_APPEND);
    }

    public static function loginSucesso(string $email): void
    {
        self::escrever('INFO', 'Login bem-sucedido', ['email' => $email]);
    }

    public static function falhaAutenticacao(string $email): void
    {
        self::escrever('AVISO', 'Falha de autenticação', ['email' => $email]);
    }

    public static function entidadeCriada(string $entidade, $id): void
    {
        self::escrever('INFO', "Entidade criada: {$entidade}", ['id' => $id]);
    }

    public static function erroInterno(string $mensagem, array $contexto = []): void
    {
        self::escrever('ERRO', $mensagem, $contexto);
    }

    public static function acessoNegado(string $rota, ?int $usuarioId): void
    {
        self::escrever('AVISO', 'Acesso negado', ['rota' => $rota, 'usuario_id' => $usuarioId]);
    }
}
