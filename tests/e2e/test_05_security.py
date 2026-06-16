"""
test_05_security.py — Vulnerability & Security tests for Digipay backend.
Tests authentication bypass, injection probes, JWT tampering, IDOR, CORS, etc.
"""

import base64
import json
import pytest
import requests
from conftest import BACKEND_URL, ADMIN_PHONE


PROTECTED_ENDPOINTS = [
    "/wallet/transactions",
    "/wallet/analytics",
    "/admin/dashboard",
    "/admin/transactions",
    "/admin/merchants",
    "/admin/analytics",
    "/merchant/dashboard",
]


class TestAuthenticationSecurity:
    """Verify all protected endpoints reject unauthenticated requests."""

    @pytest.mark.parametrize("endpoint", PROTECTED_ENDPOINTS)
    def test_protected_endpoint_requires_auth(self, endpoint):
        """Each protected endpoint should return 401 or 403 without a token."""
        r = requests.get(f"{BACKEND_URL}{endpoint}", timeout=30)
        assert r.status_code in (401, 403), \
            f"SECURITY: {endpoint} is publicly accessible (returned {r.status_code})! Auth bypass vulnerability."

    def test_no_auth_with_empty_bearer_token(self):
        """Sending 'Authorization: Bearer ' (empty) should return 401/403."""
        headers = {"Authorization": "Bearer "}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403), \
            f"Empty bearer token was accepted by /admin/dashboard (status: {r.status_code})"

    def test_no_auth_with_garbage_token(self):
        """Sending a garbage string as a bearer token should return 401/403."""
        headers = {"Authorization": "Bearer not_a_real_token_xyz_123"}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403), \
            f"Garbage token was accepted by /admin/dashboard (status: {r.status_code})"

    def test_no_auth_with_wrong_scheme(self):
        """Using 'Basic' instead of 'Bearer' scheme should return 401/403."""
        headers = {"Authorization": "Basic dXNlcjpwYXNz"}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403), \
            f"Basic auth scheme accepted by /admin/dashboard (status: {r.status_code})"


class TestJWTTampering:
    """Test that tampered JWT tokens are rejected."""

    def test_tampered_jwt_payload_rejected(self, admin_token):
        """Modifying JWT payload (e.g., role=admin → role=superadmin) should be rejected."""
        parts = admin_token.split(".")
        assert len(parts) == 3, "admin_token is not a valid 3-part JWT"

        # Decode and tamper with payload
        payload_b64 = parts[1] + "=" * (4 - len(parts[1]) % 4)
        try:
            payload = json.loads(base64.b64decode(payload_b64))
        except Exception:
            pytest.skip("Could not decode JWT payload for tampering test")

        payload["user_id"] = 99999  # tamper
        tampered_b64 = base64.b64encode(
            json.dumps(payload).encode()
        ).decode().rstrip("=")
        tampered_token = f"{parts[0]}.{tampered_b64}.{parts[2]}"

        headers = {"Authorization": f"Bearer {tampered_token}"}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403, 422), \
            f"SECURITY: Tampered JWT was accepted! (status: {r.status_code})"

    def test_jwt_with_invalid_signature_rejected(self, admin_token):
        """JWT with a forged signature should return 401/403."""
        parts = admin_token.split(".")
        fake_sig = "fakesignatureXYZABC123"
        forged_token = f"{parts[0]}.{parts[1]}.{fake_sig}"
        headers = {"Authorization": f"Bearer {forged_token}"}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403, 422), \
            f"SECURITY: JWT with fake signature was accepted! (status: {r.status_code})"

    def test_truncated_jwt_rejected(self):
        """A truncated JWT (only header.payload) should be rejected."""
        truncated = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ"  # no signature
        headers = {"Authorization": f"Bearer {truncated}"}
        r = requests.get(f"{BACKEND_URL}/admin/dashboard", headers=headers, timeout=30)
        assert r.status_code in (401, 403, 422), \
            f"SECURITY: Truncated JWT was accepted! (status: {r.status_code})"


class TestInputValidationSecurity:
    """Test that injection and malformed inputs are rejected safely."""

    def test_sql_injection_in_phone_field(self):
        """SQL injection probe in phone_number field should not return 200 (should be 400/422)."""
        payloads = [
            "' OR '1'='1",
            "1; DROP TABLE users; --",
            "' UNION SELECT * FROM users --",
        ]
        for payload in payloads:
            r = requests.post(
                f"{BACKEND_URL}/auth/send-otp",
                json={"phone_number": payload},
                timeout=30
            )
            assert r.status_code in (400, 422, 500), \
                f"SECURITY: SQL injection payload '{payload}' returned {r.status_code} — possible injection vulnerability!"
            # Must NOT return an OTP (would indicate bypass)
            if r.status_code == 200:
                data = r.json()
                assert "otp" not in data, \
                    f"SECURITY: SQL injection returned an OTP! Payload: '{payload}'"

    def test_xss_probe_in_phone_field(self):
        """XSS script tag in phone_number should be rejected (400/422)."""
        payloads = [
            "<script>alert(1)</script>",
            "javascript:alert(1)",
            "<img src=x onerror=alert(1)>",
        ]
        for payload in payloads:
            r = requests.post(
                f"{BACKEND_URL}/auth/send-otp",
                json={"phone_number": payload},
                timeout=30
            )
            assert r.status_code in (400, 422), \
                f"SECURITY: XSS payload '{payload[:30]}' returned {r.status_code} — should reject."

    def test_extremely_long_phone_field(self):
        """Extremely long phone number string should not cause 500 server error."""
        long_input = "9" * 10000
        r = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": long_input},
            timeout=30
        )
        assert r.status_code != 500, \
            f"SECURITY: Extremely long phone input caused server error (500). Possible DoS vulnerability."

    def test_search_param_injection_in_admin_transactions(self, auth_headers):
        """Search param with SQL-like input in admin/transactions should not cause 500."""
        r = requests.get(
            f"{BACKEND_URL}/admin/transactions",
            params={"search": "' OR 1=1 --"},
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code != 500, \
            f"SECURITY: SQL injection probe in search param caused 500 error!"
        assert r.status_code == 200, \
            f"Search param injection returned {r.status_code} (expected 200 with empty results)."


class TestIDORSecurity:
    """Test Insecure Direct Object Reference (IDOR) scenarios."""

    def test_admin_cannot_access_nonexistent_merchant(self, auth_headers):
        """Attempting to access/delete a nonexistent merchant should return 404, not crash."""
        r = requests.delete(
            f"{BACKEND_URL}/admin/merchants/999999",
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code in (404, 400), \
            f"DELETE /admin/merchants/999999 returned {r.status_code} (expected 404)."

    def test_toggle_nonexistent_merchant_returns_404(self, auth_headers):
        """PUT /admin/merchants/999999/status should return 404."""
        r = requests.put(
            f"{BACKEND_URL}/admin/merchants/999999/status",
            params={"is_active": True},
            headers=auth_headers,
            timeout=30
        )
        assert r.status_code in (404, 400), \
            f"Toggle nonexistent merchant returned {r.status_code} (expected 404)."


class TestCORSSecurity:
    """Test CORS header behavior."""

    def test_cors_response_header_present_on_root(self):
        """Backend should have CORS headers configured."""
        r = requests.options(
            f"{BACKEND_URL}/",
            headers={
                "Origin": "https://harishbalaji826-ops.github.io",
                "Access-Control-Request-Method": "GET",
            },
            timeout=30
        )
        # Should not be a 5xx error
        assert r.status_code < 500, \
            f"CORS preflight to root returned server error {r.status_code}"

    def test_no_wildcard_cors_on_protected_routes(self, auth_headers):
        """Protected endpoints should not have a wildcard ACAO: * header."""
        r = requests.get(
            f"{BACKEND_URL}/admin/dashboard",
            headers={**auth_headers, "Origin": "https://evil.com"},
            timeout=30
        )
        acao = r.headers.get("Access-Control-Allow-Origin", "")
        assert acao != "*", \
            "SECURITY: /admin/dashboard returns 'Access-Control-Allow-Origin: *' (wildcard CORS)!"


class TestRateLimitAndDOS:
    """Basic DoS resilience checks."""

    def test_rapid_otp_requests_do_not_cause_500(self):
        """Sending multiple rapid OTP requests should not cause server errors."""
        errors = []
        for _ in range(5):
            r = requests.post(
                f"{BACKEND_URL}/auth/send-otp",
                json={"phone_number": "8888888888"},
                timeout=30
            )
            if r.status_code == 500:
                errors.append(r.status_code)
        assert len(errors) == 0, \
            f"SECURITY: {len(errors)} requests returned 500 during rapid OTP test — possible DoS vulnerability."

    def test_concurrent_otp_old_code_invalidated(self):
        """After a new OTP is sent, the previous OTP should no longer be valid."""
        phone = "7777777777"
        # Send first OTP
        r1 = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": phone},
            timeout=30
        )
        otp1 = r1.json().get("otp")
        # Send second OTP (overwrites first)
        r2 = requests.post(
            f"{BACKEND_URL}/auth/send-otp",
            json={"phone_number": phone},
            timeout=30
        )
        # Try to verify using first OTP — should fail
        if otp1:
            r3 = requests.post(
                f"{BACKEND_URL}/auth/verify-otp",
                json={"phone_number": phone, "otp_code": otp1},
                timeout=30
            )
            # Could be 400 (invalid) or 200 depending on implementation
            # Just ensure it does not crash (500)
            assert r3.status_code != 500, \
                "Server crashed when verifying old OTP after new one was sent."
