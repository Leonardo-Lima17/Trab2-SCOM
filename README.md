# CineArquivo — Trabalho Individual II (SCOM)

Evolução do catálogo pessoal de filmes do Trabalho 1, agora com backend
funcional em **PHP + PDO**, banco de dados **MySQL/MariaDB**, autenticação
por sessão, controle de acesso por papéis, validação/sanitização, proteção
contra SQLi/XSS/CSRF, testes automatizados e logs de aplicação.

## Arquitetura

Padrão **MVC simplificado em camadas**:

```
backend/
  config/       → conexão PDO + carregamento de variáveis de ambiente (.env)
  src/
    Controllers/  → recebem a requisição, chamam Models, devolvem Response
    Models/       → única camada que fala com o banco (PDO + prepared statements)
    Middleware/   → Auth (sessão + papéis)
    Utils/        → Response, Validator, Html (escaping), Logger, Csrf
  public/         → index.php (front controller / roteador) + .htaccess
  database/       → schema.sql
  tests/          → suíte de testes automatizados (sem dependências externas)
  docs/           → API.md (documentação de endpoints)
  logs/           → app.log (gerado em tempo de execução)
frontend/         → HTML5/CSS3/JS do Trabalho 1, adaptado para consumir a API
```

Fluxo de uma requisição: `public/index.php` (roteador) → `Controller` →
`Middleware\Auth` (quando aplicável) → `Model` (PDO) → `Response` (JSON).

## Pré-requisitos

- PHP ≥ 8.1 com extensão `pdo_mysql`
- MySQL ou MariaDB
- Servidor web com `mod_rewrite` (Apache/XAMPP) **ou** o servidor embutido do PHP

## Instalação

1. **Banco de dados**: importe o script de criação
   ```bash
   mysql -u root -p < backend/database/schema.sql
   ```
   Isso cria o banco `cinearquivo`, as tabelas, os gêneros e um usuário
   `admin@cinearquivo.local`. **Antes de usar o login desse admin**, gere a
   hash real da senha desejada e atualize a coluna `senha_hash`:
   ```bash
   php backend/scripts/gerar_hash.php "suaSenhaForte123"
   # copie o resultado e rode no MySQL:
   # UPDATE usuarios SET senha_hash = '<hash gerada>' WHERE email = 'admin@cinearquivo.local';
   ```

2. **(Opcional) Importar o catálogo do Trabalho 1**: os 116 filmes que
   estavam hardcoded em `data.js` podem ser migrados para o banco,
   associados ao usuário admin:
   ```bash
   mysql -u root -p cinearquivo < backend/database/seed_catalogo_inicial.sql
   ```

3. **Variáveis de ambiente**: copie o exemplo e ajuste suas credenciais
   ```bash
   cp backend/.env.example backend/.env
   ```

4. **Rodar o backend** (servidor embutido do PHP, mais simples para desenvolvimento):
   ```bash
   cd backend/public
   php -S localhost:8000
   ```
   A API fica disponível em `http://localhost:8000/api/...`
   (em Apache/XAMPP, aponte o DocumentRoot para `backend/public`, o `.htaccess` já cuida do roteamento).

5. **Rodar o frontend**: abra `frontend/index.html` em um servidor estático
   (ex. extensão Live Server do VS Code), ou sirva a pasta com:
   ```bash
   cd frontend
   php -S localhost:5500
   ```
   Ajuste a constante `API_BASE_URL` em `frontend/js/app.js` se as portas
   forem diferentes das do exemplo.

## Pôsteres e recomendações (opcional, via TMDB)

1. Crie uma conta gratuita em themoviedb.org e gere uma chave em *Configurações > API*.
2. Coloque a chave em `backend/.env`: `TMDB_API_KEY=sua_chave` (nunca versione esse arquivo).
3. Em um banco já existente, aplique a migração (não apaga dados):
   ```bash
   mysql -u root -p < backend/database/migrations/001_poster_e_tmdb.sql
   ```
   (instalações novas já recebem as colunas pelo `schema.sql`).
4. Para preencher os pôsteres dos filmes que já estão no banco (ex.: o seed):
   ```bash
   php backend/scripts/preencher_posters.php
   ```

Sem a chave, o site funciona normalmente: os filmes ficam com as iniciais no lugar do pôster
e as recomendações usam só os filmes de outros usuários. Novos filmes salvos sem pôster
recebem um automaticamente quando a chave está configurada.

## Testes automatizados

```bash
php backend/tests/run_tests.php
```
Cobre validação de entradas (casos válidos e inválidos), lógica de hash de
senha, proteção CSRF e mapeamento de gêneros do TMDB. Retorna código de saída `0` se tudo passar.

## Segurança implementada

- **SQL Injection**: todo acesso ao banco usa `PDO::prepare()` com parâmetros
  nomeados — nenhuma concatenação de valores externos em SQL.
- **XSS**: sanitização de entrada (`strip_tags`) + a API responde em JSON
  (escapado por `json_encode`); `Utils/Html::escapar()` documenta o padrão
  de escaping para qualquer saída HTML futura.
- **CSRF**: token por sessão (`Utils/Csrf`), exigido no header
  `X-CSRF-Token` em toda requisição `POST/PUT/DELETE` (exceto login/registro).
- **Autenticação**: senhas com `password_hash()`/`password_verify()`
  (bcrypt), `session_regenerate_id()` no login, cookies `HttpOnly` + `SameSite=Lax`.
- **Controle de acesso**: `Middleware\Auth` bloqueia rotas sem sessão (401)
  ou sem o papel exigido (403); `FilmeController` valida posse do recurso
  em toda operação de escrita.

## Uso de IA generativa

Este projeto foi desenvolvido com apoio do Claude (Anthropic) para geração e
revisão de código, a partir dos requisitos do professor e do código do
Trabalho 1 fornecido pelo aluno. Detalhe o uso real (o que foi gerado, o que
foi revisado/alterado manualmente) na seção 13 do relatório, conforme exigido
no enunciado — a ausência dessa declaração pode zerar a nota do trabalho.
