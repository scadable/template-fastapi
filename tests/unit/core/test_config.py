from app.core.config import Settings, get_settings


class TestConfig:
    def test_defaults_match_sample(self):
        s = Settings(_env_file=None)  # bypass .env
        assert s.db_name == "fastapi_dev"
        assert s.db_user == "postgres"
        assert s.db_password == "postgres"
        assert s.db_port == 5432
        assert s.sqlalchemy_uri == (
            "postgresql://postgres:postgres@localhost:5432/fastapi_dev"
        )

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

    def test_settings_loads_from_custom_env_file(self, tmp_path):
        # Create a temporary env file with custom values
        env_file = tmp_path / "my.env"
        env_file.write_text(
            "DB_NAME=env_loaded_db\n"
            "DB_USER=envuser\n"
            "DB_PASSWORD=envpass\n"
            "DB_HOST=envhost\n"
            "DB_PORT=9999\n"
        )

        s = Settings(_env_file=str(env_file), _env_file_encoding="utf-8")
        assert s.db_name == "env_loaded_db"
        assert s.db_user == "envuser"
        assert s.db_password == "envpass"
        assert s.db_host == "envhost"
        assert s.db_port == 9999

        expected = "postgresql://envuser:envpass@envhost:9999/env_loaded_db"
        assert s.sqlalchemy_uri == expected


class TestGetSettings:
    def test_get_settings_is_singleton(self):
        # Clear the cache to be sure
        get_settings.cache_clear()
        s1 = get_settings()
        s2 = get_settings()
        assert s1 is s2, "get_settings() should return the same object on repeated calls"
