from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.security import user_saat_ini
from app.schemas import BeriRatingRequest

router = APIRouter(prefix="/api/rating", tags=["Rating"])


@router.post("", status_code=201)
def beri_rating(body: BeriRatingRequest, user=Depends(user_saat_ini), db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_beri_rating(%s, %s, %s, %s)",
                (
                    user["id_user"],
                    body.id_game,
                    body.rating,
                    body.review,
                ),
            )
        return {"message": "Rating dan ulasan berhasil diberikan"}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1062:
            raise HTTPException(status_code=400, detail="Game ini sudah dinilai")
        elif e.args[0] == 1452:
            raise HTTPException(status_code=400, detail="Game tidak ditemukan")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


@router.get("")
def lihat_semua_rating(db=Depends(get_db)):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_semua_rating()")
        hasil = cursor.fetchall()
    return hasil


@router.get("/{id_game}")
def lihat_rating_game(id_game: int, db=Depends(get_db)):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_rating_game(%s)", (id_game,))
        hasil = cursor.fetchall()
    return hasil