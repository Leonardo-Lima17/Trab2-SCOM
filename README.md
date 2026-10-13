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