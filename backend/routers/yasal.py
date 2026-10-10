"""Herkese açık yasal sayfalar ve web'den hesap silme talebi (Google Play: gizlilik URL'si + silme bağlantısı).

Metinlerin tek kaynağı `backend/yasal/*.md`. Uygulamadaki kopya `scripts/yasal_senkron.py` ile bunlardan üretilir.
"""
import html
import re
from pathlib import Path

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session

import models
from config import ayarlar
from database import get_db
from koruma import SINIR_HASSAS, limiter
from zaman import simdi

router = APIRouter(prefix="/yasal", tags=["Yasal"], include_in_schema=False)
KLASOR = Path(__file__).resolve().parent.parent / "yasal"
SAYFALAR = {"gizlilik": "gizlilik.md", "kvkk": "kvkk.md", "kullanim": "kullanim.md"}


def yer_tutuculari(metin: str, taban: str) -> str:
    return (metin.replace("{DESTEK_EPOSTA}", ayarlar().destek_eposta)
            .replace("{HESAP_SILME_URL}", f"{taban}/yasal/hesap-silme")
            .replace("{KVKK_URL}", f"{taban}/yasal/kvkk"))


def md_html(md: str) -> str:
    """Bu metinler için yeterli, bağımlılıksız küçük Markdown → HTML dönüştürücü."""
    def satir_ici(s: str) -> str:
        s = html.escape(s)
        s = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)
        return re.sub(r"\[(.+?)\]\((https?://[^)\s]+)\)", r'<a href="\2">\1</a>', s)

    parcalar, liste = [], False
    for satir in md.splitlines():
        if satir.startswith("- "):
            if not liste:
                parcalar.append("<ul>")
                liste = True
            parcalar.append(f"<li>{satir_ici(satir[2:])}</li>")
            continue
        if liste:
            parcalar.append("</ul>")
            liste = False
        if satir.startswith("## "):
            parcalar.append(f"<h2>{satir_ici(satir[3:])}</h2>")
        elif satir.startswith("# "):
            parcalar.append(f"<h1>{satir_ici(satir[2:])}</h1>")
        elif satir.strip():
            parcalar.append(f"<p>{satir_ici(satir)}</p>")
    if liste:
        parcalar.append("</ul>")
    return "\n".join(parcalar)


def sayfa(baslik: str, govde: str) -> HTMLResponse:
    return HTMLResponse(f"""<!doctype html><html lang="tr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(baslik)} · Premium Berber</title>
<style>body{{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;max-width:760px;margin:0 auto;padding:24px 16px;
line-height:1.6;color:#1c1c1c;background:#fff}}h1{{color:#8b6914}}h2{{margin-top:28px;font-size:1.15em}}a{{color:#8b6914}}
nav a{{margin-right:12px}}input,textarea,button{{font:inherit;width:100%;box-sizing:border-box;padding:10px;margin:6px 0 14px;
border:1px solid #ccc;border-radius:8px}}button{{background:#141414;color:#d4a574;border:0;cursor:pointer}}
.not{{background:#f6f1e7;padding:12px;border-radius:8px}}</style></head><body>
<nav><a href="gizlilik">Gizlilik</a><a href="kvkk">KVKK</a><a href="kullanim">Kullanım Koşulları</a>
<a href="hesap-silme">Hesap Silme</a></nav>{govde}</body></html>""")


def _taban(request: Request) -> str:
    return str(request.base_url).rstrip("/")


@router.get("/{ad}", response_class=HTMLResponse)
def yasal_sayfa(ad: str, request: Request):
    if ad == "hesap-silme":
        return hesap_silme_formu()
    dosya = SAYFALAR.get(ad)
    if not dosya:
        return sayfa("Bulunamadı", "<h1>Sayfa bulunamadı</h1>")
    md = yer_tutuculari((KLASOR / dosya).read_text(encoding="utf-8"), _taban(request))
    return sayfa(md.splitlines()[0].lstrip("# "), md_html(md))


def hesap_silme_formu() -> HTMLResponse:
    return sayfa("Hesap Silme", """<h1>Hesap ve Veri Silme</h1>
<p>Premium Berber hesabınızı ve kişisel verilerinizi silmek için:</p>
<ul><li><strong>Uygulamadan (anında):</strong> Profil → Hesap → Hesabımı Sil</li>
<li><strong>Uygulamaya erişemiyorsanız:</strong> aşağıdaki formu doldurun. Talebiniz hesabınıza kayıtlı e-postayla
eşleştirilir ve en geç 30 gün içinde sonuçlandırılır.</li></ul>
<p class="not">Silinenler: ad, soyad, telefon, e-posta, bildirim anahtarı, favoriler, yorum metinleri; gelecekteki
randevular iptal edilir. Salonların muhasebe kayıtları için geçmiş randevular <strong>kimliğinizle ilişkilendirilemeyecek
şekilde</strong> saklanır. Sunucu kayıtları en fazla 30 gün tutulur.</p>
<form method="post" action="hesap-silme">
<label>Hesabınıza kayıtlı e-posta<input type="email" name="email" required maxlength="120"></label>
<label>Açıklama (isteğe bağlı)<textarea name="aciklama" rows="3" maxlength="500"></textarea></label>
<button type="submit">Silme talebi gönder</button></form>""")


@router.post("/hesap-silme", response_class=HTMLResponse)
@limiter.limit(SINIR_HASSAS)
def hesap_silme_talebi(request: Request, email: str = Form(max_length=120), aciklama: str = Form("", max_length=500),
                       db: Session = Depends(get_db)):
    email = email.strip().lower()
    if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email):
        return sayfa("Hesap Silme", "<h1>Geçersiz e-posta</h1><p><a href='hesap-silme'>Geri dön</a></p>")
    db.add(models.HesapSilmeTalebi(email=email, aciklama=aciklama.strip() or None,
                                   olusturma=simdi().isoformat(timespec="seconds")))
    db.commit()
    return sayfa("Talebiniz alındı", f"""<h1>Talebiniz alındı</h1>
<p><strong>{html.escape(email)}</strong> adresine kayıtlı hesabın silinme talebi kaydedildi. En geç 30 gün içinde
sonuçlandırılacak ve bu adrese bilgi verilecektir.</p>""")
