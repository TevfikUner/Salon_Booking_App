"""salonun en az onceden randevu suresi (dakika)

Revision ID: 0009
Revises: 0008
Create Date: 2026-10-12 16:00:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0009'
down_revision: Union[str, Sequence[str], None] = '0008'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.add_column(sa.Column('min_onceden_dk', sa.Integer(), server_default='0', nullable=False))


def downgrade() -> None:
    with op.batch_alter_table('salonlar', schema=None) as batch_op:
        batch_op.drop_column('min_onceden_dk')
