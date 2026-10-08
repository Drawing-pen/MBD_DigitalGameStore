from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.security import user_saat_ini
from app.schemas import CheckoutRequest

router = APIRouter(prefix="/api/transaksi", tags=["Transaksi"])


@router.post("/checkout", status_code=201)
def checkout(body: CheckoutRequest, user=Depends(user_saat_ini), db=Depends(get_db)):
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_checkout(%s, %s, %s)",
                (user["id_user"], body.id_bank, ",".join(str(i) for i in sorted(set(body.daftar_game)))),
            )
            hasil = cursor.fetchone()  
        return {"message": "Checkout berhasil", "data": hasil}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1452:
            raise HTTPException(status_code=400, detail="Bank yang dipilih tidak ditemukan")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


@router.get("/riwayat")
def lihat_riwayat_pembelian(
    user=Depends(user_saat_ini),
    db=Depends(get_db),
):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_riwayat_pembelian(%s)", (user["id_user"],))
        hasil = cursor.fetchall()
    return hasil