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
    WHERE id_user = p_id_user AND id_game = p_id_game;

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
    WHERE id_game = p_id_game;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_nama_game_terisi(p_nama_game VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN TRIM(COALESCE(p_nama_game, '')) <> '';
END$$

CREATE FUNCTION func_cek_harga_game_valid(p_harga DECIMAL(12,2))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_harga IS NOT NULL AND p_harga >= 0 AND p_harga <= 9999999999.99;
END$$

CREATE FUNCTION func_cek_developer_ada(p_id_developer INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM developer
    WHERE id_developer = p_id_developer;

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
    WHERE nama_game = p_nama_game;

    RETURN v_jumlah = 0;
END$$

CREATE FUNCTION func_cek_username_terisi(p_username VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN TRIM(COALESCE(p_username, '')) <> '';
END$$

CREATE FUNCTION func_cek_username_tanpa_at(p_username VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN LOCATE('@', COALESCE(p_username, '')) = 0;
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

CREATE FUNCTION func_cek_nama_asli_terisi(p_nama_asli VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN TRIM(COALESCE(p_nama_asli, '')) <> '';
END$$

CREATE FUNCTION func_cek_no_hp_valid(p_no_hp VARCHAR(20))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN COALESCE(p_no_hp, '') REGEXP '^[+]?[0-9]{8,15}$';
END$$

CREATE FUNCTION func_cek_email_valid(p_email VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN COALESCE(p_email, '') REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$';
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
    WHERE id_user = p_id_user;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_user_punya_transaksi(p_id_user INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM transaksi
    WHERE id_user = p_id_user;

    RETURN v_jumlah > 0;
END$$

CREATE FUNCTION func_cek_nama_developer_terisi(p_nama_developer VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN TRIM(COALESCE(p_nama_developer, '')) <> '';
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
    FROM developerGame
    WHERE id_developer = p_id_developer;

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
    WHERE FIND_IN_SET(id_game, p_daftar_game) > 0;
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
      AND FIND_IN_SET(d.id_game, p_daftar_game) > 0;
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
    WHERE FIND_IN_SET(id_game, p_daftar_game) > 0;
    RETURN v_total;
END$$

CREATE FUNCTION func_game_milik_developer(p_id_developer INT, p_id_game INT)
RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_ada INT;
    SELECT COUNT(*) INTO v_ada FROM developerGame
    WHERE id_developer = p_id_developer AND id_game = p_id_game;
    RETURN v_ada > 0;
END$$

CREATE FUNCTION func_game_pernah_dibeli(p_id_game INT)
RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_ada INT;
    SELECT COUNT(*) INTO v_ada FROM detailTransaksi WHERE id_game = p_id_game;
    RETURN v_ada > 0;
END$$

DELIMITER ;