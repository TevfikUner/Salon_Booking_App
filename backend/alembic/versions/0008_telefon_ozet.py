"""kisisel veri sifreleme: musteri telefon ozeti (HMAC) - sifreli telefonda esitlik aramasi yerine

Revision ID: 0008
Revises: 0007
Create Date: 2026-10-12 15:00:00

Şifreli sütunların veritabanı tipi değişmez (VARCHAR/TEXT); şifreleme uygulama katmanında (veri_sifreleme.py).
Mevcut veriyi şifrelemek ayrı bir adımdır: python araclar.py veri-sifrele
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0008'
down_revision: Union[str, Sequence[str], None] = '0007'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    from veri_sifreleme import coz, telefon_ozeti

    with op.batch_alter_table('musteriler', schema=None) as batch_op:
        batch_op.add_column(sa.Column('telefon_ozet', sa.String(), nullable=True))
        batch_op.create_index(batch_op.f('ix_musteriler_telefon_ozet'), ['telefon_ozet'], unique=False)
    baglanti = op.get_bind()
    satirlar = baglanti.execute(sa.text("SELECT id, telefon FROM musteriler WHERE telefon IS NOT NULL")).fetchall()
    for id_, telefon in satirlar:
        ozet = telefon_ozeti(coz(telefon))
        if ozet:
            baglanti.execute(sa.text("UPDATE musteriler SET telefon_ozet = :o WHERE id = :i"), {"o": ozet, "i": id_})


def downgrade() -> None:
    with op.batch_alter_table('musteriler', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_musteriler_telefon_ozet'))
        batch_op.drop_column('telefon_ozet')
