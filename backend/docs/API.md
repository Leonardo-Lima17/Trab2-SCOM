# API do CineArquivo — Documentação

Base URL (desenvolvimento local, ex. XAMPP): `http://localhost/cinearquivo/backend/public/api`

Todas as respostas são JSON, no formato:

```json
// sucesso
{ "sucesso": true, "dados": { ... } }

// erro
{ "sucesso": false, "erro": { "codigo": 422, "mensagem": "...", "campos": { "titulo": "..." } } }
```

Autenticação é feita por **sessão** (cookie `HttpOnly`). Requisições `POST`,
`PUT` e `DELETE` (exceto login/registro) exigem o header `X-CSRF-Token`,
obtido em `GET /api/csrf`.

---

## Autenticação

### `GET /api/csrf`
Retorna o token CSRF da sessão atual (crie a sessão antes, acessando qualquer rota).

**Resposta 200**
```json
{ "sucesso": true, "dados": { "token": "a1b2c3..." } }
```

---

### `POST /api/auth/registrar`
Cria uma nova conta (perfil `usuario`).

**Corpo**
```json
{ "nome": "Maria Silva", "email": "maria@exemplo.com", "senha": "minhasenha123" }
```

Regras: `nome` obrigatório (até 120 caracteres), `email` válido (até 160) e `senha` de 8 a 72 caracteres.

**Resposta 201**
```json
{ "sucesso": true, "dados": { "id": 3, "nome": "Maria Silva", "email": "maria@exemplo.com", "papel": "usuario" } }
```

**Possíveis erros**: `422` (validação), `409` (e-mail já cadastrado)

---

### `POST /api/auth/login`
**Corpo**: `{ "email": "...", "senha": "..." }`
**Resposta 200**: dados do usuário autenticado (mesma forma do registro)
**Erros**: `401` (credenciais inválidas), `422` (campos ausentes)

---

### `POST /api/auth/logout`
Encerra a sessão atual. **Resposta 200**: `{ "mensagem": "Sessão encerrada." }`

---

### `GET /api/auth/eu`
Retorna o usuário logado atualmente, ou `401` se não houver sessão.

---

## Gêneros

### `GET /api/generos`
Lista o catálogo fixo de gêneros. Endpoint público (não exige sessão).

**Resposta 200**
```json
{ "sucesso": true, "dados": [ { "id": 1, "chave": "acao", "nome": "Ação" }, ... ] }
```

---

## Filmes

Requer sessão ativa em todos os endpoints abaixo.

### `GET /api/filmes`
Lista os filmes do usuário logado (admin pode usar `?todos=1` para ver de todos).

**Query params**: `busca`, `genero`, `status` (`assistido` | `quero-assistir` | `todos`),
`ordenar` (`titulo-asc` | `ano-desc` | `ano-asc` | `nota-desc`), `pagina`, `por_pagina`(máximo 50, padrão 20)

**Exemplo**: `GET /api/filmes?busca=nolan&status=assistido&ordenar=nota-desc`

**Resposta 200**
```json
{
  "sucesso": true,
  "dados": {
    "itens": [ { "id": 1, "titulo": "A Origem", "ano": 2010, "generos": ["ficcao"], "...": "..." } ],
    "total": 12, "pagina": 1, "por_pagina": 20
  }
}
```

---

### `GET /api/filmes/{id}`
Detalhe de um filme. `403` se pertencer a outro usuário (e você não for admin). `404` se não existir.

---

### `POST /api/filmes`
Cria um filme para o usuário logado. Requer header `X-CSRF-Token`.

**Corpo**
```json
{
  "titulo": "Duna", "ano": 2021, "diretor": "Denis Villeneuve", "duracao": 155,
  "sinopse": "...", "nota": 5, "status": "assistido", "generos": ["ficcao", "aventura"],
  "poster_url": "https://image.tmdb.org/t/p/w342/exemplo.jpg", "tmdb_id": 438631
}
```

`poster_url` (opcional) deve começar com `https://`. Se for omitido e o servidor tiver a
chave do TMDB configurada, o pôster é buscado automaticamente pelo título e ano.

**Regras de validação** (erro `422` se não forem cumpridas):

- `titulo`: obrigatório, até 160 caracteres.
- `ano`: opcional, inteiro entre 1900 e 2100.
- `duracao`: opcional, inteiro entre 1 e 1000 (minutos).
- `nota`: opcional, inteiro entre 0 e 5.
- `status`: `assistido` ou `quero-assistir`.
- `generos`: lista com pelo menos um item (veja `GET /api/generos` para as chaves válidas).
- `sinopse`: opcional, até 5000 caracteres.
- `poster_url`: opcional, URL `https://` de até 500 caracteres.

**Resposta 201**: o filme criado (mesma forma de `GET /api/filmes/{id}`)
**Erros**: `422` (validação — título ou gênero ausente, ano/nota fora do intervalo etc.)

---

### `PUT /api/filmes/{id}`
Atualiza um filme (mesmo corpo do `POST`). Só o dono pode editar. `403` caso contrário.

---

### `DELETE /api/filmes/{id}`
Remove um filme. Dono **ou** admin podem excluir.

**Resposta 200**: `{ "mensagem": "Filme excluído." }`

---

## Busca no TMDB e recomendações

Requerem sessão ativa. Dependem de `TMDB_API_KEY` no `.env` do servidor.

### `GET /api/tmdb/buscar?q={titulo}`
Busca filmes no TMDB (até 8 resultados) para preencher pôster, sinopse, ano e gêneros.

**Resposta 200**
```json
{ "sucesso": true, "dados": [ {
  "tmdb_id": 438631, "titulo": "Duna", "ano": 2021, "sinopse": "...",
  "poster_url": "https://image.tmdb.org/t/p/w342/exemplo.jpg", "generos": ["ficcao", "aventura"]
} ] }
```
**Erros**: `422` (termo com menos de 2 ou mais de 120 caracteres), `503` (TMDB não configurado), `502` (TMDB indisponível)

---

### `GET /api/recomendacoes`
Até 12 sugestões para o usuário logado: filmes parecidos com os que ele avaliou com nota 4 ou 5
(via TMDB) e filmes populares entre outros usuários nos gêneros de que ele gosta. Filmes que o
usuário já tem não são sugeridos.

**Resposta 200**
```json
{ "sucesso": true, "dados": { "itens": [ {
  "tmdb_id": 155, "titulo": "Batman: O Cavaleiro das Trevas", "ano": 2008, "sinopse": "...",
  "poster_url": "https://image.tmdb.org/t/p/w342/exemplo.jpg", "generos": ["acao", "crime"],
  "motivo": "Porque você gostou de A Origem"
} ] } }
```

---

## Usuários (admin)

### `GET /api/usuarios`
Lista todos os usuários cadastrados. Requer papel `admin`; retorna `403` caso contrário.

---

## Códigos de status usados

| Código | Significado |
|---|---|
| 200 | Sucesso |
| 201 | Recurso criado |
| 400 | Requisição malformada |
| 401 | Não autenticado |
| 403 | Autenticado, mas sem permissão |
| 404 | Recurso não encontrado |
| 409 | Conflito (ex.: e-mail já cadastrado) |
| 419 | Token CSRF ausente/inválido |
| 422 | Erro de validação |
| 500 | Erro interno do servidor |
