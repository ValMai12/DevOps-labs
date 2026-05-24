import app


def test_alive():
    client = app.app.test_client()

    response = client.get("/health/alive")

    assert response.status_code == 200
    assert response.data.decode() == "OK"


def test_home():
    client = app.app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert b"mywebapp" in response.data
    assert b"GET /notes" in response.data


def test_create_note_without_json():
    client = app.app.test_client()

    response = client.post(
        "/notes",
        data="not json",
        content_type="application/json"
    )

    assert response.status_code == 400


def test_create_note_without_required_fields():
    client = app.app.test_client()

    response = client.post("/notes", json={"title": "Only title"})

    assert response.status_code == 400
    assert response.json["error"] == "title and content are required"


def test_get_missing_note(monkeypatch):
    class FakeCursor:
        def execute(self, query, params):
            pass

        def fetchone(self):
            return None

    class FakeConnection:
        def cursor(self):
            return FakeCursor()

        def close(self):
            pass

    monkeypatch.setattr(app, "get_db_connection", lambda: FakeConnection())

    client = app.app.test_client()

    response = client.get(
        "/notes/999",
        headers={"Accept": "application/json"}
    )

    assert response.status_code == 404
    assert response.json["error"] == "Note not found"
