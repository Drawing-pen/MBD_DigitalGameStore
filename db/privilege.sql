CREATE USER IF NOT EXISTS 'akun_backend'@'localhost'
IDENTIFIED BY 'pw12345678';

-- register/login akun
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_tambah_user TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_hapus_user TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_ambil_login_user TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_profil_user TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_daftar_developer TO 'akun_backend'@'localhost';

-- UC1-UC4
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_checkout TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_tambah_keranjang TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_beri_rating TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_tambah_game TO 'akun_backend'@'localhost';

-- proc view
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_keranjang TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_riwayat_pembelian TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_semua_rating TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_rating_game TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_katalog_game TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_log_aktivitas TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_game_developer TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_genre TO 'akun_backend'@'localhost';
GRANT EXECUTE ON PROCEDURE toko_game_digital.proc_lihat_bank TO 'akun_backend'@'localhost';

FLUSH PRIVILEGES;