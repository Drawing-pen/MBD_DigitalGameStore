USE toko_game_digital;

DELIMITER $$

CREATE TRIGGER trg_hapus_item_keranjang
AFTER INSERT ON detailTransaksi
FOR EACH ROW
BEGIN
    DECLARE v_id_user INT;

    SELECT id_user INTO v_id_user
    FROM transaksi
    WHERE id_transaksi = NEW.id_transaksi;

    DELETE FROM keranjang
    WHERE id_user = v_id_user AND id_game = NEW.id_game;
END$$

CREATE TRIGGER trg_log_checkout
AFTER INSERT ON detailTransaksi
FOR EACH ROW
BEGIN
    DECLARE v_id_user INT;

    SELECT id_user INTO v_id_user
    FROM transaksi
    WHERE id_transaksi = NEW.id_transaksi;

    INSERT INTO log_aktivitas (id_user, aktivitas)
    VALUES (v_id_user, CONCAT('Membeli game id ', NEW.id_game));
END$$

CREATE TRIGGER trg_log_tambah_keranjang
AFTER INSERT ON keranjang
FOR EACH ROW
BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas)
    VALUES (NEW.id_user, CONCAT('Menambahkan game id ', NEW.id_game, ' ke keranjang'));
END$$

CREATE TRIGGER trg_log_beri_rating
AFTER INSERT ON rating
FOR EACH ROW
BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas)
    VALUES (NEW.id_user, CONCAT('Memberi rating game id ', NEW.id_game));
END$$

CREATE TRIGGER trg_tambah_jumlah_game_developer
AFTER INSERT ON developerGame
FOR EACH ROW
BEGIN
    UPDATE developer
    SET jumlah_game = jumlah_game + 1
    WHERE id_developer = NEW.id_developer;
END$$

CREATE TRIGGER trg_kurangi_jumlah_game_developer
AFTER DELETE ON developerGame
FOR EACH ROW
BEGIN
    UPDATE developer SET jumlah_game = jumlah_game - 1
    WHERE id_developer = OLD.id_developer;
END$$

DELIMITER ;