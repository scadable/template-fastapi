import sqlalchemy as sa
from sqlalchemy import MetaData

from app.db.base import Base


class TestBaseMetadata:
    def test_base_has_metadata_attr(self):
        # Base.metadata must exist and be a MetaData instance
        assert hasattr(Base, "metadata"), "Base should have a .metadata attribute"
        assert isinstance(Base.metadata, MetaData)


class TestModelRegistration:
    def test_defining_model_registers_table(self):
        # Defining a model subclass dynamically should register the table
        # in Base.metadata.tables under its __tablename__.
        class DummyModel(Base):
            __tablename__ = "dummy_model"
            id = sa.Column(sa.Integer, primary_key=True)

        # Now Base.metadata.tables should include "dummy_model"
        assert "dummy_model" in Base.metadata.tables
        tbl = Base.metadata.tables["dummy_model"]

        # The primary key column should be called "id"
        pk_cols = [c.name for c in tbl.primary_key]
        assert pk_cols == ["id"]
