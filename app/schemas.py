from pydantic import BaseModel, Field
from typing import Optional, Any
from datetime import date


class TambahKeranjangRequest(BaseModel):
    id_game: int


class CheckoutRequest(BaseModel):
    id_bank: int


class BeriRatingRequest(BaseModel):
    id_game: int
    rating: int = Field(ge=1, le=5)
    review: Optional[str] = None


class TambahGameRequest(BaseModel):
    nama_game: str
    deskripsi: Optional[str] = None
    spesifikasi: Optional[dict[str, Any]] = None
    harga: float
    release_date: Optional[date] = None
    id_genre: Optional[int] = None


class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str = Field(min_length=6, max_length=128)   
    no_hp: Optional[str] = None
    nama_asli: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str = Field(max_length=128)


class HapusAkunRequest(BaseModel):
    password: str = Field(max_length=128)


class DaftarDeveloperRequest(BaseModel):
    nama_developer: str
    deskripsi: Optional[str] = None