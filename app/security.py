import time
import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from app.config import settings
import bcrypt

_bearer = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    pwd_bytes = password.encode("utf-8")[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode("utf-8")


def verifikasi_password(password_mentah: str, password_hash: str) -> bool:
    pwd_bytes = password_mentah.encode("utf-8")[:72]
    hash_bytes = password_hash.encode("utf-8")
    return bcrypt.checkpw(pwd_bytes, hash_bytes)


def buat_token(user: dict) -> tuple[str, int]:
    sekarang = int(time.time())
    detik = settings.jwt_menit_berlaku * 60
    isi = {"sub": str(user["id_user"]), "email": user["email"], "iat": sekarang, "exp": sekarang + detik}
    return jwt.encode(isi, settings.jwt_rahasia, algorithm=settings.jwt_algoritma), detik


def user_saat_ini(kredensial: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> dict:
    if kredensial is None:
        raise HTTPException(
            status_code=401,
            detail="Silakan login terlebih dahulu",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        data = jwt.decode(
            kredensial.credentials,
            settings.jwt_rahasia,
            algorithms=[settings.jwt_algoritma],
            options={"require": ["exp", "sub"]},
        )
        return {"id_user": int(data["sub"]), "email": data["email"]}
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Sesi kamu sudah berakhir, silakan login lagi",
                            headers={"WWW-Authenticate": "Bearer"})
    except (jwt.InvalidTokenError, KeyError, ValueError):
        raise HTTPException(status_code=401, detail="Sesi tidak valid, silakan login lagi",
                            headers={"WWW-Authenticate": "Bearer"})