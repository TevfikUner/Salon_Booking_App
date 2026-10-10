"""Zamanlanmış görev süreci (hatırlatma, otomatik tamamlama + değerlendirme bildirimi, temizlik).

Production'da web servisi SCHEDULER_ENABLED=false ile çalışır; görevleri yalnızca bu süreç yürütür:
    python worker.py
Render'da ayrı bir "worker" servisi olarak tanımlıdır (render.yaml).
"""
import logging
import signal

from apscheduler.schedulers.blocking import BlockingScheduler

from config import ayarlar
from gozlem import loglamayi_kur, sentry_kur
from zamanlayici import gorevleri_ekle

loglamayi_kur()
sentry_kur()
log = logging.getLogger("premium_berber.worker")


def main() -> None:
    zamanlayici = BlockingScheduler(timezone=ayarlar().zaman_dilimi)
    gorevleri_ekle(zamanlayici)

    def dur(*_):
        log.info("Worker durduruluyor.")
        zamanlayici.shutdown(wait=False)

    signal.signal(signal.SIGTERM, dur)
    signal.signal(signal.SIGINT, dur)
    log.info("Worker başladı: %s", ", ".join(j.id for j in zamanlayici.get_jobs()))
    zamanlayici.start()


if __name__ == "__main__":
    main()
