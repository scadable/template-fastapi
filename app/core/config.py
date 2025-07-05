"""
Centralised application settings, loaded from .env via Pydantic.
"""

from functools import lru_cache
from pydantic import BaseSettings, Field, PostgresDsn


class Settings(BaseSettings):
    db_user: str = Field("postgres", env="DB_USER")
    db_password: str = Field("postgres", env="DB_PASSWORD")
    db_name: str = Field("fastapi_dev", env="DB_NAME")
    db_host: str = Field("localhost", env="DB_HOST")
    db_port: int = Field(5432, env="DB_PORT")
    database_url: PostgresDsn | None = Field(None, env="DATABASE_URL")

    @property
    def sqlalchemy_uri(self) -> str:
        """
        Assemble the SQLAlchemy/Postgres URI.

        Priority: explicit DATABASE_URL env var > assemble from parts.
        """
        if self.database_url:
            return str(self.database_url)
        return (
            f"postgresql://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    """Return a cached singleton Settings object."""
    return Settings()
