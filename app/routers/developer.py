from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.schemas import DaftarDeveloperRequest
from app.security import user_saat_ini

router = APIRouter(prefix="/api/developer", tags=["Developer"])


@router.post("/daftar", status_code=201)
def daftar_developer(body: DaftarDeveloperRequest, user=Depends(user_saat_ini), db=Depends(get_db)):
    # satu akun, dua pintu: yang login sudah terbukti lewat token, tidak perlu password lagi
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_daftar_developer(%s, %s, %s)",
                (user["id_user"], body.nama_developer, body.deskripsi),
            )
            hasil = cursor.fetchone()
        return {
            "message": "Akun berhasil didaftarkan sebagai developer",
            "id_developer": hasil["id_developer"],
        }
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1062:   # dua permintaan daftar masuk bersamaan
            raise HTTPException(status_code=400, detail="Akun ini sudah terdaftar sebagai developer")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


@router.get("/saya/game")
def lihat_game_developer(
    user=Depends(user_saat_ini),
    db=Depends(get_db),
):
    try:
        with db.cursor() as cursor:
            cursor.execute("CALL proc_lihat_game_developer(%s)", (user["id_user"],))
            hasil = cursor.fetchall()
        return hasil
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")