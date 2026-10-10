from sqlalchemy import create_engine, event
from sqlalchemy.orm import declarative_base, sessionmaker

from config import ayarlar

DATABASE_URL = ayarlar().database_url
# Render/Heroku "postgres://" verir; SQLAlchemy 2 "postgresql://" bekler.
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

SQLITE = DATABASE_URL.startswith("sqlite")

if SQLITE:
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False, "timeout": 30})

    @event.listens_for(engine, "connect")
    def _sqlite_ayarlari(dbapi_conn, _):
        dbapi_conn.execute("PRAGMA foreign_keys=ON")
        dbapi_conn.execute("PRAGMA journal_mode=WAL")  # okuyucular yazarı beklemesin
else:
    a = ayarlar()
    engine = create_engine(
        DATABASE_URL,
        pool_size=a.db_pool_size,
        max_overflow=a.db_max_overflow,
        pool_timeout=a.db_pool_timeout,
        pool_recycle=a.db_pool_recycle,
        pool_pre_ping=True,  # kopmuş bağlantıyı (DB yeniden başlatma) sessizce yenile
        connect_args={"connect_timeout": 5, "application_name": "premium-berber"},
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
