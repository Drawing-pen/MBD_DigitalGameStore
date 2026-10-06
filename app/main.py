from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from app.routers import keranjang, transaksi, rating, game, auth, developer, log, referensi

app = FastAPI(title="Digital Game Store API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(keranjang.router)
app.include_router(transaksi.router)
app.include_router(rating.router)
app.include_router(game.router)
app.include_router(auth.router)
app.include_router(developer.router)
app.include_router(log.router)
app.include_router(referensi.router)


LABEL = {
    "password": "Password", "email": "Email", "username": "Username", "nama_asli": "Nama", "no_hp": "No. HP",
    "nama_game": "Nama game", "harga": "Harga", "deskripsi": "Deskripsi", "spesifikasi": "Spesifikasi",
    "release_date": "Tanggal rilis", "id_genre": "Genre", "id_game": "Game", "id_bank": "Bank",
    "rating": "Rating", "review": "Ulasan", "nama_developer": "Nama developer",
}


RENTANG = {"rating": (1, 5)}


@app.exception_handler(RequestValidationError)
async def pesan_validasi_ramah(request: Request, exc: RequestValidationError):
    # semua error validasi dijadikan satu bentuk {"detail": "pesan"}, sama seperti error lainnya
    e = exc.errors()[0]
    kolom = str(e["loc"][-1])
    nama = LABEL.get(kolom, kolom)
    ctx = e.get("ctx", {})
    jenis = e["type"]
    if jenis == "missing":
        pesan = f"{nama} harus diisi"
    elif jenis == "string_too_short":
        pesan = f"{nama} terlalu pendek (minimal {ctx.get('min_length')} karakter)"
    elif jenis == "string_too_long":
        pesan = f"{nama} terlalu panjang (maksimal {ctx.get('max_length')} karakter)"
    elif jenis in ("less_than_equal", "greater_than_equal"):
        batas = RENTANG.get(kolom)
        pesan = f"{nama} harus antara {batas[0]} dan {batas[1]}" if batas else f"{nama} tidak valid"
    else:
        pesan = f"{nama} tidak valid"
    return JSONResponse(status_code=422, content={"detail": pesan})


@app.get("/")
def root():
    return {"message": "Digital Game Store API jalan"}