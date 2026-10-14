-- =========================================================
-- CineArquivo — Script de criação do banco de dados
-- Trabalho Individual II - SCOM
-- SGBD: MySQL / MariaDB
-- =========================================================

CREATE DATABASE IF NOT EXISTS cinearquivo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cinearquivo;

-- ---------------------------------------------------------
-- Tabela: usuarios
-- ---------------------------------------------------------
DROP TABLE IF EXISTS filme_generos;
DROP TABLE IF EXISTS filmes;
DROP TABLE IF EXISTS generos;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(120)      NOT NULL,
  email         VARCHAR(160)      NOT NULL,
  senha_hash    VARCHAR(255)      NOT NULL,
  papel         ENUM('admin', 'usuario') NOT NULL DEFAULT 'usuario',
  criado_em     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_usuarios_email (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Tabela: generos (catálogo fixo de gêneros)
-- ---------------------------------------------------------
CREATE TABLE generos (
  id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  chave   VARCHAR(40)  NOT NULL,
  nome    VARCHAR(60)  NOT NULL,
  UNIQUE KEY uk_generos_chave (chave)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Tabela: filmes (entidade principal, pertence a um usuário)
-- ---------------------------------------------------------
CREATE TABLE filmes (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id    INT UNSIGNED NOT NULL,
  titulo        VARCHAR(160) NOT NULL,
  ano           SMALLINT UNSIGNED NULL,
  diretor       VARCHAR(120) NOT NULL DEFAULT 'Não informado',
  duracao       SMALLINT UNSIGNED NULL,
  sinopse       TEXT NULL,
  nota          TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status        ENUM('assistido', 'quero-assistir') NOT NULL DEFAULT 'quero-assistir',
  cor_tema      VARCHAR(7) NOT NULL DEFAULT '#333952',
  poster_url    VARCHAR(500) NULL,
  tmdb_id       INT UNSIGNED NULL,
  criado_em     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_filmes_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_filmes_nota CHECK (nota BETWEEN 0 AND 5),
  INDEX idx_filmes_usuario (usuario_id),
  INDEX idx_filmes_status (status),
  INDEX idx_filmes_titulo (titulo),
  INDEX idx_filmes_tmdb (tmdb_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Tabela associativa: filme_generos (N:N)
-- ---------------------------------------------------------
CREATE TABLE filme_generos (
  filme_id  INT UNSIGNED NOT NULL,
  genero_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (filme_id, genero_id),
  CONSTRAINT fk_fg_filme
    FOREIGN KEY (filme_id) REFERENCES filmes(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_fg_genero
    FOREIGN KEY (genero_id) REFERENCES generos(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Seed: gêneros (mesmos usados no Trabalho 1, em data.js)
-- ---------------------------------------------------------
INSERT INTO generos (chave, nome) VALUES
  ('ficcao', 'Ficção científica'),
  ('drama', 'Drama'),
  ('suspense', 'Suspense'),
  ('aventura', 'Aventura'),
  ('romance', 'Romance'),
  ('fantasia', 'Fantasia'),
  ('musical', 'Musical'),
  ('historia', 'História'),
  ('animacao', 'Animação'),
  ('comedia', 'Comédia'),
  ('acao', 'Ação'),
  ('crime', 'Crime');

-- ---------------------------------------------------------
-- Seed: usuário administrador padrão
-- Senha em texto claro: admin123  (troque após o primeiro login)
-- Hash gerado com password_hash('admin123', PASSWORD_BCRYPT)
-- ---------------------------------------------------------
INSERT INTO usuarios (nome, email, senha_hash, papel) VALUES
  ('Administrador', 'admin@cinearquivo.local',
   '$2y$10$2q7t3s9zI0i0m7bQxQeOa.Zt8Vd1uYqQbYQwq0kFhQxG8x0y0Xy1a', 'admin');

-- Observação: a hash acima é apenas um placeholder de exemplo.
-- Rode backend/scripts/gerar_hash.php (incluso) para gerar a hash real
-- de 'admin123' na sua instalação de PHP e substitua o valor antes do uso.
