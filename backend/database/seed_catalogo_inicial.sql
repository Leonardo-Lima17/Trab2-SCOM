-- =========================================================
-- CineArquivo — Seed opcional: importa o catálogo do Trabalho 1
-- (116 filmes de data.js) associado ao usuário admin.
-- Rode DEPOIS de schema.sql:
--   mysql -u root -p cinearquivo < seed_catalogo_inicial.sql
-- =========================================================
USE cinearquivo;

SET @admin_id = (SELECT id FROM usuarios WHERE email = 'admin@cinearquivo.local' LIMIT 1);

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Blade Runner 2049', 2017, 'Denis Villeneuve', 164, 'Um replicante da nova geração descobre um segredo capaz de mergulhar a sociedade em caos e parte à procura de um antigo agente aposentado.', 5, 'assistido', '#3c6e91');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Parasita', 2019, 'Bong Joon-ho', 132, 'Uma família de baixa renda se infiltra, aos poucos, na rotina de uma família rica, até que um evento inesperado muda tudo.', 5, 'assistido', '#4a5d3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Interestelar', 2014, 'Christopher Nolan', 169, 'Um grupo de exploradores usa uma passagem recém-descoberta no espaço-tempo para tentar garantir a sobrevivência da humanidade.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'A Forma da Água', 2017, 'Guillermo del Toro', 123, 'Uma faxineira muda desenvolve uma conexão afetiva incomum com uma criatura anfíbia mantida em um laboratório secreto.', 4, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'romance';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Whiplash: Em Busca da Perfeição', 2014, 'Damien Chazelle', 107, 'Um jovem baterista de jazz é empurrado ao limite por um professor extremamente exigente em busca da excelência.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'musical';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Duna', 2021, 'Denis Villeneuve', 155, 'O herdeiro de uma casa nobre precisa proteger o recurso mais valioso da galáxia em um planeta desértico hostil.', 4, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Oppenheimer', 2023, 'Christopher Nolan', 180, 'A trajetória do físico J. Robert Oppenheimer e seu papel central no desenvolvimento da bomba atômica.', 0, 'quero-assistir', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'historia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Handred: Vidas Passadas', 2023, 'Celine Song', 106, 'Duas pessoas que se conheceram na infância se reencontram décadas depois e reavaliam os caminhos que suas vidas tomaram.', 0, 'quero-assistir', '#5c3a5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'romance';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Andarilho', 2015, 'Alejandro G. Iñárritu', 156, 'Um caçador ferido e abandonado pela própria expedição luta para sobreviver e retornar à civilização.', 4, 'assistido', '#4a4030');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Coringa', 2019, 'Todd Phillips', 122, 'Um comediante fracassado de Gotham City é empurrado, aos poucos, para uma espiral de isolamento e violência.', 5, 'assistido', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Divertida Mente 2', 2024, 'Kelsey Mann', 96, 'As emoções de Riley precisam lidar com a chegada de novos sentimentos durante a fase da adolescência.', 4, 'assistido', '#3a6e6e');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Clube da Luta', 1999, 'David Fincher', 139, 'Um homem insone e insatisfeito com a vida forma, ao lado de um vendedor de sabonetes, um clube clandestino de lutas.', 5, 'assistido', '#2a2a2a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Divertida Mente', 2015, 'Pete Docter', 95, 'As emoções dentro da mente de uma garota de onze anos tentam guiá-la durante uma difícil mudança de cidade.', 4, 'assistido', '#3a5c8a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Cidade de Deus', 2002, 'Fernando Meirelles', 130, 'A trajetória de moradores de uma favela carioca é acompanhada ao longo de duas décadas marcadas pela violência.', 5, 'assistido', '#8a5c2a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'historia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Poor Things', 2023, 'Yorgos Lanthimos', 141, 'Uma jovem mulher trazida de volta à vida por um cientista excêntrico embarca em uma jornada de autodescoberta.', 0, 'quero-assistir', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Green Book', 2018, 'Peter Farrelly', 130, 'Um motorista ítalo-americano é contratado para conduzir um pianista negro em turnê pelo sul dos EUA nos anos 1960.', 4, 'assistido', '#1f5c3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem de Ferro', 2008, 'Jon Favreau', 126, 'Um industrial bilionário constrói uma armadura tecnológica após ser capturado durante um conflito armado.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Incrível Hulk', 2008, 'Louis Leterrier', 112, 'Um cientista foge do exército americano enquanto tenta controlar a fera em que se transforma sob estresse.', 4, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem de Ferro 2', 2010, 'Jon Favreau', 124, 'O herói enfrenta rivais comerciais e um vingador armado enquanto lida com os efeitos colaterais de sua tecnologia.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Thor', 2011, 'Kenneth Branagh', 115, 'Um príncipe asgardiano arrogante é exilado na Terra e precisa provar seu valor para recuperar seus poderes.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Capitão América: O Primeiro Vingador', 2011, 'Joe Johnston', 124, 'Um jovem franzino se transforma em super-soldado para combater uma organização nazista de ciência avançada.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Os Vingadores', 2012, 'Joss Whedon', 143, 'Um grupo de heróis é reunido para deter uma invasão alienígena liderada por um deus renegado.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem de Ferro 3', 2013, 'Shane Black', 130, 'Após um ataque terrorista à sua casa, o herói precisa se reconstruir sem contar com sua armadura.', 4, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Thor: O Mundo Sombrio', 2013, 'Alan Taylor', 112, 'Uma ameaça ancestral força o deus do trovão a se aliar ao irmão adotivo para salvar os nove reinos.', 4, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Capitão América 2: O Soldado Invernal', 2014, 'Anthony e Joe Russo', 136, 'O herói descobre uma conspiração infiltrada dentro da própria organização para a qual trabalha.', 5, 'assistido', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Guardiões da Galáxia', 2014, 'James Gunn', 121, 'Um grupo heterogêneo de fora da lei se une para impedir que um artefato poderoso caia em mãos erradas.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Vingadores: Era de Ultron', 2015, 'Joss Whedon', 141, 'Uma inteligência artificial criada para proteger o mundo se volta contra seus próprios criadores.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem-Formiga', 2015, 'Peyton Reed', 117, 'Um ex-ladrão ganha a capacidade de encolher para executar um golpe que pode salvar o mundo.', 5, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Capitão América: Guerra Civil', 2016, 'Anthony e Joe Russo', 147, 'Uma divergência sobre supervisão governamental divide um grupo de heróis em dois lados opostos.', 5, 'assistido', '#4a5d3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Doutor Estranho', 2016, 'Scott Derrickson', 115, 'Um cirurgião arrogante busca cura para suas mãos feridas e descobre um mundo de magia e dimensões paralelas.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Guardiões da Galáxia Vol. 2', 2017, 'James Gunn', 137, 'O grupo intergaláctico enfrenta revelações sobre a verdadeira origem de um de seus membros.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem-Aranha: De Volta ao Lar', 2017, 'Jon Watts', 133, 'Um jovem herói tenta equilibrar a vida escolar com a responsabilidade de proteger seu bairro.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Thor: Ragnarok', 2017, 'Taika Waititi', 130, 'Preso em um planeta distante, o herói precisa retornar a tempo de impedir a destruição de seu reino.', 5, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Pantera Negra', 2018, 'Ryan Coogler', 134, 'O novo rei de uma nação tecnologicamente avançada precisa defender o trono de um desafiante com um passado ligado à sua família.', 5, 'assistido', '#4a5d3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Vingadores: Guerra Infinita', 2018, 'Anthony e Joe Russo', 149, 'Um titã poderoso busca reunir artefatos cósmicos capazes de eliminar metade de toda a vida no universo.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem-Formiga e a Vespa', 2018, 'Peyton Reed', 118, 'Uma dupla de heróis embarca em uma missão de resgate em uma dimensão subatômica.', 4, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Capitã Marvel', 2019, 'Anna Boden e Ryan Fleck', 124, 'Uma piloto com poderes cósmicos descobre memórias escondidas sobre seu passado na Terra.', 4, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Vingadores: Ultimato', 2019, 'Anthony e Joe Russo', 181, 'Os heróis sobreviventes traçam um plano desesperado para reverter os efeitos de uma perda catastrófica.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem-Aranha: Longe de Casa', 2019, 'Jon Watts', 129, 'Durante uma viagem escolar pela Europa, o jovem herói é recrutado para enfrentar ameaças elementais.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Shang-Chi e a Lenda dos Dez Anéis', 2021, 'Destin Daniel Cretton', 132, 'Um homem é forçado a confrontar o passado que deixou para trás ao ser puxado para a organização secreta do pai.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Cães de Aluguel', 1992, 'Quentin Tarantino', 99, 'Um assalto a joalheria dá errado e os criminosos sobreviventes suspeitam de um infiltrado entre eles.', 0, 'quero-assistir', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Pulp Fiction: Tempo de Violência', 1994, 'Quentin Tarantino', 154, 'Histórias entrelaçadas de capangas, um boxeador e um casal de assaltantes se cruzam em Los Angeles.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Jackie Brown', 1997, 'Quentin Tarantino', 154, 'Uma aeromoça presa contrabandeando dinheiro arma um plano arriscado para escapar de todos os lados envolvidos.', 0, 'quero-assistir', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Kill Bill: Volume 1', 2003, 'Quentin Tarantino', 111, 'Uma ex-assassina desperta de um coma decidida a se vingar de quem tentou matá-la no altar.', 0, 'quero-assistir', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Kill Bill: Volume 2', 2004, 'Quentin Tarantino', 137, 'A protagonista continua sua jornada de vingança até o confronto final com o líder do grupo que a traiu.', 0, 'quero-assistir', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'À Prova de Morte', 2007, 'Quentin Tarantino', 113, 'Um dublê usa seu carro reforçado como arma para perseguir grupos de mulheres em estradas americanas.', 0, 'quero-assistir', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Bastardos Inglórios', 2009, 'Quentin Tarantino', 153, 'Um esquadrão de soldados judeus-americanos trama um plano para acabar com a liderança nazista na França ocupada.', 5, 'assistido', '#4a5d3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Django Livre', 2012, 'Quentin Tarantino', 165, 'Um escravo libertado se une a um caçador de recompensas para resgatar sua esposa de um fazendeiro brutal.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Os Oito Odiados', 2015, 'Quentin Tarantino', 168, 'Oito estranhos presos por uma nevasca em uma cabana isolada escondem segredos perigosos uns dos outros.', 0, 'quero-assistir', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Era Uma Vez em... Hollywood', 2019, 'Quentin Tarantino', 161, 'Um ator em declínio e seu dublê tentam se manter relevantes na Hollywood de 1969.', 5, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: Uma Nova Esperança', 1977, 'George Lucas', 121, 'Um jovem fazendeiro se junta à rebelião para resgatar uma princesa e destruir uma estação de combate colossal.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: O Império Contra-Ataca', 1980, 'Irvin Kershner', 124, 'Os rebeldes são caçados por um império vingativo enquanto o protagonista treina para se tornar um cavaleiro Jedi.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: O Retorno de Jedi', 1983, 'Richard Marquand', 131, 'A batalha final entre a rebelião e o império decide o destino da galáxia.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: A Ameaça Fantasma', 1999, 'George Lucas', 133, 'Dois Jedi protegem uma jovem rainha enquanto um plano político ameaça a estabilidade da república.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: Ataque dos Clones', 2002, 'George Lucas', 142, 'Um exército de clones surge em meio a uma crise separatista que ameaça dividir a galáxia.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: A Vingança dos Sith', 2005, 'George Lucas', 140, 'Um Jedi promissor sucumbe ao lado sombrio da força, selando o destino da república.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: O Despertar da Força', 2015, 'J.J. Abrams', 138, 'Uma nova geração de heróis entra em rota de colisão com os remanescentes do antigo império.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: Os Últimos Jedi', 2017, 'Rian Johnson', 152, 'Uma jovem em busca de treinamento Jedi confronta as crenças de um mestre isolado e desiludido.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Star Wars: A Ascensão Skywalker', 2019, 'J.J. Abrams', 142, 'A resistência enfrenta o retorno de uma ameaça sombria que parecia definitivamente derrotada.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Batman Begins', 2005, 'Christopher Nolan', 140, 'Um herdeiro traumatizado treina no exterior antes de voltar à sua cidade natal para combater o crime.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Batman: O Cavaleiro das Trevas', 2008, 'Christopher Nolan', 152, 'Um vigilante mascarado enfrenta um criminoso caótico que testa seus limites morais.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Batman: O Cavaleiro das Trevas Ressurge', 2012, 'Christopher Nolan', 165, 'Anos após se retirar, o herói é forçado a voltar quando um novo vilão ameaça destruir sua cidade.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem de Aço', 2013, 'Zack Snyder', 143, 'Um alienígena criado na Terra precisa decidir entre esconder seus poderes ou proteger a humanidade.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Liga da Justiça', 2017, 'Zack Snyder', 120, 'Um grupo de heróis se une para enfrentar uma ameaça alienígena após a perda de um aliado importante.', 3, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Mulher-Maravilha', 2017, 'Patty Jenkins', 141, 'Uma guerreira amazona deixa sua ilha isolada para combater as forças por trás da Primeira Guerra Mundial.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'The Batman', 2022, 'Matt Reeves', 176, 'No segundo ano como vigilante, o herói investiga uma série de assassinatos ligados à corrupção da cidade.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e a Pedra Filosofal', 2001, 'Chris Columbus', 152, 'Um garoto órfão descobre ser bruxo e ingressa em uma escola de magia repleta de mistérios.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e a Câmara Secreta', 2002, 'Chris Columbus', 161, 'Uma série de ataques misteriosos na escola de magia reacende uma lenda antiga e perigosa.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e o Prisioneiro de Azkaban', 2004, 'Alfonso Cuarón', 142, 'A fuga de um prisioneiro perigoso traz revelações sobre o passado da família do protagonista.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e o Cálice de Fogo', 2005, 'Mike Newell', 157, 'Um torneio mágico entre escolas coloca o protagonista em perigo mortal sem que ele tenha se inscrito.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e a Ordem da Fênix', 2007, 'David Yates', 138, 'Enquanto o ministério nega o retorno do mal, um grupo de estudantes se prepara secretamente para a resistência.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e o Enigma do Príncipe', 2009, 'David Yates', 153, 'Aulas particulares revelam memórias-chave sobre o passado do maior inimigo do protagonista.', 4, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e as Relíquias da Morte: Parte 1', 2010, 'David Yates', 146, 'Os protagonistas partem em uma jornada perigosa para destruir os fragmentos da alma do vilão.', 4, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Harry Potter e as Relíquias da Morte: Parte 2', 2011, 'David Yates', 130, 'A batalha final pela escola de magia decide o destino de todo o mundo bruxo.', 5, 'assistido', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Senhor dos Anéis: A Sociedade do Anel', 2001, 'Peter Jackson', 178, 'Um hobbit assume a missão de destruir um anel amaldiçoado antes que ele caia nas mãos erradas.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Senhor dos Anéis: As Duas Torres', 2002, 'Peter Jackson', 179, 'A comunidade dividida enfrenta batalhas separadas enquanto o portador do anel se aproxima de seu destino.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Senhor dos Anéis: O Retorno do Rei', 2003, 'Peter Jackson', 201, 'As forças livres da Terra-média se unem para a batalha final contra um exército sombrio.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Hobbit: Uma Jornada Inesperada', 2012, 'Peter Jackson', 169, 'Um hobbit pacato é recrutado por um grupo de anões para recuperar um reino tomado por um dragão.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Hobbit: A Desolação de Smaug', 2013, 'Peter Jackson', 161, 'O grupo se aproxima da montanha solitária e de seu perigoso guardião alado.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Hobbit: A Batalha dos Cinco Exércitos', 2014, 'Peter Jackson', 144, 'A disputa pelo tesouro do reino recuperado desencadeia um conflito entre vários povos da Terra-média.', 0, 'quero-assistir', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Toy Story', 1995, 'John Lasseter', 81, 'Um cowboy de brinquedo enfrenta a chegada de um novo brinquedo espacial que ameaça seu lugar de favorito.', 0, 'assistido', '#3a6e6e');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Procurando Nemo', 2003, 'Andrew Stanton', 100, 'Um peixe-palhaço superprotetor atravessa o oceano em busca do filho capturado por mergulhadores.', 0, 'assistido', '#3a6e6e');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Wall-E', 2008, 'Andrew Stanton', 98, 'Um robô solitário encarregado de limpar a Terra abandonada encontra uma nova sonda que muda sua rotina.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Up: Altas Aventuras', 2009, 'Pete Docter', 96, 'Um viúvo idoso amarra milhares de balões à sua casa para realizar um sonho antigo ao lado da esposa.', 0, 'assistido', '#3a6e6e');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Coco', 2017, 'Lee Unkrich', 105, 'Um garoto apaixonado por música é transportado para a terra dos mortos em busca de suas origens.', 0, 'quero-assistir', '#255c5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Zootopia: Essa Cidade É o Bicho', 2016, 'Byron Howard e Rich Moore', 108, 'Uma coelha policial se une a uma raposa trapaceira para resolver um caso que ameaça a convivência entre espécies.', 0, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Como Treinar o Seu Dragão', 2010, 'Dean DeBlois e Chris Sanders', 98, 'Um jovem viking forma uma amizade improvável com um dragão que deveria caçar.', 0, 'assistido', '#3a6e6e');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Shrek', 2001, 'Andrew Adamson e Vicky Jenson', 90, 'Um ogro solitário aceita resgatar uma princesa para recuperar a paz de seu pântano.', 0, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'animacao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Matrix', 1999, 'Lana e Lilly Wachowski', 136, 'Um programador descobre que a realidade em que vive é uma simulação controlada por máquinas.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Matrix Reloaded', 2003, 'Lana e Lilly Wachowski', 138, 'A resistência humana se prepara para um ataque massivo das máquinas à última cidade livre.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Terminator 2: O Julgamento Final', 1991, 'James Cameron', 137, 'Um robô reprogramado protege um garoto que será fundamental no futuro contra máquinas hostis.', 0, 'quero-assistir', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Alien, o Oitavo Passageiro', 1979, 'Ridley Scott', 117, 'A tripulação de uma nave de carga é caçada por uma criatura extraterrestre letal a bordo.', 0, 'quero-assistir', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Jurassic Park', 1993, 'Steven Spielberg', 127, 'Um parque temático com dinossauros clonados sai do controle durante uma visita de especialistas.', 4, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'De Volta para o Futuro', 1985, 'Robert Zemeckis', 116, 'Um adolescente é acidentalmente enviado ao passado e precisa garantir que seus pais se conheçam.', 5, 'assistido', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Mad Max: Estrada da Fúria', 2015, 'George Miller', 120, 'Em um deserto pós-apocalíptico, uma fugitiva e um sobrevivente se unem contra um tirano local.', 0, 'quero-assistir', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Gladiador', 2000, 'Ridley Scott', 155, 'Um general romano traído é escravizado e se torna gladiador em busca de vingança contra o novo imperador.', 5, 'assistido', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Poderoso Chefão', 1972, 'Francis Ford Coppola', 175, 'O filho mais novo de uma família mafiosa é gradualmente arrastado para os negócios do pai.', 4, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Poderoso Chefão II', 1974, 'Francis Ford Coppola', 202, 'A ascensão do novo chefe da família é intercalada com a história de seu pai décadas antes.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Os Suspeitos', 1995, 'Bryan Singer', 106, 'Um sobrevivente de uma explosão em um cais conta à polícia a história por trás de cinco criminosos reunidos.', 0, 'quero-assistir', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Se7en: Os Sete Crimes Capitais', 1995, 'David Fincher', 127, 'Dois detetives investigam uma série de assassinatos inspirados nos sete pecados capitais.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'De Repente 30', 2004, 'Gary Winick', 97, 'Uma adolescente insatisfeita faz um pedido mágico e acorda treze anos no futuro, já adulta.', 0, 'quero-assistir', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'romance';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Meninas Malvadas', 2004, 'Mark Waters', 97, 'Uma garota recém-chegada a uma nova escola se infiltra no grupo mais popular e temido do colégio.', 0, 'quero-assistir', '#5c3a5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'O Diabo Veste Prada', 2006, 'David Frankel', 109, 'Uma jovem assistente enfrenta as exigências implacáveis da editora-chefe de uma revista de moda.', 0, 'quero-assistir', '#5c5c1f');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'La La Land: Cantando Estações', 2016, 'Damien Chazelle', 128, 'Uma atriz e um pianista de jazz equilibram amor e ambição em Los Angeles.', 0, 'quero-assistir', '#7a3a2a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'musical';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'romance';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Coringa: Delírio a Dois', 2024, 'Todd Phillips', 138, 'Preso e à espera de julgamento, o protagonista desenvolve uma relação intensa com outra paciente da instituição.', 0, 'quero-assistir', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'musical';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Barbie', 2023, 'Greta Gerwig', 114, 'Uma boneca que vive em um mundo perfeito é levada a questionar sua existência ao visitar o mundo real.', 0, 'quero-assistir', '#5c3a5c');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'comedia';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'fantasia';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Duna: Parte Dois', 2024, 'Denis Villeneuve', 166, 'O herdeiro exilado se une aos habitantes do deserto para retomar seu destino e enfrentar seus inimigos.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Homem-Aranha: Sem Volta Para Casa', 2021, 'Jon Watts', 148, 'Um feitiço que dá errado abre portas entre universos e traz consequências inesperadas para o herói.', 5, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Top Gun: Maverick', 2022, 'Joseph Kosinski', 131, 'Um piloto veterano é convocado para treinar uma nova geração para uma missão quase impossível.', 0, 'quero-assistir', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'John Wick', 2014, 'Chad Stahelski', 101, 'Um assassino aposentado retorna ao submundo do crime após um ataque à sua casa.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'John Wick 2', 2017, 'Chad Stahelski', 122, 'Uma dívida de honra do passado obriga o protagonista a voltar à ativa contra sua vontade.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'John Wick 3: Parabellum', 2019, 'Chad Stahelski', 131, 'Com uma recompensa alta pela sua cabeça, o assassino foge por Nova York enquanto busca aliados.', 5, 'assistido', '#3a3a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'crime';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Missão Impossível: Protocolo Fantasma', 2011, 'Brad Bird', 133, 'Um agente é acusado de um atentado e precisa provar sua inocência sem apoio oficial.', 0, 'quero-assistir', '#5c1f3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Velozes e Furiosos 7', 2015, 'James Wan', 137, 'Uma equipe de pilotos enfrenta um mercenário em busca de vingança pelo irmão que perderam.', 4, 'assistido', '#8a6a3a');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'aventura';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'Rocky', 1976, 'John G. Avildsen', 119, 'Um boxeador amador recebe a chance de sua vida ao ser escalado para lutar pelo título mundial.', 0, 'quero-assistir', '#7a2020');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'drama';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'acao';

INSERT INTO filmes (usuario_id, titulo, ano, diretor, duracao, sinopse, nota, status, cor_tema) VALUES (@admin_id, 'A Origem', 2010, 'Christopher Nolan', 148, 'Um especialista em roubar segredos através de sonhos aceita a missão inversa de plantar uma ideia na mente de alguém.', 5, 'assistido', '#1f2d4d');
SET @filme_id = LAST_INSERT_ID();
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'ficcao';
INSERT INTO filme_generos (filme_id, genero_id) SELECT @filme_id, id FROM generos WHERE chave = 'suspense';
