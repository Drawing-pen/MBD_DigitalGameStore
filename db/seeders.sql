USE toko_game_digital;

DELIMITER $$

CREATE PROCEDURE proc_insert_genre(IN p_nama_genre VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    INSERT INTO genre (nama_genre) VALUES (p_nama_genre);
    COMMIT;
END$$

CREATE PROCEDURE proc_insert_bank(
    IN p_nama_bank VARCHAR(100),
    IN p_kode_bank VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    INSERT INTO bank (nama_bank, kode_bank) VALUES (p_nama_bank, p_kode_bank);
    COMMIT;
END$$

DELIMITER ;

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

CALL proc_register_user('budi123',    'budi@email.com',    '$2b$12$5W2jGsU2WGUC.iyufNJwxORLq/Cfc5nza4GKdcRGGVQ4agiGJ1D9G', '081234567801', 'Budi Santoso');
CALL proc_register_user('siti_n',     'siti@email.com',    '$2b$12$5W2jGsU2WGUC.iyufNJwxORLq/Cfc5nza4GKdcRGGVQ4agiGJ1D9G', '081234567802', 'Siti Nurhaliza');
CALL proc_register_user('andi_p',     'andi@email.com',    '$2b$12$5W2jGsU2WGUC.iyufNJwxORLq/Cfc5nza4GKdcRGGVQ4agiGJ1D9G', '081234567803', 'Andi Pratama');
CALL proc_register_user('riot_games', 'dev@riotgames.com', '$2b$12$5W2jGsU2WGUC.iyufNJwxORLq/Cfc5nza4GKdcRGGVQ4agiGJ1D9G', '081234567804', 'Riot Games');
CALL proc_register_user('toby_fox',   'dev@tobyfox.com',   '$2b$12$5W2jGsU2WGUC.iyufNJwxORLq/Cfc5nza4GKdcRGGVQ4agiGJ1D9G', '081234567805', 'Toby Fox');

-- developer
CALL proc_register_developer(4, 'Riot Games', 'Studio game kompetitif');
CALL proc_register_developer(5, 'Toby Fox',   'Developer indie RPG');
CALL proc_register_developer(3, 'Andi Games', 'Pembeli yang juga menerbitkan game');

-- game
CALL proc_publish_game('Valorant',   'FPS taktis 5v5',               '{"ram": "4GB", "gpu": "GT 730"}',     0,      '2020-06-02', 4, 1);
CALL proc_publish_game('Deltarune',  'RPG dengan pilihan cerita',    '{"ram": "2GB", "gpu": "integrated"}', 70000,  '2018-10-31', 5, 2);
CALL proc_publish_game('Undertale',  'RPG indie tanpa harus membunuh','{"ram": "2GB", "gpu": "integrated"}', 50000,  '2015-09-15', 5, 3);
CALL proc_publish_game('Hollow Knight','Metroidvania 2D',              '{"ram": "4GB", "gpu": "GTX 650"}',    100000, '2017-02-24', 5, 1);