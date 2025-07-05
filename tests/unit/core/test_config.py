from app.core.config import Settings


class TestSettingsDefaults:
    def test_defaults_match_sample(self):
        s = Settings(_env_file=None)  # bypass .env
        assert s.db_name == "fastapi_dev"
        assert s.db_user == "postgres"
        assert s.db_password == "postgres"
        assert s.db_port == 5432
        assert s.sqlalchemy_uri == (
            "postgresql://postgres:postgres@localhost:5432/fastapi_dev"
        )


class TestSettingsOverrides:
    def test_env_overrides_take_precedence(self, monkeypatch):
        monkeypatch.setenv("DB_NAME", "custom")
        monkeypatch.setenv("DB_PASSWORD", "secret")
        s = Settings(_env_file=None)
        assert s.db_name == "custom"
        assert "secret" in s.sqlalchemy_uri

    def test_database_url_short_circuit(self, monkeypatch):
        url = "postgresql://alice:pwd@db:5432/mydb"
        monkeypatch.setenv("DATABASE_URL", url)
        s = Settings(_env_file=None)
        assert s.sqlalchemy_uri == url
