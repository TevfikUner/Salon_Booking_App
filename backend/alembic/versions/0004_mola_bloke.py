"""ogle arasi, berber haftalik izin gunu, saatlik bloke

Revision ID: 0004
Revises: 0003
Create Date: 2026-10-12 01:30:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0004'
down_revision: Union[str, Sequence[str], None] = '0003'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.add_column(sa.Column('mola_baslangic', sa.String(), nullable=True))
        batch_op.add_column(sa.Column('mola_bitis', sa.String(), nullable=True))
    with op.batch_alter_table('berberler', schema=None) as batch_op:
        batch_op.add_column(sa.Column('kapali_gunler', sa.String(), server_default='', nullable=False))
    op.create_table(
        'saat_blokeleri',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('berber_id', sa.Integer(), nullable=False),
        sa.Column('tarih', sa.String(), nullable=False),
        sa.Column('bas_saat', sa.String(), nullable=False),
        sa.Column('bit_saat', sa.String(), nullable=False),
        sa.Column('aciklama', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['berber_id'], ['berberler.id']),
        sa.PrimaryKeyConstraint('id'),
    )
    with op.batch_alter_table('saat_blokeleri', schema=None) as batch_op:
        batch_op.create_index('ix_bloke_berber_tarih', ['berber_id', 'tarih'], unique=False)
        batch_op.create_index(batch_op.f('ix_saat_blokeleri_id'), ['id'], unique=False)


def downgrade() -> None:
    with op.batch_alter_table('saat_blokeleri', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_saat_blokeleri_id'))
        batch_op.drop_index('ix_bloke_berber_tarih')
    op.drop_table('saat_blokeleri')
    with op.batch_alter_table('berberler', schema=None) as batch_op:
        batch_op.drop_column('kapali_gunler')
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.drop_column('mola_bitis')
        batch_op.drop_column('mola_baslangic')
