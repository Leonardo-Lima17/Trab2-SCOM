# CineArquivo — Trabalho Individual II (SCOM)

Evolução do catálogo pessoal de filmes do Trabalho 1, agora com backend
funcional em **PHP + PDO**, banco de dados **MySQL/MariaDB**, autenticação
por sessão, controle de acesso por perfis, validação/sanitização, proteção
contra SQL Injection, XSS, CSRF e acesso não autorizado, testes
automatizados e logs de aplicação.

## Arquitetura

Padrão **MVC simplificado em camadas** (interface, lógica de aplicação e
acesso a dados separados):

```
backend/
  config/         → conexão PDO + leitura do .env
  src/
    Controllers/  → regras de cada operação; chamam Models e devolvem Response
    Models/       → única camada que fala com o banco (PDO + prepared statements)
    Middleware/   → Auth (sessão e perfis)
    Services/     → TmdbService (API externa de pôsteres e recomendações)
    Utils/        → Response, Validator, Csrf, Logger
  public/         → index.php (front controller / roteador) + .htaccess
  database/       → schema.sql, seed_catalogo_inicial.sql, migrations/
  tests/          → testes automatizados (sem dependências externas)
  scripts/        → gerar_hash.php, preencher_posters.php
  docs/           → API.md (documentação dos endpoints)
  logs/           → app.log (gerado em tempo de execução)
  router.php      → roteador do servidor embutido (frontend + API na mesma origem)
  vendor_autoload.php → autoloader simples do namespace App\ (sem Composer)
frontend/         → HTML5, CSS3 e JavaScript, consumindo a API
```

Fluxo de uma requisição: `public/index.php` (roteador) → `Controller` →
`Middleware\Auth` (quando aplicável) → `Model` (PDO) → `Response` (JSON).

## Pré-requisitos

- PHP 8.1 ou superior, com a extensão `pdo_mysql`
- MySQL ou MariaDB em execução (no XAMPP, inicie o MySQL no painel)

## Instalação e execução

1. **Banco de dados.** No phpMyAdmin, aba **Importar**, envie o arquivo
   `backend/database/schema.sql`. Ele cria o banco `cinearquivo`, as
   tabelas, os 12 gêneros e o usuário `admin@cinearquivo.local`.
   (Pelo terminal em Linux/macOS/CMD: `mysql -u root -p < backend/database/schema.sql`;
   o PowerShell não aceita o `<`.)

2. **Senha do administrador.** O `schema.sql` grava um valor inválido de
   propósito, então o login do admin só funciona depois de definir a senha.
   A partir da raiz do projeto:
   ```bash
   php backend/scripts/gerar_hash.php "sua_senha"
   ```
   Copie a hash gerada e execute na aba SQL do phpMyAdmin:
   ```sql
   UPDATE usuarios SET senha_hash = '<hash gerada>' WHERE email = 'admin@cinearquivo.local';
   ```

3. **Variáveis de ambiente.** Copie o exemplo e ajuste, se necessário
   (no XAMPP o padrão `root` sem senha já funciona):
   ```bash
   cp backend/.env.example backend/.env
   ```
   O `.env` nunca é versionado.

4. **(Opcional) Catálogo do Trabalho 1.** Importe pelo phpMyAdmin, com o
   banco `cinearquivo` selecionado, o arquivo
   `backend/database/seed_catalogo_inicial.sql` (116 filmes associados ao admin).

5. **Iniciar o sistema.** Na **raiz do projeto** (a pasta que contém
   `backend/` e `frontend/`):
   ```bash
   php -S 127.0.0.1:8000 -t frontend backend/router.php
   ```
   Acesse **http://127.0.0.1:8000** (use sempre `127.0.0.1`, não `localhost`,
   para o cookie de sessão funcionar). O servidor entrega o frontend e a API
   na mesma origem. Não abra o `index.html` direto pelo explorador de
   arquivos nem pelo Live Server: a API não responde nesse modo.

   No Windows com XAMPP, se o comando `php` não for reconhecido, use o
   caminho completo (`C:\xampp\php\php.exe -S 127.0.0.1:8000 -t frontend backend/router.php`)
   ou adicione `C:\xampp\php` à variável de ambiente PATH.

## Perfis de acesso

- **usuario**: cadastra-se pelo site e gerencia apenas o próprio catálogo.
- **admin**: gerencia o próprio catálogo e, além disso, pode marcar
  "Ver filmes de todos os usuários" na tela, excluir qualquer filme e
  listar os usuários (`GET /api/usuarios`). Não edita filmes de terceiros.

A matriz completa de permissões está no relatório técnico.

## Pôsteres e recomendações (opcional, via TMDB)

1. Crie uma conta gratuita em themoviedb.org e gere uma chave em
   *Configurações > API*.
2. Coloque a chave em `backend/.env`: `TMDB_API_KEY=sua_chave`
   (nunca versione esse arquivo).
3. Em um banco já existente, aplique a migração
   `backend/database/migrations/001_poster_e_tmdb.sql` pelo phpMyAdmin
   (não apaga dados; instalações novas já recebem as colunas pelo `schema.sql`).
4. Para preencher os pôsteres dos filmes que já estão no banco (ex.: o seed):
   ```bash
   php backend/scripts/preencher_posters.php
   ```

Sem a chave, o site funciona normalmente: os filmes ficam com as iniciais
no lugar do pôster e as recomendações usam só os filmes de outros usuários.

## Testes automatizados

```bash
php backend/tests/run_tests.php
```
São 18 testes (casos válidos e inválidos) de validação de entradas, hash de
senha, proteção CSRF e mapeamento de gêneros do TMDB. O código de saída é
`0` se todos passarem.

## Documentação da API

Todos os endpoints, com parâmetros, exemplos e códigos de status, estão em
[`backend/docs/API.md`](backend/docs/API.md).

## Segurança implementada

- **SQL Injection**: todo acesso ao banco usa `PDO::prepare()` com parâmetros
  e `ATTR_EMULATE_PREPARES` desligado; a ordenação usa lista de valores permitidos.
- **XSS**: tags HTML removidas na entrada (`strip_tags`); a API responde em JSON
  com `X-Content-Type-Options: nosniff`; o frontend insere dados com
  `textContent` ou com a função `escaparHtml`; URLs de pôster só aceitam `https://`.
- **CSRF**: token por sessão (`Utils/Csrf`), exigido no header `X-CSRF-Token`
  em toda requisição `POST/PUT/DELETE` (exceto login e cadastro).
- **Autenticação**: `password_hash()`/`password_verify()` (bcrypt),
  `session_regenerate_id()` no login, cookie `HttpOnly` + `SameSite=Lax`.
- **Controle de acesso**: `Middleware\Auth` responde 401 sem sessão e 403 sem
  o perfil exigido; os controllers verificam a posse do recurso.
- **Validação**: tipos, tamanhos e intervalos validados no backend, com
  mensagens de erro por campo (HTTP 422).
- **Logs**: `backend/logs/app.log`, com data e hora (login, falha de
  autenticação, criação de entidades, acesso negado e erros internos).

## Uso de IA generativa

Este projeto foi desenvolvido com apoio do Claude (Anthropic), por meio do
chat claude.ai, para geração e revisão de código (backend, esquema SQL,
testes, documentação e adaptação do frontend). O código gerado foi
executado, testado e corrigido pelo autor. O detalhamento por arquivo, os
defeitos encontrados e a avaliação crítica estão na seção 13 e no
Apêndice A do relatório técnico.