"""
conftest.py — Shared fixtures for Digipay E2E + API test suite.
"""

import time
import pytest
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

# ─────────────────────────────────────────────
# URLs (overridable via pytest --base-url / env)
# ─────────────────────────────────────────────
FRONTEND_URL = "https://harishbalaji826-ops.github.io/digipay-web"
BACKEND_URL  = "https://web-production-86613.up.railway.app"

ADMIN_PHONE  = "9999999999"


# ─────────────────────────────────────────────
# Selenium WebDriver fixture (module-scoped)
# ─────────────────────────────────────────────
@pytest.fixture(scope="module")
def driver():
    """Headless Chrome WebDriver, shared across tests in a module."""
    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-web-security")
    chrome_options.add_argument("--allow-running-insecure-content")
    chrome_options.add_argument("--ignore-certificate-errors")

    drv = webdriver.Chrome(options=chrome_options)
    drv.implicitly_wait(10)
    yield drv
    drv.quit()


# ─────────────────────────────────────────────
# Fresh driver per test (function-scoped)
# ─────────────────────────────────────────────
@pytest.fixture(scope="function")
def fresh_driver():
    """Fresh headless Chrome per test function — for isolation."""
    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--ignore-certificate-errors")

    drv = webdriver.Chrome(options=chrome_options)
    drv.implicitly_wait(10)
    yield drv
    drv.quit()


# ─────────────────────────────────────────────
# URL fixtures
# ─────────────────────────────────────────────
@pytest.fixture(scope="session")
def frontend_url():
    return FRONTEND_URL


@pytest.fixture(scope="session")
def backend_url():
    return BACKEND_URL


# ─────────────────────────────────────────────
# Admin token helper (session-scoped)
# ─────────────────────────────────────────────
@pytest.fixture(scope="session")
def admin_token():
    """
    Obtain a valid admin JWT by calling /auth/send-otp and /auth/verify-otp.
    The dev API returns the OTP in the response body.
    """
    # Step 1: Send OTP
    r1 = requests.post(
        f"{BACKEND_URL}/auth/send-otp",
        json={"phone_number": ADMIN_PHONE},
        timeout=30
    )
    assert r1.status_code == 200, f"send-otp failed: {r1.text}"
    otp = r1.json().get("otp")
    assert otp, "OTP not returned in response"

    # Step 2: Verify OTP
    r2 = requests.post(
        f"{BACKEND_URL}/auth/verify-otp",
        json={"phone_number": ADMIN_PHONE, "otp_code": otp},
        timeout=30
    )
    assert r2.status_code == 200, f"verify-otp failed: {r2.text}"
    token = r2.json().get("access_token")
    assert token, "access_token not in verify-otp response"
    return token


# ─────────────────────────────────────────────
# Auth header helper
# ─────────────────────────────────────────────
@pytest.fixture(scope="session")
def auth_headers(admin_token):
    return {"Authorization": f"Bearer {admin_token}"}


# ─────────────────────────────────────────────
# Wait helper
# ─────────────────────────────────────────────
def wait_for_element(driver, by, value, timeout=20):
    return WebDriverWait(driver, timeout).until(
        EC.presence_of_element_located((by, value))
    )


def wait_for_visible(driver, by, value, timeout=20):
    return WebDriverWait(driver, timeout).until(
        EC.visibility_of_element_located((by, value))
    )
