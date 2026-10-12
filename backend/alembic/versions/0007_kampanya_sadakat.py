"""kampanya, sadakat karti ve randevuda muhurlu indirim

Revision ID: 0007
Revises: 0006
Create Date: 2026-10-12 12:00:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0007'
down_revision: Union[str, Sequence[str], None] = '0006'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'kampanyalar',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('salon_id', sa.Integer(), nullable=False),
        sa.Column('ad', sa.String(), nullable=False),
        sa.Column('yuzde', sa.Integer(), nullable=False),
        sa.Column('gunler', sa.String(), nullable=False),
        sa.Column('bas_saat', sa.String(), nullable=True),
        sa.Column('bit_saat', sa.String(), nullable=True),
        sa.Column('bas_tarih', sa.String(), nullable=True),
        sa.Column('bit_tarih', sa.String(), nullable=True),
        sa.Column('hizmet_idler', sa.String(), nullable=False),
        sa.Column('aktif', sa.Boolean(), nullable=False),
        sa.Column('olusturma', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['salon_id'], ['salonlar.id']),
        sa.PrimaryKeyConstraint('id'),
    )
    with op.batch_alter_table('kampanyalar', schema=None) as batch_op:
        batch_op.create_index(batch_op.f('ix_kampanyalar_salon_id'), ['salon_id'], unique=False)
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.add_column(sa.Column('sadakat_esik', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('sadakat_yuzde', sa.Integer(), nullable=True))
    with op.batch_alter_table('randevular', schema=None) as batch_op:
        batch_op.add_column(sa.Column('liste_fiyati', sa.Float(), nullable=True))
        batch_op.add_column(sa.Column('indirim_tutari', sa.Float(), server_default='0', nullable=False))
        batch_op.add_column(sa.Column('indirim_aciklama', sa.String(), nullable=True))
        batch_op.add_column(sa.Column('kampanya_id', sa.Integer(), nullable=True))
        batch_op.create_foreign_key('fk_randevu_kampanya', 'kampanyalar', ['kampanya_id'], ['id'], ondelete='SET NULL')


def downgrade() -> None:
    with op.batch_alter_table('randevular', schema=None) as batch_op:
        batch_op.drop_constraint('fk_randevu_kampanya', type_='foreignkey')
        batch_op.drop_column('kampanya_id')
        batch_op.drop_column('indirim_aciklama')
        batch_op.drop_column('indirim_tutari')
        batch_op.drop_column('liste_fiyati')
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.drop_column('sadakat_yuzde')
        batch_op.drop_column('sadakat_esik')
    with op.batch_alter_table('kampanyalar', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_kampanyalar_salon_id'))
    op.drop_table('kampanyalar')
