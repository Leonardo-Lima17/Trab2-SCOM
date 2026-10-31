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
  // Modal de detalhe (+ editar/excluir)
  // =========================================================

  function abrirModal(filme, elementoOrigem) {
    elementoQueAbriuModal = elementoOrigem;

    const generosTexto = filme.generos.map(nomeDoGenero).join(", ");
    const ehDono = usuarioAtual && filme.usuario_id === usuarioAtual.id;
    const podeExcluir = ehDono || (usuarioAtual && usuarioAtual.papel === "admin");

    modalConteudo.innerHTML = `
      <h2 id="modal-titulo">${escaparHtml(filme.titulo)}</h2>
      <p class="modal-meta">${filme.ano ?? "?"} · ${escaparHtml(filme.diretor)} · ${filme.duracao ?? "?"} min</p>
      <p class="modal-generos"><strong>Gêneros:</strong> ${escaparHtml(generosTexto)}</p>
      <p class="modal-sinopse">${escaparHtml(filme.sinopse || "Sem sinopse cadastrada.")}</p>
      <p class="modal-status">${
        filme.status === "assistido"
          ? `Avaliação pessoal: ${"★".repeat(filme.nota)}${"☆".repeat(5 - filme.nota)}`
          : "Ainda não assistido — está na lista de interesse."
      }</p>
      <div class="modal-acoes">
        ${ehDono ? `<button type="button" class="botao" id="botao-editar-filme">Editar</button>` : ""}
        ${podeExcluir ? `<button type="button" class="botao botao--remover" id="botao-remover-filme">Excluir</button>` : ""}
      </div>
    `;

    if (filme.poster_url) {
      const img = document.createElement("img");
      img.className = "modal-poster";
      img.alt = `Pôster do filme ${filme.titulo}`;
      img.referrerPolicy = "no-referrer";
      img.addEventListener("error", () => img.remove());
      img.src = filme.poster_url;
      modalConteudo.prepend(img);
    }

    if (ehDono) {
      document.getElementById("botao-editar-filme").addEventListener("click", () => {
        fecharModal();
        abrirModalAdicionar(filme);
      });
    }

    if (podeExcluir) {
      document.getElementById("botao-remover-filme").addEventListener("click", async () => {
        try {
          await apiFetch(`/filmes/${filme.id}`, { method: "DELETE" });
          fecharModal();
          await carregarERenderizarFilmes();
          carregarRecomendacoes();
        } catch (erro) {
          alert(erro.message);
        }
      });
    }

    modal.showModal();
    modalFechar.focus();
  }

  function fecharModal() {
    modal.close();
    if (elementoQueAbriuModal) {
      elementoQueAbriuModal.focus();
    }
  }

  function escaparHtml(texto) {
    const div = document.createElement("div");
    div.textContent = texto ?? "";
    return div.innerHTML;
  }

  // =========================================================
  // Formulário "Adicionar / editar filme"
  // =========================================================

  function abrirModalAdicionar(filmeParaEditar = null, sugestao = null) {
    formAdicionar.reset();
    mensagemAdicionar.textContent = "";
    mensagemTmdb.textContent = "";
    resultadosTmdb.innerHTML = "";
    resultadosTmdb.hidden = true;
    campoBuscaTmdb.value = "";
    document.getElementById("novo-poster").value = "";
    document.getElementById("novo-tmdb-id").value = "";
    montarGenerosFormAdicionar();

    if (filmeParaEditar) {
      filmeEmEdicaoId = filmeParaEditar.id;
      tituloModalAdicionar.textContent = "Editar filme";
      botaoSalvarFilme.textContent = "Salvar alterações";

      document.getElementById("novo-titulo").value = filmeParaEditar.titulo;
      document.getElementById("novo-ano").value = filmeParaEditar.ano ?? "";
      document.getElementById("novo-duracao").value = filmeParaEditar.duracao ?? "";
      document.getElementById("novo-diretor").value = filmeParaEditar.diretor ?? "";
      document.getElementById("novo-nota").value = String(filmeParaEditar.nota ?? 0);
      document.getElementById("novo-sinopse").value = filmeParaEditar.sinopse ?? "";
      document.getElementById("novo-poster").value = filmeParaEditar.poster_url ?? "";
      document.getElementById("novo-tmdb-id").value = filmeParaEditar.tmdb_id ?? "";

      const statusInput = formAdicionar.querySelector(
        `input[name="status-novo"][value="${filmeParaEditar.status}"]`
      );
      if (statusInput) statusInput.checked = true;

      filmeParaEditar.generos.forEach((chave) => {
        const checkbox = document.getElementById(`add-genero-${chave}`);
        if (checkbox) checkbox.checked = true;
      });
    } else {
      filmeEmEdicaoId = null;
      tituloModalAdicionar.textContent = "Adicionar filme à minha lista";
      botaoSalvarFilme.textContent = "Salvar filme";

      if (sugestao) {
        // Veio de uma recomendação: já entra como "quero assistir"
        preencherFormularioComFilme(sugestao);
        document.getElementById("novo-status-pendente").checked = true;
      }
    }

    modalAdicionar.showModal();
    document.getElementById("novo-titulo").focus();
  }

  function fecharModalAdicionar() {
    modalAdicionar.close();
    filmeEmEdicaoId = null;
    botaoAbrirAdicionar.focus();
  }

  async function tratarEnvioFormAdicionar(evento) {
    evento.preventDefault();
    mensagemAdicionar.textContent = "";

    const generos = Array.from(
      formAdicionar.querySelectorAll('input[name="genero-novo"]:checked')
    ).map((el) => el.value);

    const status = formAdicionar.querySelector('input[name="status-novo"]:checked').value;

    const dados = {
      titulo: document.getElementById("novo-titulo").value.trim(),
      ano: document.getElementById("novo-ano").value || null,
      diretor: document.getElementById("novo-diretor").value.trim(),
      duracao: document.getElementById("novo-duracao").value || null,
      nota: status === "assistido" ? document.getElementById("novo-nota").value : 0,
      status,
      sinopse: document.getElementById("novo-sinopse").value.trim(),
      poster_url: document.getElementById("novo-poster").value.trim() || null,
      tmdb_id: document.getElementById("novo-tmdb-id").value || null,
      generos,
    };

    try {
      if (filmeEmEdicaoId) {
        await apiFetch(`/filmes/${filmeEmEdicaoId}`, { method: "PUT", corpo: dados });
      } else {
        await apiFetch("/filmes", { method: "POST", corpo: dados });
      }
      fecharModalAdicionar();
      await carregarERenderizarFilmes();
      carregarRecomendacoes();
    } catch (erro) {
      const primeiroErroDeCampo = Object.values(erro.campos || {})[0];
      mensagemAdicionar.textContent = primeiroErroDeCampo || erro.message;
      mensagemAdicionar.className = "mensagem-form mensagem-form--erro";
    }
  }

  // =========================================================
  // Busca no TMDB (pôster, sinopse, ano e gêneros)
  // =========================================================

  function preencherFormularioComFilme(item) {
    document.getElementById("novo-titulo").value = item.titulo ?? "";
    document.getElementById("novo-ano").value = item.ano ?? "";
    if (item.sinopse) {
      document.getElementById("novo-sinopse").value = item.sinopse;
    }
    document.getElementById("novo-poster").value = item.poster_url ?? "";
    document.getElementById("novo-tmdb-id").value = item.tmdb_id ?? "";

    (item.generos || []).forEach((chave) => {
      const checkbox = document.getElementById(`add-genero-${chave}`);
      if (checkbox) checkbox.checked = true;
    });
  }

  async function buscarNoTmdb() {
    const termo = campoBuscaTmdb.value.trim();
    mensagemTmdb.textContent = "";
    mensagemTmdb.className = "mensagem-form";
    resultadosTmdb.innerHTML = "";
    resultadosTmdb.hidden = true;

    if (termo.length < 2) {
      mensagemTmdb.textContent = "Digite pelo menos 2 caracteres.";
      return;
    }

    botaoBuscarTmdb.disabled = true;
    try {
      const itens = await apiFetch(`/tmdb/buscar?q=${encodeURIComponent(termo)}`);

      if (itens.length === 0) {
        mensagemTmdb.textContent = "Nenhum filme encontrado. Você pode preencher manualmente.";
        return;
      }

      itens.forEach((item) => {
        const li = document.createElement("li");
        const botao = document.createElement("button");
        botao.type = "button";
        botao.className = "resultado-tmdb";

        if (item.poster_url) {
          const img = document.createElement("img");
          img.alt = "";
          img.src = item.poster_url;
          img.referrerPolicy = "no-referrer";
          botao.appendChild(img);
        } else {
          const vazio = document.createElement("span");
          vazio.className = "resultado-tmdb__sem-poster";
          botao.appendChild(vazio);
        }

        const texto = document.createElement("span");
        texto.textContent = item.ano ? `${item.titulo} (${item.ano})` : item.titulo;
        botao.appendChild(texto);

        botao.addEventListener("click", () => {
          preencherFormularioComFilme(item);
          resultadosTmdb.hidden = true;
          mensagemTmdb.textContent = "Dados preenchidos. Confira e escolha o status.";
        });

        li.appendChild(botao);
        resultadosTmdb.appendChild(li);
      });
      resultadosTmdb.hidden = false;
    } catch (erro) {
      mensagemTmdb.textContent = erro.message;
      mensagemTmdb.className = "mensagem-form mensagem-form--erro";
    } finally {
      botaoBuscarTmdb.disabled = false;
    }
  }

  // =========================================================
  // Recomendações
  // =========================================================

  async function carregarRecomendacoes() {
    try {
      const dados = await apiFetch("/recomendacoes");
      renderizarRecomendacoes(dados.itens || []);
    } catch (erro) {
      secaoRecomendacoes.hidden = true;
      console.error("Recomendações indisponíveis:", erro);
    }
  }

  function renderizarRecomendacoes(itens) {
    listaRecomendacoes.innerHTML = "";

    if (itens.length === 0) {
      secaoRecomendacoes.hidden = true;
      return;
    }

    const fragmento = document.createDocumentFragment();

    itens.forEach((item) => {
      const clone = templateRecomendacao.content.cloneNode(true);

      aplicarPoster(clone.querySelector(".card-filme__poster"), item.poster_url, item.titulo);
      clone.querySelector(".card-filme__titulo").textContent = item.titulo;
      clone.querySelector(".card-filme__meta").textContent = item.ano ? String(item.ano) : "";
      clone.querySelector(".card-filme__motivo").textContent = item.motivo || "";

      const botao = clone.querySelector(".card-filme__botao");
      botao.setAttribute("aria-label", `Adicionar ${item.titulo} à minha lista`);
      botao.addEventListener("click", () => abrirModalAdicionar(null, item));

      fragmento.appendChild(clone);
    });

    listaRecomendacoes.appendChild(fragmento);
    secaoRecomendacoes.hidden = false;
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
