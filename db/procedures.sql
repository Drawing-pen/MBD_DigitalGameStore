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

CREATE PROCEDURE proc_lihat_genre()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT * FROM v_genre
    ORDER BY nama_genre;
    COMMIT;
END$$

CREATE PROCEDURE proc_lihat_bank()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT * FROM v_bank
    ORDER BY nama_bank;
    COMMIT;
END$$

-- UC1: checkout game
CREATE PROCEDURE proc_checkout(
    IN p_id_user INT, IN p_id_bank INT, IN p_daftar_game VARCHAR(1000))   
BEGIN
    DECLARE v_id_transaksi INT;
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_jumlah_diminta INT;
    DECLARE v_kode_bank VARCHAR(10);
    DECLARE v_nomor_va VARCHAR(30);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SET v_jumlah_diminta = func_hitung_game_diminta(p_daftar_game);
    SET v_total = func_hitung_total_pilihan(p_daftar_game);

    IF NOT func_cek_user_ada(p_id_user) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun tidak ditemukan, silakan login lagi';
    ELSEIF v_jumlah_diminta = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pilih minimal satu game untuk dibeli';
    ELSEIF func_hitung_game_valid(p_daftar_game) <> v_jumlah_diminta THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ada game yang tidak ditemukan';
    ELSEIF func_hitung_game_sudah_dimiliki(p_id_user, p_daftar_game) > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ada game yang sudah kamu miliki';
    ELSE
        SELECT kode_bank INTO v_kode_bank
        FROM bank
        WHERE id_bank = p_id_bank;

        SET v_nomor_va = CONCAT(
            v_kode_bank,
            DATE_FORMAT(NOW(), '%y%m%d%H%i%s'),
            LPAD(FLOOR(RAND() * 100), 2, '0')
        );

        INSERT INTO transaksi (id_user, total_pembelian, id_bank, nomor_va)
        VALUES (p_id_user, v_total, p_id_bank, v_nomor_va);

        SET v_id_transaksi = LAST_INSERT_ID();

        INSERT INTO detailTransaksi (id_transaksi, id_game, harga_beli)
        SELECT v_id_transaksi, id_game, harga_game
        FROM game
        WHERE aktif = 1
          AND CONCAT(',', p_daftar_game, ',') LIKE CONCAT('%,', id_game, ',%');

        COMMIT;

        SELECT v_id_transaksi AS id_transaksi,
               v_total AS total_pembelian,
               v_nomor_va AS nomor_va;
    END IF;
END$$

CREATE PROCEDURE proc_lihat_riwayat_pembelian(IN p_id_user INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_riwayat_pembelian
    WHERE id_user = p_id_user
    ORDER BY tanggal_pembelian DESC, id_transaksi DESC, nama_game;

    COMMIT;
END$$

-- UC2: menambahkan game ke keranjang
CREATE PROCEDURE proc_tambah_keranjang(IN p_id_user INT, IN p_id_game INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_cek_user_ada(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun tidak ditemukan, silakan login lagi';
    ELSEIF NOT func_cek_game_ada(p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game tidak ditemukan';
    ELSEIF func_sudah_beli_game(p_id_user, p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game ini sudah dimiliki';
    ELSEIF func_cek_keranjang(p_id_user, p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game ini sudah ada di keranjang';
    ELSE
        START TRANSACTION;

        INSERT INTO keranjang (id_user, id_game)
        VALUES (p_id_user, p_id_game);

        COMMIT;
    END IF;
END$$

CREATE PROCEDURE proc_lihat_keranjang(IN p_id_user INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_isi_keranjang
    WHERE id_user = p_id_user;

    COMMIT;
END$$

-- UC3: memberi rating dan ulasan
CREATE PROCEDURE proc_beri_rating(
    IN p_id_user INT,
    IN p_id_game INT,
    IN p_rating INT,
    IN p_review VARCHAR(1000)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_cek_user_ada(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun tidak ditemukan, silakan login lagi';
    ELSEIF NOT func_cek_game_ada(p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game tidak ditemukan';
    ELSEIF NOT func_sudah_beli_game(p_id_user, p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hanya bisa menilai game yang sudah dibeli';
    ELSEIF func_sudah_kasih_rating(p_id_user, p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game ini sudah dinilai';
    ELSE
        START TRANSACTION;

        INSERT INTO rating (rating, review, id_user, id_game)
        VALUES (p_rating, p_review, p_id_user, p_id_game);

        COMMIT;
    END IF;
END$$

CREATE PROCEDURE proc_lihat_semua_rating()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_rating_game
    ORDER BY rata_rata_rating DESC, id_game;

    COMMIT;
END$$

CREATE PROCEDURE proc_lihat_rating_game(IN p_id_game INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_cek_game_ada(p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game tidak ditemukan';
    ELSE
        START TRANSACTION;

        SELECT id_rating, username, rating, review
        FROM v_ulasan_game
        WHERE id_game = p_id_game
        ORDER BY id_rating DESC;

        COMMIT;
    END IF;
END$$

-- UC4: mempublikasi game
CREATE PROCEDURE proc_tambah_game(
    IN p_nama_game VARCHAR(100),
    IN p_deskripsi VARCHAR(250),
    IN p_spesifikasi TEXT,
    IN p_harga DECIMAL(12,2),
    IN p_release_date DATE,
    IN p_id_developer INT,
    IN p_id_genre INT
)
BEGIN
    DECLARE v_id_game INT;
    DECLARE v_nama_game VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_nama_game = TRIM(COALESCE(p_nama_game, ''));

    IF v_nama_game = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nama game harus diisi';
    ELSEIF p_harga IS NULL OR p_harga < 0 OR p_harga > 9999999999.99 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harga game tidak valid';
    ELSEIF NOT func_cek_developer_ada(p_id_developer) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun ini belum terdaftar sebagai developer';
    ELSEIF NOT func_cek_nama_game_unik(v_nama_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nama game ini sudah dipakai, silakan pilih nama lain';
    ELSE
        START TRANSACTION;

        INSERT INTO game (
            nama_game,
            deskripsi_game,
            spesifikasi_game,
            harga_game,
            release_date
        )
        VALUES (
            v_nama_game,
            p_deskripsi,
            p_spesifikasi,
            p_harga,
            p_release_date
        );

        SET v_id_game = LAST_INSERT_ID();

        INSERT INTO developerGame (id_game, id_developer)
        VALUES (v_id_game, p_id_developer);

        IF p_id_genre IS NOT NULL THEN
            INSERT INTO genreGame (id_genre, id_game)
            VALUES (p_id_genre, v_id_game);
        END IF;

        COMMIT;

        SELECT v_id_game AS id_game;
    END IF;
END$$

CREATE PROCEDURE proc_lihat_katalog_game()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_katalog_game
    ORDER BY id_game;

    COMMIT;
END$$

CREATE PROCEDURE proc_lihat_log_aktivitas(IN p_id_user INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_log_aktivitas
    WHERE id_user = p_id_user
    ORDER BY waktu DESC, id_log DESC;

    COMMIT;
END$$

-- Register akun
CREATE PROCEDURE proc_tambah_user(
    IN p_username VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),   
    IN p_no_hp VARCHAR(20),
    IN p_nama_asli VARCHAR(100)
)
BEGIN
    DECLARE v_id_user INT;
    DECLARE v_username VARCHAR(100);
    DECLARE v_email VARCHAR(100);
    DECLARE v_nama_asli VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_username = TRIM(COALESCE(p_username, ''));
    SET v_email = TRIM(COALESCE(p_email, ''));
    SET v_nama_asli = TRIM(COALESCE(p_nama_asli, ''));

    IF v_username = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username harus diisi';
    ELSEIF v_username LIKE '%@%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username tidak boleh mengandung @';
    ELSEIF NOT func_cek_username_belum_terpakai(v_username) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username ini sudah dipakai';
    ELSEIF v_email NOT LIKE '%_@_%._%' OR v_email LIKE '% %' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Format email tidak valid';
    ELSEIF v_nama_asli = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nama harus diisi';
    ELSEIF COALESCE(p_no_hp, '') NOT REGEXP '^[0-9]{8,15}$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No. HP harus diisi dan hanya berisi angka (8-15 digit)';
    ELSEIF NOT func_cek_email_belum_terpakai(v_email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Email ini sudah terdaftar';
    ELSE
        START TRANSACTION;

        INSERT INTO user (username, email, password, no_hp, nama_asli)
        VALUES (v_username, v_email, p_password, p_no_hp, v_nama_asli);

        SET v_id_user = LAST_INSERT_ID();

        COMMIT;

        SELECT v_id_user AS id_user;
    END IF;
END$$

CREATE PROCEDURE proc_hapus_user(IN p_id_user INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_cek_user_ada(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun tidak ditemukan';
    ELSEIF func_cek_developer_punya_game(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun developer yang masih punya game tidak bisa dihapus';
    ELSE
        START TRANSACTION;

        UPDATE user
        SET aktif = 0
        WHERE id_user = p_id_user;

        COMMIT;
    END IF;
END$$

CREATE PROCEDURE proc_ambil_login_user(
    IN p_identitas VARCHAR(100)   
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_kredensial_user
    WHERE email = p_identitas OR username = p_identitas;

    COMMIT;
END$$

CREATE PROCEDURE proc_lihat_profil_user(IN p_id_user INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT * FROM v_profil_user
    WHERE id_user = p_id_user;

    COMMIT;
END$$

-- Register developer
CREATE PROCEDURE proc_daftar_developer(
    IN p_id_user INT,
    IN p_nama_developer VARCHAR(100),
    IN p_deskripsi VARCHAR(250)
)
BEGIN
    DECLARE v_nama_developer VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_nama_developer = TRIM(COALESCE(p_nama_developer, ''));

    IF v_nama_developer = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nama developer harus diisi';
    ELSEIF NOT func_cek_user_ada(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun tidak ditemukan';
    ELSEIF func_cek_sudah_jadi_developer(p_id_user) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun ini sudah terdaftar sebagai developer';
    ELSE
        START TRANSACTION;

        INSERT INTO developer (id_developer, nama_developer, deskripsi_developer)
        VALUES (p_id_user, v_nama_developer, p_deskripsi);

        COMMIT;

        SELECT p_id_user AS id_developer;
    END IF;
END$$

CREATE PROCEDURE proc_lihat_game_developer(IN p_id_developer INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_cek_developer_ada(p_id_developer) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Akun ini belum terdaftar sebagai developer';
    ELSE
        START TRANSACTION;

        SELECT id_game,
               nama_game,
               harga_game,
               release_date,
               rata_rata_rating,
               total_terjual
        FROM v_game_developer
        WHERE id_developer = p_id_developer
        ORDER BY id_game DESC;

        COMMIT;
    END IF;
END$$

CREATE PROCEDURE proc_hapus_game(IN p_id_developer INT, IN p_id_game INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT func_game_milik_developer(p_id_developer, p_id_game) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Game tidak ditemukan';
    ELSE
        START TRANSACTION;

        UPDATE game
        SET aktif = 0
        WHERE id_game = p_id_game;

        COMMIT;

        SELECT p_id_game AS id_game_dihapus;
    END IF;
END$$

DELIMITER ;