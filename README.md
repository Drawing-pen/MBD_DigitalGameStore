# Digital Game Store


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