from fastapi import APIRouter, Depends
from app.database import get_db
from app.security import user_saat_ini

router = APIRouter(prefix="/api/log", tags=["Log"])


@router.get("")
def lihat_log_aktivitas(
    user=Depends(user_saat_ini),
    db=Depends(get_db),
):
    with db.cursor() as cursor:
        cursor.execute("CALL proc_lihat_log_aktivitas(%s)", (user["id_user"],))
        hasil = cursor.fetchall()
    return hasil