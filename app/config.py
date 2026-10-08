import os
from dataclasses import dataclass
from pathlib import Path
from dotenv import load_dotenv

ROOT_DIR = Path(__file__).resolve().parents[1]
load_dotenv(ROOT_DIR / ".env")


def _wajib(nama_var: str) -> str:
    nilai = os.getenv(nama_var)
    if not nilai:
        raise RuntimeError(f"Variabel lingkungan '{nama_var}' wajib diisi di file .env")
    return nilai


@dataclass(frozen=True)
class Settings:
    # Database Config
    db_host: str
    db_port: int
    db_user: str
    db_password: str
    db_name: str

    # JWT Config
    jwt_rahasia: str
    jwt_algoritma: str
    jwt_menit_berlaku: int


def muat_settings() -> Settings:
    # Validasi port
    try:
        db_port = int(os.getenv("DB_PORT", "3306"))
    except ValueError:
        raise RuntimeError("Variabel 'DB_PORT' di .env harus berupa angka")

    try:
        jwt_menit = int(os.getenv("JWT_MENIT_BERLAKU", "60"))
    except ValueError:
        raise RuntimeError("Variabel 'JWT_MENIT_BERLAKU' di .env harus berupa angka")

    jwt_rahasia = _wajib("JWT_RAHASIA")
    if len(jwt_rahasia) < 32:
        raise RuntimeError("JWT_RAHASIA di file .env minimal harus 32 karakter demi keamanan")

    return Settings(
        db_host=os.getenv("DB_HOST", "localhost"),
        db_port=db_port,
        db_user=os.getenv("DB_USER", "root"),
        db_password=os.getenv("DB_PASSWORD", ""),
        db_name=os.getenv("DB_NAME", "toko_game_digital"),
        jwt_rahasia=jwt_rahasia,
        jwt_algoritma="HS256",
        jwt_menit_berlaku=jwt_menit,
    )

# Singleton instance
settings = muat_settings()