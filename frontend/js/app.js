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