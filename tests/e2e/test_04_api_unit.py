"""
test_04_api_unit.py — Backend REST API unit tests for Digipay.
Tests all major endpoints using the `requests` library (no Selenium).
"""

import pytest
import requests
from conftest import BACKEND_URL, ADMIN_PHONE


class TestBackendHealth:
    """Basic health/availability tests."""

    def test_root_endpoint_returns_200(self):
        """GET / should return HTTP 200."""
        r = requests.get(f"{BACKEND_URL}/", timeout=30)
        assert r.status_code == 200, \
            f"Root endpoint returned {r.status_code}, expected 200."

    def test_root_returns_running_message(self):
        """GET / response body should contain the running message."""
        r = requests.get(f"{BACKEND_URL}/", timeout=30)
        data = r.json()
        msg = data.get("message", "").lower()
        assert "digipay" in msg or "running" in msg, \
            f"Root endpoint message unexpected: '{data}'"

    def test_backend_responds_under_5s(self):
        """Backend root endpoint should respond within 5 seconds."""
        import time
        start = time.time()
        r = requests.get(f"{BACKEND_URL}/", timeout=10)
        elapsed = time.time() - start
        assert elapsed < 5, f"Backend root took {elapsed:.2f}s — expected < 5s."


class TestAuthEndpoints:
    """Tests for /auth/send-otp and /auth/verify-otp."""

    def test_send_otp_valid_phone_returns_200(self):
        """POST /auth/send-otp with a valid 10-digit phone returns 200."""
        r = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        assert r.status_code == 200, \
            f"send-otp returned {r.status_code}: {r.text}"

    def test_send_otp_returns_otp_in_body(self):
        """POST /auth/send-otp response body includes the OTP field."""
        r = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        data = r.json()
        assert "otp" in data, \
            f"'otp' field missing from send-otp response: {data}"
        assert len(str(data["otp"])) == 6, \
            f"OTP is not 6 digits: '{data['otp']}'"

    def test_send_otp_returns_success_message(self):
        """POST /auth/send-otp response includes a success message."""
        r = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        data = r.json()
        msg = data.get("message", "").lower()
        assert "sent" in msg or "success" in msg, \
            f"send-otp message unexpected: '{data.get('message')}'"

    def test_send_otp_missing_phone_returns_422(self):
        """POST /auth/send-otp without phone_number should return 422."""
        r = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={},
            timeout=30
        )
        assert r.status_code == 422, \
            f"Expected 422 for missing phone, got {r.status_code}"

    def test_verify_otp_correct_returns_200(self):
        """POST /auth/verify-otp with correct OTP returns 200 and token."""
        # Get OTP first
        r1 = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        otp = r1.json()["otp"]
        # Verify
        r2 = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE, "otp_code": otp},
            timeout=30
        )
        assert r2.status_code == 200, \
            f"verify-otp returned {r2.status_code}: {r2.text}"

    def test_verify_otp_returns_access_token(self):
        """POST /auth/verify-otp response includes access_token."""
        r1 = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        otp = r1.json()["otp"]
        r2 = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE, "otp_code": otp},
            timeout=30
        )
        data = r2.json()
        assert "access_token" in data, \
            f"'access_token' missing from verify-otp response: {data}"
        assert len(data["access_token"]) > 10, "access_token appears too short."

    def test_verify_otp_returns_role(self):
        """POST /auth/verify-otp response includes role field."""
        r1 = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        otp = r1.json()["otp"]
        r2 = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE, "otp_code": otp},
            timeout=30
        )
        data = r2.json()
        assert "role" in data, f"'role' missing from verify-otp response: {data}"
        assert data["role"] == "admin", \
            f"Expected role='admin' for 9999999999, got '{data['role']}'"

    def test_verify_otp_wrong_code_returns_400(self):
        """POST /auth/verify-otp with wrong OTP should return 400."""
        r = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE, "otp_code": "000000"},
            timeout=30
        )
        assert r.status_code == 400, \
            f"Wrong OTP expected 400, got {r.status_code}"

    def test_verify_otp_wrong_code_returns_invalid_message(self):
        """POST /auth/verify-otp error body should mention 'Invalid OTP'."""
        r = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE, "otp_code": "000000"},
            timeout=30
        )
        detail = r.json().get("detail", "").lower()
        assert "invalid" in detail or "otp" in detail, \
            f"Error detail for wrong OTP was: '{detail}'"

    def test_verify_otp_missing_fields_returns_422(self):
        """POST /auth/verify-otp without required fields returns 422."""
        r = requests.post(
            f"{BACKEND_URL}/auth/verify-otp",
            json={"phone_number": ADMIN_PHONE},
            timeout=30
        )
        assert r.status_code == 422, \
            f"Expected 422 for missing otp_code, got {r.status_code}"


class TestWalletEndpoints:
    """Tests for /wallet/* endpoints."""

    def test_get_transactions_without_token_returns_401_or_403(self):
        """GET /wallet/transactions without auth token should return 401 or 403."""
        r = requests.get(f"{BACKEND_URL}/wallet/transactions", timeout=30)
        assert r.status_code in (401, 403), \
            f"Expected 401/403 for unauthenticated /wallet/transactions, got {r.status_code}"

    def test_get_analytics_without_token_returns_401_or_403(self):
        """GET /wallet/analytics without auth token should return 401 or 403."""
        r = requests.get(f"{BACKEND_URL}/wallet/analytics", timeout=30)
        assert r.status_code in (401, 403), \
            f"Expected 401/403 for unauthenticated /wallet/analytics, got {r.status_code}"

    def test_get_transactions_with_token_returns_200(self, auth_headers):
        """GET /wallet/transactions with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/wallet/transactions",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"wallet/transactions with auth returned {r.status_code}: {r.text}"

    def test_get_transactions_returns_list(self, auth_headers):
        """GET /wallet/transactions response should be a JSON array."""
        r = requests.get(
            f"{BACKEND_URL}/wallet/transactions",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert isinstance(data, list), \
            f"Expected list from /wallet/transactions, got {type(data)}"

    def test_get_analytics_with_token_returns_200(self, auth_headers):
        """GET /wallet/analytics with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/wallet/analytics",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"wallet/analytics with auth returned {r.status_code}: {r.text}"

    def test_get_analytics_contains_balance(self, auth_headers):
        """GET /wallet/analytics response should contain 'balance' field."""
        r = requests.get(
            f"{BACKEND_URL}/wallet/analytics",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "balance" in data, \
            f"'balance' field missing from analytics response: {list(data.keys())}"

    def test_get_analytics_contains_category_breakdown(self, auth_headers):
        """GET /wallet/analytics response should contain 'category_breakdown'."""
        r = requests.get(
            f"{BACKEND_URL}/wallet/analytics",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "category_breakdown" in data, \
            f"'category_breakdown' missing from analytics: {list(data.keys())}"


class TestAdminEndpoints:
    """Tests for /admin/* endpoints (requires admin role)."""

    def test_admin_dashboard_without_token_returns_401_or_403(self):
        """GET /admin/dashboard without token should return 401 or 403."""
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", timeout=30)
        assert r.status_code in (401, 403), \
            f"Expected 401/403 for unauthenticated /admin/dashboard, got {r.status_code}"

    def test_admin_dashboard_with_token_returns_200(self, auth_headers):
        """GET /admin/dashboard with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/admin/dashboard",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"admin/dashboard returned {r.status_code}: {r.text}"

    def test_admin_dashboard_contains_total_transactions(self, auth_headers):
        """GET /admin/dashboard response includes 'total_transactions' KPI."""
        r = requests.get(
            f"{BACKEND_URL}/admin/dashboard",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "total_transactions" in data, \
            f"'total_transactions' missing from admin dashboard: {list(data.keys())}"

    def test_admin_dashboard_contains_total_users(self, auth_headers):
        """GET /admin/dashboard response includes 'total_users' KPI."""
        r = requests.get(
            f"{BACKEND_URL}/admin/dashboard",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "total_users" in data, \
            f"'total_users' missing from admin dashboard: {list(data.keys())}"

    def test_admin_dashboard_contains_total_merchants(self, auth_headers):
        """GET /admin/dashboard response includes 'total_merchants' KPI."""
        r = requests.get(
            f"{BACKEND_URL}/admin/dashboard",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "total_merchants" in data, \
            f"'total_merchants' missing from admin dashboard: {list(data.keys())}"

    def test_admin_transactions_with_token_returns_200(self, auth_headers):
        """GET /admin/transactions with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/admin/transactions",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"admin/transactions returned {r.status_code}: {r.text}"

    def test_admin_transactions_contains_transactions_array(self, auth_headers):
        """GET /admin/transactions response includes 'transactions' array."""
        r = requests.get(
            f"{BACKEND_URL}/admin/transactions",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "transactions" in data, \
            f"'transactions' key missing from admin/transactions: {list(data.keys())}"
        assert isinstance(data["transactions"], list), \
            "transactions field should be a list."

    def test_admin_merchants_with_token_returns_200(self, auth_headers):
        """GET /admin/merchants with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/admin/merchants",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"admin/merchants returned {r.status_code}: {r.text}"

    def test_admin_merchants_returns_list(self, auth_headers):
        """GET /admin/merchants returns a JSON array."""
        r = requests.get(
            f"{BACKEND_URL}/admin/merchants",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert isinstance(data, list), \
            f"Expected list from /admin/merchants, got {type(data)}"

    def test_admin_analytics_with_token_returns_200(self, auth_headers):
        """GET /admin/analytics with valid admin token returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/admin/analytics",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code == 200, \
            f"admin/analytics returned {r.status_code}: {r.text}"

    def test_admin_analytics_contains_category_distribution(self, auth_headers):
        """GET /admin/analytics response includes category_distribution."""
        r = requests.get(
            f"{BACKEND_URL}/admin/analytics",
            headers=auth_headers,
            timeout=30
        )
        data = r.json()
        assert "category_distribution" in data, \
            f"'category_distribution' missing from admin analytics: {list(data.keys())}"


class TestMerchantEndpoints:
    """Tests for /merchant/* endpoints."""

    def test_nearby_merchants_no_auth_required(self):
        """GET /merchant/nearby (with lat/lng) should be public (no auth needed)."""
        r = requests.get(
            f"{BACKEND_URL}/merchant/nearby",
            params={"latitude": 12.9716, "longitude": 77.5946},
            timeout=30
        )
        # Should return 200 (public endpoint)
        assert r.status_code == 200, \
            f"/merchant/nearby returned {r.status_code}: {r.text}"

    def test_nearby_merchants_returns_list(self):
        """GET /merchant/nearby returns a JSON list."""
        r = requests.get(
            f"{BACKEND_URL}/merchant/nearby",
            params={"latitude": 12.9716, "longitude": 77.5946},
            timeout=30
        )
        data = r.json()
        assert isinstance(data, list), \
            f"Expected list from /merchant/nearby, got {type(data)}"

    def test_recommendations_with_params(self):
        """GET /merchant/recommendations with all required params returns 200."""
        r = requests.get(
            f"{BACKEND_URL}/merchant/recommendations",
            params={
                "latitude": 12.9716,
                "longitude": 77.5946,
                "heading": 45.0,
                "speed": 1.5
            },
            timeout=30
        )
        assert r.status_code == 200, \
            f"/merchant/recommendations returned {r.status_code}: {r.text}"

    def test_merchant_dashboard_without_token_returns_401_or_403(self):
        """GET /merchant/dashboard without token should return 401 or 403."""
        r = requests.get(f"{BACKEND_URL}/merchant/dashboard", timeout=30)
        assert r.status_code in (401, 403), \
            f"Expected 401/403 for unauthenticated /merchant/dashboard, got {r.status_code}"
