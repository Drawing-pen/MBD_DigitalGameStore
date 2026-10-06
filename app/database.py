import pymysql
import pymysql.cursors
import os
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "akun_backend"),
        password=os.getenv("DB_PASSWORD", "pw12345678"),
        database=os.getenv("DB_NAME", "toko_game_digital"),
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )


def get_db():
    connection = get_connection()
    try:
        yield connection
    finally:
        connection.close()
