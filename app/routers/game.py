import json
from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.security import user_saat_ini
from app.schemas import TambahGameRequest

router = APIRouter(prefix="/api/game", tags=["Game"])


@router.post("", status_code=201)
def tambah_game(body: TambahGameRequest, user=Depends(user_saat_ini), db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_tambah_game(%s, %s, %s, %s, %s, %s, %s)",
                (
                    body.nama_game,
                    body.deskripsi,
                    json.dumps(body.spesifikasi) if body.spesifikasi is not None else None,
                    body.harga,
                    body.release_date,
                    user["id_user"],       
                    body.id_genre,
                ),
            )
            hasil = cursor.fetchone()
        return {"message": "Game berhasil dipublikasikan", "id_game": hasil["id_game"]}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1452:
            raise HTTPException(status_code=400, detail="Genre yang dipilih tidak ditemukan")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


@router.get("")
def lihat_katalog_game(
    db=Depends(get_db),
):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_katalog_game()")
        hasil = cursor.fetchall()
    for game in hasil:
        if game["spesifikasi_game"]:
            game["spesifikasi_game"] = json.loads(game["spesifikasi_game"])
    return hasil

@router.delete("/{id_game}")
def hapus_game(id_game: int, user=Depends(user_saat_ini), db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            cursor.execute("CALL proc_hapus_game(%s, %s)", (user["id_user"], id_game))
        return {"message": "Game berhasil dihapus"}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")