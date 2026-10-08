# Digital Game Store

## Setup database

Jalankan file di folder `db/` sebagai `root`, dengan urutan ini:

1. `create_table.sql`
2. `functions.sql`
3. `procedures.sql`
4. `triggers.sql`
5. `view.sql`
6. `index.sql`
7. `privilege.sql`
8. `seeders.sql`

## Setup backend

1. Salin `.env.example` menjadi `.env`, lalu isi: `DB_USER=akun_backend`, `DB_PASSWORD` (dari `privilege.sql`),
   dan `JWT_RAHASIA` (minimal 32 karakter, buat dengan
   `python -c "import secrets; print(secrets.token_hex(32))"`). Jangan di-commit.
2. `python -m venv venv` lalu aktifkan (`venv\Scripts\activate` di Windows).
3. `pip install -r requirements.txt`
4. `uvicorn app.main:app --reload`
5. Buka `http://127.0.0.1:8000/docs`. Untuk endpoint yang butuh login: panggil `POST /api/auth/login`,
   salin `access_token`, klik **Authorize**, lalu tempel tokennya.

## Endpoint

"Login: ya" = wajib header `Authorization: Bearer <token>`. Identitas (id user / id developer) selalu
diambil dari token, bukan dari body atau path.

| Method | Path | Login | Procedure |
|---|---|---|---|
| POST | /api/auth/register | tidak | proc_tambah_user |
| POST | /api/auth/login | tidak | proc_ambil_login_user |
| POST | /api/auth/hapus-akun | ya | proc_ambil_login_user lalu proc_hapus_user |
| GET | /api/game | tidak | proc_lihat_katalog_game |
| GET | /api/genre | tidak | proc_lihat_genre |
| GET | /api/bank | tidak | proc_lihat_bank |
| GET | /api/rating | tidak | proc_lihat_semua_rating |
| GET | /api/rating/{id_game} | tidak | proc_lihat_rating_game |
| POST | /api/keranjang | ya | proc_tambah_keranjang |
| GET | /api/keranjang | ya | proc_lihat_keranjang |
| POST | /api/transaksi/checkout | ya | proc_checkout |
| GET | /api/transaksi/riwayat | ya | proc_lihat_riwayat_pembelian |
| POST | /api/rating | ya | proc_beri_rating |
| GET | /api/log | ya | proc_lihat_log_aktivitas |
| POST | /api/developer/daftar | ya | proc_daftar_developer |
| POST | /api/game | ya | proc_tambah_game |
| DELETE | /api/game/{id_game} | ya | proc_hapus_game |
| GET | /api/developer/saya/game | ya | proc_lihat_game_developer |