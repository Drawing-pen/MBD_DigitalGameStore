from pydantic import BaseModel, Field
from typing import Optional, Any
from datetime import date
from decimal import Decimal


class TambahKeranjangRequest(BaseModel):
    id_game: int


class CheckoutRequest(BaseModel):
    id_bank: int
    daftar_game: list[int] = Field(min_length=1)   # game yang dipilih (dari keranjang atau beli langsung)


class BeriRatingRequest(BaseModel):
    id_game: int
    rating: int = Field(ge=1, le=5)
    review: Optional[str] = None


class TambahGameRequest(BaseModel):
    nama_game: str
    deskripsi: Optional[str] = None
    spesifikasi: Optional[dict[str, Any]] = None
    harga: Decimal = Field(ge=0, le=Decimal('9999999999.99'), decimal_places=2)
    release_date: Optional[date] = None
    id_genre: Optional[int] = None


class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str = Field(min_length=6, max_length=128)   
    no_hp: str
    nama_asli: str


class LoginRequest(BaseModel):
    username_atau_email: str
    password: str = Field(max_length=128)


class HapusAkunRequest(BaseModel):
    password: str = Field(max_length=128)


class DaftarDeveloperRequest(BaseModel):
    nama_developer: str
    deskripsi: Optional[str] = None