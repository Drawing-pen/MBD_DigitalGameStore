from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.security import user_saat_ini
from app.schemas import TambahKeranjangRequest

router = APIRouter(prefix="/api/keranjang", tags=["Keranjang"])


@router.post("", status_code=201)
def tambah_keranjang(body: TambahKeranjangRequest, user=Depends(user_saat_ini), db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_tambah_keranjang(%s, %s)",
                (user["id_user"], body.id_game),
            )
        return {"message": "Game berhasil ditambahkan ke keranjang"}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1452:
            raise HTTPException(status_code=400, detail="Game tidak ditemukan")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


@router.get("")
def lihat_keranjang(user=Depends(user_saat_ini), db=Depends(get_db)):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_keranjang(%s)", (user["id_user"],))
        hasil = cursor.fetchall()
    return hasil