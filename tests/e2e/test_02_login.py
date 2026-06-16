"""
test_02_login.py — Login Portal functional tests for Digipay.
Tests OTP send, OTP verify, validation errors, and back navigation.
"""

import time
import pytest
import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import FRONTEND_URL, BACKEND_URL, ADMIN_PHONE, wait_for_visible


def navigate_to_login(driver):
    """Helper: navigate from landing page to login portal."""
    driver.get(FRONTEND_URL)
    WebDriverWait(driver, 20).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="login-nav-button"]'))
    )
    driver.find_element(By.CSS_SELECTOR, '[data-testid="login-nav-button"]').click()
    wait_for_visible(driver, By.CSS_SELECTOR, '[data-testid="phone-input"]')


class TestLoginPortal:
    """Functional tests for the Digipay Login Portal."""

    @pytest.fixture(autouse=True)
    def setup(self, fresh_driver):
        """Use a fresh driver per test to avoid state leaking."""
        self.driver = fresh_driver
        navigate_to_login(self.driver)

    # ── 1. UI Rendering ─────────────────────────────────────────────────────

    def test_login_page_renders(self, fresh_driver):
        """Login portal renders the 'Secure Login Portal' heading."""
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert "Secure Login Portal" in body_text or "Login" in body_text, \
            "Login portal heading 'Secure Login Portal' is missing."

    def test_phone_input_visible(self, fresh_driver):
        """Phone number input field should be visible."""
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        assert inp.is_displayed(), "Phone number input is not displayed."

    def test_request_code_button_visible(self, fresh_driver):
        """'Request Code' button should be visible on step 1."""
        btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]')
        assert btn.is_displayed(), "'Request Code' button is not displayed."
        assert "Request" in btn.text or "Code" in btn.text or "Submit" in btn.text, \
            f"Button text mismatch: '{btn.text}'"

    def test_back_button_visible(self, fresh_driver):
        """'Back to Home' button should be visible on the login page."""
        btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="back-button"]')
        assert btn.is_displayed(), "Back button is not displayed."

    def test_country_code_prefix_visible(self, fresh_driver):
        """'+91' country code prefix should be visible."""
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert "+91" in body_text, "Country code prefix '+91' is missing from login page."

    # ── 2. Validation ───────────────────────────────────────────────────────

    def test_short_phone_shows_toast_error(self, fresh_driver):
        """Submitting a short phone number (< 10 digits) should show a toast error."""
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys("12345")  # only 5 digits
        btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]')
        btn.click()
        time.sleep(1.5)
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        # Toast should appear with validation message
        assert "10" in body_text or "valid" in body_text.lower() or "digit" in body_text.lower(), \
            "No validation toast appeared for short phone number."

    def test_empty_phone_shows_toast_error(self, fresh_driver):
        """Submitting an empty phone number should show a toast error."""
        btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]')
        btn.click()
        time.sleep(1.5)
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert "10" in body_text or "valid" in body_text.lower() or "mobile" in body_text.lower(), \
            "No validation toast appeared for empty phone number."

    # ── 3. Back Navigation ──────────────────────────────────────────────────

    def test_back_button_returns_to_landing(self, fresh_driver):
        """Clicking 'Back to Home' should return to the landing page."""
        back_btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="back-button"]')
        back_btn.click()
        time.sleep(1.5)
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert "DIGIPAY" in body_text or "UPI" in body_text or "Open Web Portal" in body_text, \
            "Clicking Back did not return to the landing page."

    # ── 4. OTP Step Rendering ───────────────────────────────────────────────

    def test_send_otp_shows_otp_step(self, fresh_driver):
        """Sending OTP with a valid phone should switch to the OTP entry step."""
        # Use admin phone for a guaranteed response
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys(ADMIN_PHONE)
        btn = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]')
        btn.click()
        # Wait for OTP input to appear (step 2)
        WebDriverWait(self.driver, 25).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-input"]'))
        )
        otp_input = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-input"]')
        assert otp_input.is_displayed(), "OTP input did not appear after sending OTP."

    def test_developer_otp_hint_visible(self, fresh_driver):
        """Dev OTP hint block should appear after a valid OTP send."""
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys(ADMIN_PHONE)
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()
        WebDriverWait(self.driver, 25).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-help-block"]'))
        )
        hint = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-help-block"]')
        assert hint.is_displayed(), "Developer OTP hint block is not visible after OTP send."
        assert len(hint.text.strip()) > 0, "Developer OTP hint block appears empty."

    def test_change_phone_number_button_visible_on_otp_step(self, fresh_driver):
        """'Change Phone Number' button should appear on the OTP entry step."""
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys(ADMIN_PHONE)
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()
        WebDriverWait(self.driver, 25).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-input"]'))
        )
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert "Change Phone" in body_text, \
            "'Change Phone Number' button is missing on OTP entry step."

    # ── 5. Full Login Flow ──────────────────────────────────────────────────

    def test_full_admin_login_flow(self, fresh_driver):
        """Full admin login: send OTP → read hint → verify → dashboard renders."""
        # Step 1: Enter phone
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys(ADMIN_PHONE)
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()

        # Step 2: Wait for OTP hint
        WebDriverWait(self.driver, 25).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-help-block"]'))
        )
        hint_elem = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-help-block"]')
        hint_text = hint_elem.text.strip()
        # Extract the 6-digit OTP from hint text
        otp_code = "".join(filter(str.isdigit, hint_text))[-6:]
        assert len(otp_code) == 6, f"Could not extract 6-digit OTP from hint: '{hint_text}'"

        # Step 3: Enter OTP
        otp_input = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-input"]')
        otp_input.send_keys(otp_code)
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()

        # Step 4: Wait for dashboard to load
        WebDriverWait(self.driver, 30).until(
            lambda d: "Secure Login Portal" not in d.find_element(By.TAG_NAME, "body").text
        )
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        # Dashboard should show admin/user name or a dashboard element
        assert (
            "Administrator" in body_text
            or "Dashboard" in body_text
            or "DIGIPAY" in body_text
        ), f"Dashboard did not load after admin login. Body: {body_text[:200]}"

    def test_wrong_otp_shows_error(self, fresh_driver):
        """Submitting an incorrect OTP should show an error toast."""
        inp = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        inp.send_keys(ADMIN_PHONE)
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()
        WebDriverWait(self.driver, 25).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-input"]'))
        )
        otp_input = self.driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-input"]')
        otp_input.send_keys("000000")  # deliberately wrong
        self.driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()
        time.sleep(3)
        body_text = self.driver.find_element(By.TAG_NAME, "body").text
        assert (
            "Invalid" in body_text
            or "invalid" in body_text
            or "wrong" in body_text.lower()
            or "verification" in body_text.lower()
        ), "No error message appeared for wrong OTP."
