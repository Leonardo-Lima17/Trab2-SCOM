-- =========================================================
-- Migração 001 — pôster e vínculo com o TMDB
-- Use em um banco JÁ EXISTENTE (não apaga nada).
-- Para instalação nova, o schema.sql já inclui estas colunas.
-- =========================================================
USE cinearquivo;

ALTER TABLE filmes
  ADD COLUMN poster_url VARCHAR(500) NULL AFTER cor_tema,
  ADD COLUMN tmdb_id INT UNSIGNED NULL AFTER poster_url,
  ADD INDEX idx_filmes_tmdb (tmdb_id);
