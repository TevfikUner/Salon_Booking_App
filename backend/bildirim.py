"""Push bildirim motoru (FCM). Firebase yapılandırılmamışsa sessizce loglar.

Testler `gonderilenler` listesinden gönderilen bildirimleri doğrulayabilir.
"""
import logging

from firebase_app import firebase_hazir

log = logging.getLogger(__name__)

# Son gönderilen bildirimler (test/teşhis için, en fazla 100 kayıt)
gonderilenler: list[dict] = []


def bildirim_gonder(token: str | None, baslik: str, mesaj: str, veri: dict | None = None) -> bool:
    if not token:
        return False
    kayit = {"token": token, "baslik": baslik, "mesaj": mesaj, "veri": veri or {}}
    gonderilenler.append(kayit)
    del gonderilenler[:-100]
    if not firebase_hazir():
        log.info("[bildirim-devre-disi] %s — %s", baslik, mesaj)
        return False
    from firebase_admin import messaging

    try:
        messaging.send(messaging.Message(
            notification=messaging.Notification(title=baslik, body=mesaj),
            data={k: str(v) for k, v in (veri or {}).items()},
            token=token,
        ))
        return True
    except Exception as e:  # geçersiz/eskimiş token vb.
        log.warning("Bildirim gönderilemedi: %s", e)
        return False
