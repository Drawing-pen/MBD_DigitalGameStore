# Digital Game Store API

Backend FastAPI untuk project Toko Game Digital (MBD). Semua endpoint cuma
memanggil `CALL` ke procedure MySQL, gak ada `SELECT`/`INSERT` langsung dari
kode Python. Backend konek pakai `akun_backend`, user database yang cuma punya
hak `EXECUTE` ke procedure.

## Setup database

Jalankan file di folder `db/` sebagai `root`, dengan urutan ini:

1. `create table.sql`
2. `functions.sql`
3. `procedures.sql`
4. `triggers.sql`
5. `view.sql`
6. `index.sql`
7. `privilege.sql`
8. `seeders.sql`

## Setup backend

1. Cek `.env`: `DB_USER=akun_backend` (dari `privilege.sql`) dan `JWT_RAHASIA` (kunci penanda token,
   minimal 32 karakter; **ganti dengan nilaimu sendiri** dan jangan di-commit). Server menolak
   start kalau `JWT_RAHASIA` kosong atau pendek.
2. `python -m venv venv` lalu aktifkan (`venv\Scripts\activate` di Windows).
3. `pip install -r requirements.txt`
4. `uvicorn app.main:app --reload`
5. Buka `http://127.0.0.1:8000/docs`. Untuk endpoint yang butuh login: panggil `POST /api/auth/login`,
   salin `access_token`, klik tombol **Authorize**, lalu tempel tokennya.

## Endpoint

Kolom "Login": **ya** = wajib kirim header `Authorization: Bearer <token>`. Identitas (id user /
id developer) SELALU diambil dari token, bukan dari body atau path, jadi tidak bisa dipalsukan.

| Method | Path | Login | Memanggil procedure |
|---|---|---|---|
| POST | /api/auth/register | tidak | tambah_user |
| POST | /api/auth/login | tidak | ambil_kredensial_user (+ cek bcrypt di FastAPI), mengembalikan token |
| GET | /api/auth/saya | ya | ambil_kredensial_user (profil akun yang login) |
| POST | /api/auth/hapus-akun | ya | ambil_kredensial_user lalu hapus_user (body: password) |
| GET | /api/game?limit=20&offset=0 | tidak | lihat_katalog_game |
| GET | /api/genre | tidak | lihat_genre (untuk pilihan genre di form publish game) |
| GET | /api/bank | tidak | lihat_bank (untuk pilihan bank di form checkout) |
| GET | /api/rating | tidak | lihat_semua_rating |
| GET | /api/rating/{id_game} | tidak | lihat_rating_game |
| POST | /api/keranjang | ya | tambah_keranjang (body: id_game) |
| GET | /api/keranjang | ya | lihat_keranjang (keranjang milik sendiri) |
| POST | /api/transaksi/checkout | ya | checkout (body: id_bank) |
| GET | /api/transaksi/riwayat?limit=20&offset=0 | ya | lihat_riwayat_pembelian |
| POST | /api/rating | ya | beri_rating (body: id_game, rating, review) |
| GET | /api/log?limit=20&offset=0 | ya | lihat_log_aktivitas |
| POST | /api/developer/daftar | ya | daftar_developer (body: nama_developer, deskripsi) |
| POST | /api/game | ya | tambah_game (developer = akun yang login) |
| GET | /api/developer/saya/game?limit=20&offset=0 | ya | lihat_game_developer |

## Catatan

- Data referensi (genre, bank, developer, user) diisi lewat `seeders.sql`.
- Pagination: endpoint riwayat dan katalog menerima `limit` (1-100, default 20) dan `offset`
  (default 0). Procedure `lihat_log_aktivitas` juga berpagination (belum punya endpoint).
  Database yang sudah terisi: jalankan `db/migrasi_pagination.sql` (sekali, aman diulang).
- Fitur akun: password di-hash pakai bcrypt di FastAPI, database cuma menyimpan hash
  (procedure `tambah_user` menolak password yang bukan hash bcrypt). Login pakai email.
  Akun seeder (budi@email.com, siti@email.com, andi@email.com, dev@riotgames.com, dev@tobyfox.com)
  semuanya berpassword `pw12345`. Riot Games dan Toby Fox sudah menjadi developer; andi@email.com juga
  developer (Andi Games), sebagai contoh satu akun dua pintu.
- Satu akun, dua pintu: developer adalah profil yang menempel pada akun user (id developer = id user), dibuat lewat `POST /api/developer/daftar`. Login hanya satu (`/api/auth/login`), responsnya memuat `access_token`, `adalah_developer`, dan `nama_developer`. Tidak ada verifikasi developer.
- Hapus akun: user yang sudah pernah bertransaksi, atau developer yang masih punya game, tidak bisa dihapus.
- Token (JWT, HS256): berlaku `JWT_MENIT_BERLAKU` menit (default 60). Isinya hanya id user dan email;
  status developer sengaja tidak dimasukkan karena bisa berubah. Token bersifat stateless: tidak ada
  logout di sisi server (FE cukup membuang token), dan token tetap berlaku sampai kedaluwarsa walau
  akunnya sudah dihapus. Tidak ada refresh token.
- Semua procedure (termasuk yang cuma membaca) memakai struktur yang sama: `DECLARE EXIT HANDLER`
  (`ROLLBACK` + `RESIGNAL`), `START TRANSACTION`, dan `COMMIT`. Procedure baca memakai
  `START TRANSACTION READ ONLY` sehingga database sendiri menolak penulisan di dalamnya.
- Database yang sudah terisi: jalankan migrasi BERURUTAN, masing-masing sekali (aman diulang), dan
  jangan menjalankan ulang migrasi lama sesudah yang baru:
  1. `db/migrasi_spesifikasi_json.sql`  2. `db/migrasi_developer_satu_akun.sql`  3. `db/migrasi_pagination.sql`
  4. `db/migrasi_gabung_leaf.sql`  5. `db/migrasi_transaksi_baca.sql`.
  Reset dari nol: cukup 8 file di atas.
- Error dari `SIGNAL` (misal "Game sudah ada di keranjang") otomatis jadi
  HTTP 400 dengan pesan aslinya.