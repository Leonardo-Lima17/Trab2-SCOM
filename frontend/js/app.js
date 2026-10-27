/**
 * app.js
 * Camada de front-end do CineArquivo — consome a API PHP (backend/public/api)
 * via fetch. Não usa mais localStorage para os filmes: agora eles vivem no
 * banco de dados, por trás de autenticação de sessão.
 */

(function () {
  "use strict";

  // Usa o mesmo host da página (localhost ou 127.0.0.1) para que o cookie de
  // sessão seja enviado. O backend deve estar rodando na porta 8000.
  const API_BASE_URL =
  window.location.port === "8000"
    ? "/api"
    : `http://${window.location.hostname}:8000/api`;

  // =========================================================
  // Elementos da página
  // =========================================================
  const grid = document.getElementById("grade-filmes");
  const contador = document.getElementById("contador-resultados");
  const vazio = document.getElementById("estado-vazio");
  const avisoLogin = document.getElementById("aviso-login");
  const formFiltros = document.getElementById("form-filtros");
  const campoBusca = document.getElementById("campo-busca");
  const campoOrdenar = document.getElementById("campo-ordenar");
  const listaGenerosEl = document.getElementById("lista-generos");
  const botaoLimpar = document.getElementById("botao-limpar-filtros");
  const painelFiltros = document.querySelector(".painel-filtros");
  const secaoCatalogo = document.querySelector('[aria-labelledby="catalogo-titulo"]');
  const template = document.getElementById("template-card-filme");
  const paginacaoEl = document.getElementById("paginacao");
  const botaoPaginaAnterior = document.getElementById("botao-pagina-anterior");
  const botaoPaginaProxima = document.getElementById("botao-pagina-proxima");
  const infoPagina = document.getElementById("info-pagina");

  const modal = document.getElementById("modal-detalhe");
  const modalConteudo = document.getElementById("modal-conteudo");
  const modalFechar = document.getElementById("modal-fechar");
  let elementoQueAbriuModal = null;

  const modalAdicionar = document.getElementById("modal-adicionar");
  const formAdicionar = document.getElementById("form-adicionar");
  const tituloModalAdicionar = document.getElementById("modal-adicionar-titulo");
  const botaoAbrirAdicionar = document.getElementById("botao-adicionar-filme");
  const botaoCancelarAdicionar = document.getElementById("botao-cancelar-adicionar");
  const listaGenerosFormEl = document.getElementById("lista-generos-form");
  const mensagemAdicionar = document.getElementById("mensagem-adicionar");
  const botaoSalvarFilme = formAdicionar.querySelector('button[type="submit"]');
  const campoBuscaTmdb = document.getElementById("busca-tmdb");
  const botaoBuscarTmdb = document.getElementById("botao-buscar-tmdb");
  const resultadosTmdb = document.getElementById("resultados-tmdb");
  const mensagemTmdb = document.getElementById("mensagem-tmdb");
  const secaoRecomendacoes = document.getElementById("recomendacoes");
  const listaRecomendacoes = document.getElementById("lista-recomendacoes");
  const templateRecomendacao = document.getElementById("template-card-recomendacao");

  const modalAuth = document.getElementById("modal-auth");
  const botaoAbrirLogin = document.getElementById("botao-abrir-login");
  const botaoFecharAuth = document.getElementById("botao-fechar-auth");
  const abaLogin = document.getElementById("aba-login");
  const abaRegistrar = document.getElementById("aba-registrar");
  const formLogin = document.getElementById("form-login");
  const formRegistrar = document.getElementById("form-registrar");
  const mensagemLogin = document.getElementById("mensagem-login");
  const mensagemRegistrar = document.getElementById("mensagem-registrar");

  const usuarioLogadoNomeEl = document.getElementById("usuario-logado-nome");
  const botaoLogout = document.getElementById("botao-logout");

  // =========================================================
  // Estado da aplicação
  // =========================================================
  let usuarioAtual = null; // { id, nome, papel }
  let csrfToken = null;
  let generosCache = []; // [{id, chave, nome}]
  let filmeEmEdicaoId = null; // null = criando; número = editando
  let paginaAtual = 1;
  const FILMES_POR_PAGINA = 50;

  // =========================================================
  // Camada de comunicação com a API
  // =========================================================

  async function apiFetch(caminho, { method = "GET", corpo = null } = {}) {
    const precisaCsrf = method !== "GET";

    const opcoes = {
      method,
      credentials: "include",
      headers: { "Content-Type": "application/json" },
    };

    if (precisaCsrf && csrfToken) {
      opcoes.headers["X-CSRF-Token"] = csrfToken;
    }

    if (corpo !== null) {
      opcoes.body = JSON.stringify(corpo);
    }

    const resposta = await fetch(`${API_BASE_URL}${caminho}`, opcoes);
    const json = await resposta.json().catch(() => null);

    if (!resposta.ok || !json || !json.sucesso) {
      const erro = new Error(json?.erro?.mensagem || "Erro inesperado ao falar com o servidor.");
      erro.status = resposta.status;
      erro.campos = json?.erro?.campos || {};
      throw erro;
    }

    return json.dados;
  }

  async function atualizarTokenCsrf() {
    const dados = await apiFetch("/csrf");
    csrfToken = dados.token;
  }

  // =========================================================
  // Autenticação
  // =========================================================

  async function verificarSessaoAtual() {
    try {
      const dados = await apiFetch("/auth/eu");
      usuarioAtual = dados;
      await atualizarTokenCsrf();
      await depoisDeAutenticar();
    } catch {
      usuarioAtual = null;
      mostrarEstadoDeslogado();
    }
  }

  async function entrar(email, senha) {
    const dados = await apiFetch("/auth/login", {
      method: "POST",
      corpo: { email, senha },
    });
    usuarioAtual = dados;
    await atualizarTokenCsrf();
    await depoisDeAutenticar();
  }

  async function registrar(nome, email, senha) {
    const dados = await apiFetch("/auth/registrar", {
      method: "POST",
      corpo: { nome, email, senha },
    });
    usuarioAtual = dados;
    await atualizarTokenCsrf();
    await depoisDeAutenticar();
  }

  async function sair() {
    try {
      await apiFetch("/auth/logout", { method: "POST" });
    } finally {
      usuarioAtual = null;
      csrfToken = null;
      mostrarEstadoDeslogado();
    }
  }

  async function depoisDeAutenticar() {
    fecharModalAuth();
    mostrarEstadoLogado();
    await carregarGeneros();
    await carregarERenderizarFilmes();
    carregarRecomendacoes(); // não bloqueia a tela: pode depender de serviço externo
  }

  function mostrarEstadoLogado() {
    usuarioLogadoNomeEl.textContent = `Olá, ${usuarioAtual.nome.split(" ")[0]}`;
    usuarioLogadoNomeEl.hidden = false;
    botaoAbrirLogin.hidden = true;
    botaoLogout.hidden = false;
    botaoAbrirAdicionar.hidden = false;
    avisoLogin.hidden = true;
    painelFiltros.hidden = false;
    secaoCatalogo.hidden = false;
  }

  function mostrarEstadoDeslogado() {
    usuarioLogadoNomeEl.hidden = true;
    botaoAbrirLogin.hidden = false;
    botaoLogout.hidden = true;
    botaoAbrirAdicionar.hidden = true;
    avisoLogin.hidden = false;
    painelFiltros.hidden = true;
    secaoCatalogo.hidden = true;
    secaoRecomendacoes.hidden = true;
  }

  // =========================================================
  // Gêneros (filtros + formulário de adicionar/editar)
  // =========================================================

  async function carregarGeneros() {
    generosCache = await apiFetch("/generos");
    montarFiltroGeneros();
    montarGenerosFormAdicionar();
  }

  function montarFiltroGeneros() {
    listaGenerosEl.innerHTML = "";
    generosCache.forEach((genero) => {
      const id = `genero-${genero.chave}`;
      const item = document.createElement("li");
      item.className = "filtro-genero-item";
      item.innerHTML = `
        <input type="checkbox" id="${id}" name="genero" value="${genero.chave}" class="filtro-checkbox">
        <label for="${id}">${genero.nome}</label>
      `;
      listaGenerosEl.appendChild(item);
    });
  }

  function montarGenerosFormAdicionar() {
    listaGenerosFormEl.innerHTML = "";
    generosCache.forEach((genero) => {
      const id = `add-genero-${genero.chave}`;
      const item = document.createElement("li");
      item.className = "filtro-genero-item";
      item.innerHTML = `
        <input type="checkbox" id="${id}" name="genero-novo" value="${genero.chave}" class="filtro-checkbox">
        <label for="${id}">${genero.nome}</label>
      `;
      listaGenerosFormEl.appendChild(item);
    });
  }

  function nomeDoGenero(chave) {
    const encontrado = generosCache.find((g) => g.chave === chave);
    return encontrado ? encontrado.nome : chave;
  }

  // =========================================================
  // Filtros, busca, ordenação → API
  // =========================================================

  function obterFiltrosAtuais() {
    const generosSelecionados = Array.from(
      formFiltros.querySelectorAll('input[name="genero"]:checked')
    ).map((el) => el.value);

    return {
      busca: campoBusca.value.trim(),
      genero: generosSelecionados[0] || "", // backend filtra por 1 gênero por vez
      status: formFiltros.querySelector('input[name="status"]:checked').value,
      ordenar: campoOrdenar.value,
    };
  }

  function montarQueryString(filtros, pagina) {
    const params = new URLSearchParams();
    if (filtros.busca) params.set("busca", filtros.busca);
    if (filtros.genero) params.set("genero", filtros.genero);
    if (filtros.status) params.set("status", filtros.status);
    if (filtros.ordenar) params.set("ordenar", filtros.ordenar);
    params.set("pagina", String(pagina));
    params.set("por_pagina", String(FILMES_POR_PAGINA));
    return params.toString();
  }

  async function carregarERenderizarFilmes() {
    const filtros = obterFiltrosAtuais();
    const query = montarQueryString(filtros, paginaAtual);

    try {
      const resultado = await apiFetch(`/filmes?${query}`);
            // Se apagou o último filme da página, volta para a anterior
      if (resultado.itens.length === 0 && paginaAtual > 1) {
        paginaAtual--;
        return carregarERenderizarFilmes();
      }

      renderizarGrade(resultado.itens, resultado.total);
      atualizarPaginacao(resultado.total);
    } catch (erro) {
      contador.textContent = "Não foi possível carregar seus filmes.";
      console.error(erro);
    }
  }

  // =========================================================
  // Renderização da grade
  // =========================================================

  function atualizarPaginacao(total) {
    const totalPaginas = Math.max(1, Math.ceil(total / FILMES_POR_PAGINA));
    paginacaoEl.hidden = totalPaginas <= 1;
    infoPagina.textContent = `Página ${paginaAtual} de ${totalPaginas}`;
    botaoPaginaAnterior.disabled = paginaAtual <= 1;
    botaoPaginaProxima.disabled = paginaAtual >= totalPaginas;
  }

  function mudarPagina(delta) {
    paginaAtual += delta;
    carregarERenderizarFilmes();
    secaoCatalogo.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function renderizarGrade(filmes, total) {
    grid.innerHTML = "";

    contador.textContent =
      total === 1 ? "1 filme encontrado" : `${total} filmes encontrados`;

    if (filmes.length === 0) {
      vazio.hidden = false;
      return;
    }
    vazio.hidden = true;

    const fragmento = document.createDocumentFragment();

    filmes.forEach((filme) => {
      const clone = template.content.cloneNode(true);
      const artigo = clone.querySelector(".card-filme");
      const poster = clone.querySelector(".card-filme__poster");
      const titulo = clone.querySelector(".card-filme__titulo");
      const meta = clone.querySelector(".card-filme__meta");
      const badgeStatus = clone.querySelector(".card-filme__badge");
      const badgePersonalizado = clone.querySelector(".card-filme__badge-personalizado");
      const botao = clone.querySelector(".card-filme__botao");

      artigo.id = `filme-${filme.id}`;
      poster.style.setProperty("--cor-poster", filme.cor_tema || "#333952");
      aplicarPoster(poster, filme.poster_url, filme.titulo);

      titulo.textContent = filme.titulo;
      meta.textContent = `${filme.ano ?? "?"} · ${filme.diretor}`;

      if (filme.status === "assistido") {
        badgeStatus.textContent = `Assistido · ${"★".repeat(filme.nota)}${"☆".repeat(5 - filme.nota)}`;
        badgeStatus.classList.add("card-filme__badge--assistido");
      } else {
        badgeStatus.textContent = "Quero assistir";
        badgeStatus.classList.add("card-filme__badge--pendente");
      }

      // "Adicionado por você" é reaproveitado como "meu filme" (dono da sessão)
      if (usuarioAtual && filme.usuario_id === usuarioAtual.id && badgePersonalizado) {
        badgePersonalizado.hidden = false;
      }

      botao.setAttribute("aria-label", `Ver detalhes de ${filme.titulo}`);
      botao.dataset.filmeId = filme.id;
      botao.addEventListener("click", (evento) => abrirModal(filme, evento.currentTarget));

      fragmento.appendChild(clone);
    });

    grid.appendChild(fragmento);
  }

  function obterIniciais(titulo) {
    return titulo
      .split(" ")
      .filter((palavra) => palavra.length > 2)
      .slice(0, 2)
      .map((palavra) => palavra[0])
      .join("")
      .toUpperCase();
  }

  // Mostra o pôster por cima das iniciais; se a imagem falhar, as iniciais ficam.
  function aplicarPoster(elementoPoster, posterUrl, titulo) {
    elementoPoster.textContent = obterIniciais(titulo);
    if (!posterUrl) return;

    const img = document.createElement("img");
    img.className = "card-filme__imagem";
    img.alt = `Pôster do filme ${titulo}`;
    img.loading = "lazy";
    img.decoding = "async";
    img.referrerPolicy = "no-referrer";
    img.addEventListener("error", () => img.remove());
    img.src = posterUrl;
    elementoPoster.appendChild(img);
  }

  // =========================================================
  // Login / registro
  // =========================================================

  function abrirModalAuth() {
    modalAuth.showModal();
    document.getElementById("login-email").focus();
  }

  function fecharModalAuth() {
    if (modalAuth.open) modalAuth.close();
    mensagemLogin.textContent = "";
    mensagemRegistrar.textContent = "";
    formLogin.reset();
    formRegistrar.reset();
  }

  function mostrarAbaLogin() {
    abaLogin.classList.add("aba-auth--ativa");
    abaLogin.setAttribute("aria-selected", "true");
    abaRegistrar.classList.remove("aba-auth--ativa");
    abaRegistrar.setAttribute("aria-selected", "false");
    formLogin.hidden = false;
    formRegistrar.hidden = true;
  }

  function mostrarAbaRegistrar() {
    abaRegistrar.classList.add("aba-auth--ativa");
    abaRegistrar.setAttribute("aria-selected", "true");
    abaLogin.classList.remove("aba-auth--ativa");
    abaLogin.setAttribute("aria-selected", "false");
    formRegistrar.hidden = false;
    formLogin.hidden = true;
  }

  async function tratarEnvioLogin(evento) {
    evento.preventDefault();
    mensagemLogin.textContent = "";
    try {
      await entrar(
        document.getElementById("login-email").value.trim(),
        document.getElementById("login-senha").value
      );
    } catch (erro) {
      mensagemLogin.textContent = erro.message;
      mensagemLogin.className = "mensagem-form mensagem-form--erro";
    }
  }

  async function tratarEnvioRegistrar(evento) {
    evento.preventDefault();
    mensagemRegistrar.textContent = "";
    try {
      await registrar(
        document.getElementById("registrar-nome").value.trim(),
        document.getElementById("registrar-email").value.trim(),
        document.getElementById("registrar-senha").value
      );
    } catch (erro) {
      const primeiroErroDeCampo = Object.values(erro.campos || {})[0];
      mensagemRegistrar.textContent = primeiroErroDeCampo || erro.message;
      mensagemRegistrar.className = "mensagem-form mensagem-form--erro";
    }
  }

  // =========================================================
  // Limpar filtros
  // =========================================================

  function limparFiltros() {
    formFiltros.reset();
    campoBusca.value = "";
    campoOrdenar.value = "titulo-asc";
    paginaAtual = 1;
    carregarERenderizarFilmes();
    campoBusca.focus();
  }

  // =========================================================
  // Eventos
  // =========================================================

  formFiltros.addEventListener("change", () => {
    paginaAtual = 1;
    carregarERenderizarFilmes();
  });
  campoBusca.addEventListener("input", () => {
    paginaAtual = 1;
    carregarERenderizarFilmes();
  });
  campoOrdenar.addEventListener("change", () => {
    paginaAtual = 1;
    carregarERenderizarFilmes();
  });
  botaoLimpar.addEventListener("click", limparFiltros);
  botaoPaginaAnterior.addEventListener("click", () => mudarPagina(-1));
  botaoPaginaProxima.addEventListener("click", () => mudarPagina(1));

  modalFechar.addEventListener("click", fecharModal);
  modal.addEventListener("cancel", (evento) => {
    evento.preventDefault();
    fecharModal();
  });
  modal.addEventListener("click", (evento) => {
    if (evento.target === modal) fecharModal();
  });

  botaoAbrirAdicionar.addEventListener("click", () => abrirModalAdicionar(null));
  botaoCancelarAdicionar.addEventListener("click", fecharModalAdicionar);
  formAdicionar.addEventListener("submit", tratarEnvioFormAdicionar);
  modalAdicionar.addEventListener("cancel", (evento) => {
    evento.preventDefault();
    fecharModalAdicionar();
  });
  modalAdicionar.addEventListener("click", (evento) => {
    if (evento.target === modalAdicionar) fecharModalAdicionar();
  });

  botaoBuscarTmdb.addEventListener("click", buscarNoTmdb);
  campoBuscaTmdb.addEventListener("keydown", (evento) => {
    if (evento.key === "Enter") {
      evento.preventDefault(); // Enter na busca não deve enviar o formulário
      buscarNoTmdb();
    }
  });

  botaoAbrirLogin.addEventListener("click", abrirModalAuth);
  botaoFecharAuth.addEventListener("click", fecharModalAuth);
  modalAuth.addEventListener("cancel", (evento) => {
    evento.preventDefault();
    fecharModalAuth();
  });
  abaLogin.addEventListener("click", mostrarAbaLogin);
  abaRegistrar.addEventListener("click", mostrarAbaRegistrar);
  formLogin.addEventListener("submit", tratarEnvioLogin);
  formRegistrar.addEventListener("submit", tratarEnvioRegistrar);
  botaoLogout.addEventListener("click", sair);

  // =========================================================
  // Inicialização
  // =========================================================

  painelFiltros.hidden = true;
  secaoCatalogo.hidden = true;
  secaoRecomendacoes.hidden = true;
  verificarSessaoAtual();
})();