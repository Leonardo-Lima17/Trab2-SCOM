<?php

namespace App\Utils;

/**
 * Validação e sanitização de entradas vindas do cliente.
 * Acumula erros por campo para retorno estruturado (ver Response::erro).
 */
class Validator
{
    private array $erros = [];
    private array $dados;

    public function __construct(array $dados)
    {
        $this->dados = $dados;
    }

    public function obterValor(string $campo)
    {
        return $this->dados[$campo] ?? null;
    }

    public function obrigatorio(string $campo, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor === null || (is_string($valor) && trim($valor) === '')) {
            $this->erros[$campo] = "{$rotulo} é obrigatório.";
        }
        return $this;
    }

    public function tamanhoMaximo(string $campo, int $max, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if (is_string($valor) && mb_strlen($valor) > $max) {
            $this->erros[$campo] = "{$rotulo} deve ter no máximo {$max} caracteres.";
        }
        return $this;
    }

    public function tamanhoMinimo(string $campo, int $min, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if (is_string($valor) && mb_strlen($valor) < $min) {
            $this->erros[$campo] = "{$rotulo} deve ter no mínimo {$min} caracteres.";
        }
        return $this;
    }

    public function email(string $campo, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor !== null && $valor !== '' && !filter_var($valor, FILTER_VALIDATE_EMAIL)) {
            $this->erros[$campo] = "{$rotulo} não é um e-mail válido.";
        }
        return $this;
    }

    public function inteiro(string $campo, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor !== null && $valor !== '' && filter_var($valor, FILTER_VALIDATE_INT) === false) {
            $this->erros[$campo] = "{$rotulo} deve ser um número inteiro.";
        }
        return $this;
    }

    public function intervalo(string $campo, int $min, int $max, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor !== null && $valor !== '' && ((int) $valor < $min || (int) $valor > $max)) {
            $this->erros[$campo] = "{$rotulo} deve estar entre {$min} e {$max}.";
        }
        return $this;
    }

    public function emLista(string $campo, array $opcoes, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor !== null && $valor !== '' && !in_array($valor, $opcoes, true)) {
            $this->erros[$campo] = "{$rotulo} inválido(a).";
        }
        return $this;
    }

    public function urlHttps(string $campo, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if ($valor !== null && $valor !== '') {
            if (!is_string($valor)
                || !preg_match('#^https://#i', $valor)
                || filter_var($valor, FILTER_VALIDATE_URL) === false) {
                $this->erros[$campo] = "{$rotulo} deve ser uma URL válida começando com https://.";
            }
        }
        return $this;
    }

    public function listaNaoVazia(string $campo, string $rotulo): self
    {
        $valor = $this->dados[$campo] ?? null;
        if (!is_array($valor) || count($valor) === 0
            || count(array_filter($valor, 'is_string')) !== count($valor)) {
            $this->erros[$campo] = "Selecione ao menos um(a) {$rotulo}.";
        }
        return $this;
    }

    public function valido(): bool
    {
        return empty($this->erros);
    }

    public function obterErros(): array
    {
        return $this->erros;
    }

    /**
     * Sanitização de texto simples: remove tags e espaços nas pontas.
     * O escaping para exibição em HTML é feito na saída (ver Utils/Html.php),
     * nunca no momento de salvar — assim o dado original não é perdido.
     */
    public static function sanitizarTexto(?string $valor): string
    {
        if ($valor === null) {
            return '';
        }
        return trim(strip_tags($valor));
    }
}
