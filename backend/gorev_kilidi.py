"""Dağıtık görev kilidi (DB tabanlı kiralama / lease).

Birden fazla web worker'ı veya yanlışlıkla iki worker süreci çalışsa bile zamanlanmış bir görev aynı
anda yalnızca BİR süreçte çalışır → bildirimler çift gitmez.

Kilit alma tek bir atomik UPDATE'tir (SQLite ve PostgreSQL'de aynı davranır):
    UPDATE gorev_kilitleri SET sahip=:ben, bitis=:yeni WHERE ad=:ad AND (bitis IS NULL OR bitis < :simdi)
Etkilenen satır 1 ise kilit bizdedir. Süreç çökerse kilit `sure_sn` sonunda kendiliğinden düşer.
"""
import logging
import os
import socket
import uuid
from collections.abc import Callable
from datetime import datetime, timedelta

from sqlalchemy import text
from sqlalchemy.exc import IntegrityError

import models
from database import SessionLocal

log = logging.getLogger(__name__)
SAHIP = f"{socket.gethostname()}:{os.getpid()}:{uuid.uuid4().hex[:6]}"


def _simdi() -> datetime:
    return datetime.utcnow()


def kilit_al(ad: str, sure_sn: int, sahip: str = SAHIP) -> bool:
    db = SessionLocal()
    try:
        if not db.get(models.GorevKilidi, ad):
            try:
                db.add(models.GorevKilidi(ad=ad))
                db.commit()
            except IntegrityError:
                db.rollback()  # başka süreç aynı anda ekledi
        an = _simdi()
        sonuc = db.execute(
            text("UPDATE gorev_kilitleri SET sahip = :sahip, bitis = :bitis "
                 "WHERE ad = :ad AND (bitis IS NULL OR bitis < :simdi)"),
            {"sahip": sahip, "bitis": (an + timedelta(seconds=sure_sn)).isoformat(), "ad": ad, "simdi": an.isoformat()},
        )
        db.commit()
        return sonuc.rowcount == 1
    finally:
        db.close()


def kilit_birak(ad: str, sahip: str = SAHIP) -> None:
    db = SessionLocal()
    try:
        db.execute(text("UPDATE gorev_kilitleri SET bitis = NULL, sahip = NULL WHERE ad = :ad AND sahip = :sahip"),
                   {"ad": ad, "sahip": sahip})
        db.commit()
    finally:
        db.close()


def kilitli_calistir(ad: str, gorev: Callable[[], object], sure_sn: int = 240, sahip: str = SAHIP):
    """Kilidi alabilirse görevi çalıştırır ve sonucunu döner; alamazsa None (başka süreç çalıştırıyor)."""
    if not kilit_al(ad, sure_sn, sahip):
        log.info("Görev atlandı (başka süreçte çalışıyor): %s", ad)
        return None
    try:
        return gorev()
    finally:
        kilit_birak(ad, sahip)
