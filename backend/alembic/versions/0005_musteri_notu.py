"""isletmenin kalici musteri notu

Revision ID: 0005
Revises: 0004
Create Date: 2026-10-12 02:30:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0005'
down_revision: Union[str, Sequence[str], None] = '0004'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'musteri_notlari',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('salon_id', sa.Integer(), nullable=False),
        sa.Column('musteri_id', sa.Integer(), nullable=False),
        sa.Column('metin', sa.Text(), nullable=False),
        sa.Column('guncelleme', sa.String(), nullable=False),
        sa.Column('guncelleyen', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['musteri_id'], ['musteriler.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['salon_id'], ['salonlar.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('salon_id', 'musteri_id', name='uq_musteri_notu'),
    )
    with op.batch_alter_table('musteri_notlari', schema=None) as batch_op:
        batch_op.create_index(batch_op.f('ix_musteri_notlari_musteri_id'), ['musteri_id'], unique=False)


def downgrade() -> None:
    with op.batch_alter_table('musteri_notlari', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_musteri_notlari_musteri_id'))
    op.drop_table('musteri_notlari')
