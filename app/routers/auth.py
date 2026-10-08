from fastapi import APIRouter, Depends, HTTPException
import pymysql
from app.database import get_db
from app.schemas import RegisterRequest, LoginRequest, HapusAkunRequest
from app.security import buat_token, user_saat_ini, hash_password, verifikasi_password

router = APIRouter(prefix="/api/auth", tags=["Akun"])


def _verifikasi(db, identitas: str, password: str) -> dict:
    try:
        with db.cursor() as cursor:
            cursor.execute("CALL proc_ambil_login_user(%s)", (identitas,))
            user = cursor.fetchone()
            while cursor.nextset():
                pass
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=401, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")

    if not user or not verifikasi_password(password, user["password"]):
        raise HTTPException(status_code=401, detail="Username/email atau password salah")

    return user


@router.post("/register", status_code=201)
def register(body: RegisterRequest, db=Depends(get_db)):
    hashed_pwd = hash_password(body.password)

    try:
        with db.cursor() as cursor:
            cursor.execute(
                "CALL proc_tambah_user(%s, %s, %s, %s, %s)",
                (body.username, body.email, hashed_pwd, body.no_hp, body.nama_asli),
            )
            hasil = cursor.fetchone()
        return {"message": "Akun berhasil dibuat", "id_user": hasil["id_user"]}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")
    except pymysql.err.IntegrityError as e:
        if e.args[0] == 1062:
            raise HTTPException(status_code=400, detail="Username atau email ini sudah terdaftar")
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")


def _profil(user: dict) -> dict:
    return {
        "id_user": user["id_user"],
        "username": user["username"],
        "nama_asli": user["nama_asli"],
        "adalah_developer": bool(user["adalah_developer"]),
        "nama_developer": user["nama_developer"],
    }


@router.post("/login")
def login(body: LoginRequest, db=Depends(get_db)):
    user = _verifikasi(db, body.username_atau_email, body.password)
    token, detik = buat_token(user)
    return {
        "message": "Login berhasil",
        "access_token": token,
        "token_type": "bearer",
        "expires_in": detik,
        **_profil(user),
    }

@router.post("/hapus-akun")
def hapus_akun(body: HapusAkunRequest, akun=Depends(user_saat_ini), db=Depends(get_db)):
    user = _verifikasi(db, akun["email"], body.password)
    try:
        with db.cursor() as cursor:
            cursor.execute("CALL proc_hapus_user(%s)", (user["id_user"],))
        return {"message": "Akun berhasil dihapus"}
    except pymysql.err.OperationalError as e:
        if e.args[0] == 1644:
            raise HTTPException(status_code=400, detail=e.args[1])
        raise HTTPException(status_code=500, detail="Terjadi kesalahan, silakan coba lagi nanti")