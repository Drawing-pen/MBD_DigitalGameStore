USE toko_game_digital;

CREATE VIEW v_riwayat_pembelian AS
SELECT
    t.id_transaksi,
    t.id_user,
    u.nama_asli AS nama_user,
    t.tanggal_pembelian,
    t.total_pembelian,
    b.nama_bank,
    t.nomor_va,
    g.nama_game,
    dt.harga_beli
FROM transaksi t
JOIN user u ON u.id_user = t.id_user
JOIN detailTransaksi dt ON dt.id_transaksi = t.id_transaksi
JOIN game g ON g.id_game = dt.id_game
JOIN bank b ON b.id_bank = t.id_bank;

CREATE VIEW v_isi_keranjang AS
SELECT
    k.id_keranjang,
    k.id_user,
    k.id_game,
    u.nama_asli AS nama_user,
    g.nama_game,
    g.harga_game
FROM keranjang k
JOIN user u ON u.id_user = k.id_user
JOIN game g ON g.id_game = k.id_game;

CREATE VIEW v_rating_game AS
SELECT
    g.id_game,
    g.nama_game,
    (
        SELECT ROUND(AVG(r.rating), 2)
        FROM rating r
        WHERE r.id_game = g.id_game
    ) AS rata_rata_rating,
    RANK() OVER (
        ORDER BY (
            SELECT AVG(r.rating)
            FROM rating r
            WHERE r.id_game = g.id_game
        ) DESC
    ) AS peringkat
FROM game g;

CREATE VIEW v_ulasan_game AS
SELECT
    r.id_rating,
    r.id_game,
    g.nama_game,
    u.username,
    r.rating,
    r.review
FROM rating r
JOIN user u ON u.id_user = r.id_user
JOIN game g ON g.id_game = r.id_game;

CREATE VIEW v_katalog_game AS
SELECT
    g.id_game,
    g.nama_game,
    g.deskripsi_game,
    g.spesifikasi_game,
    g.harga_game,
    g.release_date,
    (
        SELECT ROUND(AVG(r.rating), 2)
        FROM rating r
        WHERE r.id_game = g.id_game
    ) AS rata_rata_rating,
    (
        SELECT GROUP_CONCAT(DISTINCT d.nama_developer SEPARATOR ', ')
        FROM developerGame dg
        JOIN developer d ON d.id_developer = dg.id_developer
        WHERE dg.id_game = g.id_game
    ) AS nama_developer,
    (
        SELECT GROUP_CONCAT(DISTINCT gr.nama_genre SEPARATOR ', ')
        FROM genreGame gg
        JOIN genre gr ON gr.id_genre = gg.id_genre
        WHERE gg.id_game = g.id_game
    ) AS genre
FROM game g;

CREATE VIEW v_genre AS
SELECT
    id_genre,
    nama_genre
FROM genre;

CREATE VIEW v_bank AS
SELECT
    id_bank,
    nama_bank
FROM bank;

CREATE VIEW v_log_aktivitas AS
SELECT
    id_log,
    id_user,
    aktivitas,
    waktu
FROM log_aktivitas;

CREATE VIEW v_game_developer AS
SELECT
    dg.id_developer,
    g.id_game,
    g.nama_game,
    g.harga_game,
    g.release_date,
    (
        SELECT ROUND(AVG(r.rating), 2)
        FROM rating r
        WHERE r.id_game = g.id_game
    ) AS rata_rata_rating,
    (
        SELECT COUNT(*)
        FROM detailTransaksi dt
        WHERE dt.id_game = g.id_game
    ) AS total_terjual
FROM game g
JOIN developerGame dg ON dg.id_game = g.id_game;

CREATE VIEW v_kredensial_user AS
SELECT
    u.id_user,
    u.username,
    u.email,
    u.password,
    u.nama_asli,
    EXISTS (
        SELECT 1
        FROM developer d
        WHERE d.id_developer = u.id_user
    ) AS adalah_developer,
    (
        SELECT d.nama_developer
        FROM developer d
        WHERE d.id_developer = u.id_user
    ) AS nama_developer
FROM user u;

CREATE VIEW v_profil_user AS
SELECT u.id_user, u.username, u.email, u.no_hp, u.nama_asli,
  EXISTS (SELECT 1 FROM developer d WHERE d.id_developer = u.id_user) AS adalah_developer
FROM user u;