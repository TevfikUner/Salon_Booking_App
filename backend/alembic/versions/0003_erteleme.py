"""randevu erteleme sayaci

Revision ID: 0003
Revises: 0002
Create Date: 2026-10-12 00:40:00

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0003'
down_revision: Union[str, Sequence[str], None] = '0002'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table('randevular', schema=None) as batch_op:
        batch_op.add_column(sa.Column('erteleme_sayisi', sa.Integer(), server_default='0', nullable=False))


def downgrade() -> None:
    with op.batch_alter_table('randevular', schema=None) as batch_op:
        batch_op.drop_column('erteleme_sayisi')
