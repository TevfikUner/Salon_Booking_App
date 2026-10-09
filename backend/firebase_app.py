"""Firebase Admin SDK'yı (bir kez) başlatır.

Kimlik bilgisi sırası: FIREBASE_CREDENTIALS_JSON (env içeriği) → FIREBASE_CREDENTIALS_PATH (dosya).
İkisi de yoksa uygulama çalışır ama push bildirim gönderilmez ve AUTH_MODE=firebase'de token doğrulanamaz.
"""
import json
import logging
import os

import firebase_admin
from firebase_admin import credentials

from config import ayarlar

log = logging.getLogger(__name__)
_hazir: bool | None = None


def firebase_hazir() -> bool:
    global _hazir
    if _hazir is not None:
        return _hazir
    a = ayarlar()
    try:
        if firebase_admin._apps:
            _hazir = True
        elif a.firebase_credentials_json:
            firebase_admin.initialize_app(credentials.Certificate(json.loads(a.firebase_credentials_json)))
            _hazir = True
        else:
            yol = a.firebase_credentials_path
            if not os.path.isabs(yol):
                yol = os.path.join(os.path.dirname(__file__), yol)
            if os.path.exists(yol):
                firebase_admin.initialize_app(credentials.Certificate(yol))
                _hazir = True
            else:
                log.warning("Firebase servis hesabı bulunamadı; push bildirimleri devre dışı.")
                _hazir = False
    except Exception:  # bozuk JSON vb.
        log.exception("Firebase başlatılamadı")
        _hazir = False
    return _hazir
