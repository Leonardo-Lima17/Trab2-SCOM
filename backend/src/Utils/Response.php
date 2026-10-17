<?php

namespace App\Utils;

/**
 * Padroniza toda saída da API em JSON, com o mesmo "formato de envelope"
 * para sucesso e erro. Isso atende ao requisito de "respostas consistentes
 * em JSON" e "tratamento de erros padronizado".
 */
class Response
{
    public static function sucesso($dados = null, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        header('X-Content-Type-Options: nosniff');
        echo json_encode([
            'sucesso' => true,
            'dados'   => $dados,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * @param string      $mensagem    Mensagem legível para o cliente
     * @param int         $status      Código de status HTTP
     * @param string|null $detalhe     Detalhe técnico (só exposto em APP_ENV=development)
     * @param array       $erros       Erros de validação campo a campo (opcional)
     */
    public static function erro(
        string $mensagem,
        int $status = 400,
        ?string $detalhe = null,
        array $erros = []
    ): void {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        header('X-Content-Type-Options: nosniff');

        $corpo = [
            'sucesso' => false,
            'erro' => [
                'codigo'   => $status,
                'mensagem' => $mensagem,
            ],
        ];

        if (!empty($erros)) {
            $corpo['erro']['campos'] = $erros;
        }

        if ($detalhe !== null && env('APP_ENV', 'production') === 'development') {
            $corpo['erro']['detalhe_tecnico'] = $detalhe;
        }

        echo json_encode($corpo, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
