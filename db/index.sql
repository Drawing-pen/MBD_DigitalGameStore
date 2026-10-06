USE toko_game_digital;

CREATE INDEX idx_transaksi_user_tanggal
ON transaksi (id_user, tanggal_pembelian)
USING BTREE;

CREATE INDEX idx_log_aktivitas_user_waktu
ON log_aktivitas (id_user, waktu)
USING BTREE;

CREATE INDEX idx_game_nama
ON game (nama_game)
USING BTREE;