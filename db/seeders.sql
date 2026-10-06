USE toko_game_digital;

-- genre
CALL proc_insert_genre('Action');
CALL proc_insert_genre('RPG');
CALL proc_insert_genre('Indie');
CALL proc_insert_genre('Horror');
CALL proc_insert_genre('Simulation');

-- bank
CALL proc_insert_bank('BCA',     '014');
CALL proc_insert_bank('Mandiri', '008');
CALL proc_insert_bank('BNI',     '009');
CALL proc_insert_bank('BRI',     '002');

-- user (id 1-3 pembeli, id 4-5 akun studio yang akan menjadi developer)
-- Semua akun di bawah ini memiliki password plain text: pw12345
CALL proc_tambah_user('budi123',    'budi@email.com',    '$2b$12$eA8eN6E51O8R8U7G.7a6I.3qHl43R6Lp46ZfE01L3a02O9/8E.J4u', '081234567801', 'Budi Santoso');
CALL proc_tambah_user('siti_n',     'siti@email.com',    '$2b$12$eA8eN6E51O8R8U7G.7a6I.3qHl43R6Lp46ZfE01L3a02O9/8E.J4u', '081234567802', 'Siti Nurhaliza');
CALL proc_tambah_user('andi_p',     'andi@email.com',    '$2b$12$eA8eN6E51O8R8U7G.7a6I.3qHl43R6Lp46ZfE01L3a02O9/8E.J4u', '081234567803', 'Andi Pratama');
CALL proc_tambah_user('riot_games', 'dev@riotgames.com', '$2b$12$eA8eN6E51O8R8U7G.7a6I.3qHl43R6Lp46ZfE01L3a02O9/8E.J4u', NULL, 'Riot Games');
CALL proc_tambah_user('toby_fox',   'dev@tobyfox.com',   '$2b$12$eA8eN6E51O8R8U7G.7a6I.3qHl43R6Lp46ZfE01L3a02O9/8E.J4u', NULL, 'Toby Fox');

-- developer
CALL proc_daftar_developer(4, 'Riot Games', 'Studio game kompetitif');
CALL proc_daftar_developer(5, 'Toby Fox',   'Developer indie RPG');
CALL proc_daftar_developer(3, 'Andi Games', 'Pembeli yang juga menerbitkan game');

-- game
CALL proc_tambah_game('Valorant',   'FPS taktis 5v5',               '{"ram": "4GB", "gpu": "GT 730"}',     0,      '2020-06-02', 4, 1);
CALL proc_tambah_game('Deltarune',  'RPG dengan pilihan cerita',    '{"ram": "2GB", "gpu": "integrated"}', 70000,  '2018-10-31', 5, 2);
CALL proc_tambah_game('Undertale',  'RPG indie tanpa harus membunuh','{"ram": "2GB", "gpu": "integrated"}', 50000,  '2015-09-15', 5, 3);
CALL proc_tambah_game('Hollow Knight','Metroidvania 2D',              '{"ram": "4GB", "gpu": "GTX 650"}',    100000, '2017-02-24', 5, 1);