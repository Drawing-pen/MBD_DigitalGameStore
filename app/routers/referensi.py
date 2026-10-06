from fastapi import APIRouter, Depends
from app.database import get_db

router = APIRouter(prefix="/api", tags=["Referensi"])


@router.get("/genre")
def lihat_genre(db=Depends(get_db)):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_genre()")
        hasil = cursor.fetchall()
    return hasil


@router.get("/bank")
def lihat_bank(db=Depends(get_db)):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_bank()")
        hasil = cursor.fetchall()
    return hasil