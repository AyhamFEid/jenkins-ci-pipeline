import pytest
from app.main import app, compute_square

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_hello_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json() == {"message": "Hello, World!"}

def test_healthz_endpoint(client):
    response = client.get("/healthz")
    assert response.status_code == 200

def test_compute_square():
    assert compute_square(4) == 16
    assert compute_square(0) == 0
