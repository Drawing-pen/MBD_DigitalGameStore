USE toko_game_digital;

DELIMITER $$

CREATE FUNCTION func_cek_keranjang(p_id_user INT, p_id_game INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ada INT;

    SELECT COUNT(*) INTO v_ada
    FROM keranjang
    WHERE id_user = p_id_user AND id_game = p_id_game AND aktif = 1;

    RETURN v_ada > 0;
END$$

CREATE FUNCTION func_sudah_beli_game(p_id_user INT, p_id_game INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM detailTransaksi dt
    JOIN transaksi t ON t.id_transaksi = dt.id_transaksi
    WHERE t.id_user = p_id_user AND dt.id_game = p_id_game;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_sudah_kasih_rating(p_id_user INT, p_id_game INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM rating
    WHERE id_user = p_id_user AND id_game = p_id_game;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_game_ada(p_id_game INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM game
    WHERE id_game = p_id_game AND aktif = 1;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_developer_ada(p_id_developer INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM developer d
    JOIN user u ON u.id_user = d.id_developer
    WHERE d.id_developer = p_id_developer AND u.aktif = 1;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_nama_game_unik(p_nama_game VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM game
    WHERE nama_game = p_nama_game AND aktif = 1;

    RETURN v_jumlah = 0;
END$$

CREATE FUNCTION func_cek_username_belum_terpakai(p_username VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM user
    WHERE username = p_username;

    RETURN v_jumlah = 0;
END$$

CREATE FUNCTION func_cek_email_belum_terpakai(p_email VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM user
    WHERE email = p_email;

    RETURN v_jumlah = 0;
END$$

CREATE FUNCTION func_cek_user_ada(p_id_user INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM user
    WHERE id_user = p_id_user AND aktif = 1;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_sudah_jadi_developer(p_id_user INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM developer
    WHERE id_developer = p_id_user;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_developer_punya_game(p_id_developer INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM developerGame dg
    JOIN game g ON g.id_game = dg.id_game
    WHERE dg.id_developer = p_id_developer AND g.aktif = 1;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_hitung_game_diminta(p_daftar_game VARCHAR(1000))
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    IF TRIM(COALESCE(p_daftar_game, '')) = '' THEN
        RETURN 0;
    END IF;
    RETURN LENGTH(p_daftar_game) - LENGTH(REPLACE(p_daftar_game, ',', '')) + 1;
END$$

CREATE FUNCTION func_hitung_game_valid(p_daftar_game VARCHAR(1000))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;
    SELECT COUNT(*) INTO v_jumlah
    FROM game
    WHERE aktif = 1
      AND CONCAT(',', p_daftar_game, ',') LIKE CONCAT('%,', id_game, ',%');
    RETURN v_jumlah;
END$$

CREATE FUNCTION func_hitung_game_sudah_dimiliki(p_id_user INT, p_daftar_game VARCHAR(1000))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;
    SELECT COUNT(DISTINCT d.id_game) INTO v_jumlah
    FROM detailTransaksi d
    JOIN transaksi t ON t.id_transaksi = d.id_transaksi
    WHERE t.id_user = p_id_user
      AND CONCAT(',', p_daftar_game, ',') LIKE CONCAT('%,', d.id_game, ',%');
    RETURN v_jumlah;
END$$

CREATE FUNCTION func_hitung_total_pilihan(p_daftar_game VARCHAR(1000))
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT COALESCE(SUM(harga_game), 0) INTO v_total
    FROM game
    WHERE aktif = 1
      AND CONCAT(',', p_daftar_game, ',') LIKE CONCAT('%,', id_game, ',%');
    RETURN v_total;
END$$

CREATE FUNCTION func_game_milik_developer(p_id_developer INT, p_id_game INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ada INT;

    SELECT COUNT(*) INTO v_ada
    FROM developerGame dg
    JOIN game g ON g.id_game = dg.id_game
    WHERE dg.id_developer = p_id_developer AND dg.id_game = p_id_game AND g.aktif = 1;

    RETURN v_ada > 0;
END$$

DELIMITER ;