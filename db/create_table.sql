CREATE DATABASE IF NOT EXISTS toko_game_digital;
USE toko_game_digital;

CREATE TABLE genre (
    id_genre INT PRIMARY KEY AUTO_INCREMENT,
    nama_genre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE user (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    no_hp VARCHAR(20),
    nama_asli VARCHAR(100)
);

CREATE TABLE developer (
    id_developer        INT PRIMARY KEY,
    nama_developer      VARCHAR(100) NOT NULL,
    deskripsi_developer VARCHAR(250),
    jumlah_game         INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_developer) REFERENCES user(id_user) ON DELETE CASCADE
);

CREATE TABLE bank (
    id_bank INT PRIMARY KEY AUTO_INCREMENT,
    nama_bank VARCHAR(100) NOT NULL,
    kode_bank VARCHAR(10) NOT NULL
);

CREATE TABLE game (
    id_game INT PRIMARY KEY AUTO_INCREMENT,
    nama_game VARCHAR(100) NOT NULL,
    deskripsi_game VARCHAR(250),
    spesifikasi_game JSON,
    harga_game DECIMAL(12,2) NOT NULL,
    release_date DATE,
    FULLTEXT KEY idx_ft_nama_game (nama_game)
);

CREATE TABLE genreGame (
    id_genreGame INT PRIMARY KEY AUTO_INCREMENT,
    id_genre INT NOT NULL,
    id_game INT NOT NULL,
    FOREIGN KEY (id_genre) REFERENCES genre(id_genre) ON DELETE CASCADE,
    FOREIGN KEY (id_game) REFERENCES game(id_game) ON DELETE CASCADE,
    UNIQUE KEY uq_genre_game (id_genre, id_game)
);

CREATE TABLE developerGame (
    id_developerGame INT PRIMARY KEY AUTO_INCREMENT,
    id_game INT NOT NULL,
    id_developer INT NOT NULL,
    FOREIGN KEY (id_game) REFERENCES game(id_game) ON DELETE CASCADE,
    FOREIGN KEY (id_developer) REFERENCES developer(id_developer) ON DELETE CASCADE,
    UNIQUE KEY uq_developer_game (id_developer, id_game)
);

CREATE TABLE keranjang (
    id_keranjang INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT NOT NULL,
    id_game INT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES user(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_game) REFERENCES game(id_game) ON DELETE CASCADE,
    UNIQUE KEY uq_user_game_keranjang (id_user, id_game)
);

CREATE TABLE rating (
    id_rating INT PRIMARY KEY AUTO_INCREMENT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review VARCHAR(1000) NULL,
    id_user INT NOT NULL,
    id_game INT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES user(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_game) REFERENCES game(id_game) ON DELETE CASCADE,
    UNIQUE KEY uq_user_game_rating (id_user, id_game)
);

CREATE TABLE transaksi (
    id_transaksi INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT NOT NULL,
    total_pembelian DECIMAL(12,2) NOT NULL DEFAULT 0,
    tanggal_pembelian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_bank INT NOT NULL,
    nomor_va VARCHAR(30),
    FOREIGN KEY (id_user) REFERENCES user(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_bank) REFERENCES bank(id_bank)
);

CREATE TABLE detailTransaksi (
    id_detailTransaksi INT PRIMARY KEY AUTO_INCREMENT,
    id_transaksi INT NOT NULL,
    id_game INT NOT NULL,
    harga_beli DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi(id_transaksi) ON DELETE CASCADE,
    FOREIGN KEY (id_game) REFERENCES game(id_game)
);

CREATE TABLE log_aktivitas (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT NOT NULL,
    aktivitas VARCHAR(255) NOT NULL,
    waktu DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES user(id_user) ON DELETE CASCADE
);