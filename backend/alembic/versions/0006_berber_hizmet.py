"""berbere ozel hizmet: verdigi hizmetler, kendine ozel fiyat ve sure

Revision ID: 0006
Revises: 0005
Create Date: 2026-10-12 10:00:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0006'
down_revision: Union[str, Sequence[str], None] = '0005'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'berber_hizmetleri',
        sa.Column('berber_id', sa.Integer(), nullable=False),
        sa.Column('hizmet_id', sa.Integer(), nullable=False),
        sa.Column('veriyor', sa.Boolean(), nullable=False),
        sa.Column('fiyat', sa.Float(), nullable=True),
        sa.Column('sure', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['berber_id'], ['berberler.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['hizmet_id'], ['hizmetler.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('berber_id', 'hizmet_id'),
    )


def downgrade() -> None:
    op.drop_table('berber_hizmetleri')
