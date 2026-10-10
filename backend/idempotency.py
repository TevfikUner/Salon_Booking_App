"""İstek tekrarına karşı koruma (Idempotency-Key başlığı).

İstemci her "randevuyu onayla" eylemi için bir anahtar üretir ve tekrar denemelerde aynı anahtarı yollar.
- Anahtar ilk kez görülürse işlem başlamadan ÖNCE ayrılır (boş yanıtla). Böylece aynı anahtarla eşzamanlı
  ikinci istek (çift tıklama, ağ tekrarı) işleme alınmaz → 409 "işleniyor".
- İşlem başarılı olursa yanıt kaydedilir; aynı anahtarla gelen sonraki istekler AYNI yanıtı alır (yeni kayıt yok).
- İşlem hata verirse anahtar silinir; kullanıcı düzeltip tekrar deneyebilir.
"""
import json
from collections.abc import Callable

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

import models
from database import SessionLocal
from zaman import simdi

MAKS_UZUNLUK = 100


def idempotent(anahtar: str | None, kullanici: str, islem: Callable[[], dict]) -> dict:
    if not anahtar:
        return islem()
    anahtar = anahtar.strip()[:MAKS_UZUNLUK]
    tam = f"{kullanici}:{anahtar}"

    # Ayrı oturum: ana işlemin commit/rollback'inden bağımsız olsun
    db: Session = SessionLocal()
    try:
        kayit = db.get(models.IdempotencyAnahtari, tam)
        if kayit:
            if kayit.yanit:
                return json.loads(kayit.yanit)
            raise HTTPException(status_code=409, detail="İsteğiniz zaten işleniyor, lütfen bekleyin.")
        try:
            db.add(models.IdempotencyAnahtari(anahtar=tam, kullanici=kullanici, yanit="",
                                              olusturma=simdi().isoformat(timespec="seconds")))
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=409, detail="İsteğiniz zaten işleniyor, lütfen bekleyin.") from None

        try:
            yanit = islem()
        except BaseException:
            db.query(models.IdempotencyAnahtari).filter_by(anahtar=tam).delete()
            db.commit()
            raise
        db.query(models.IdempotencyAnahtari).filter_by(anahtar=tam).update({"yanit": json.dumps(yanit, ensure_ascii=False)})
        db.commit()
        return yanit
    finally:
        db.close()
