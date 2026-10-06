USE toko_game_digital;

DELIMITER $$

CREATE FUNCTION func_hitung_total_belanja(p_id_user INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(g.harga_game), 0) INTO v_total
    FROM keranjang k
    JOIN game g ON g.id_game = k.id_game
    WHERE k.id_user = p_id_user;

    RETURN v_total;
END$$

CREATE FUNCTION func_hitung_jumlah_item_keranjang(p_id_user INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jumlah INT;

    SELECT COUNT(*) INTO v_jumlah
    FROM keranjang
    WHERE id_user = p_id_user;

    RETURN v_jumlah;
END$$

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
    RETURN p_harga IS NOT NULL AND p_harga >= 0;
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

DELIMITER ;