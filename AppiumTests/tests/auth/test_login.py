"""
test_login.py - Authentication Tests (TC-001 to TC-018)
DIGIPAY iOS - Appium E2E Test Suite
Tests: Role selection, Phone entry, validation, UI elements
"""

import pytest
from pages.login_page import LoginPage, RoleSelectionPage
from pages.otp_page import OTPPage


@pytest.mark.usefixtures("driver")
class TestRoleSelection:
    """UI/UX and Functional tests for the Role Selection screen."""

    def test_TC001_role_screen_is_visible_on_launch(self, driver):
        """TC-001: App launches and role selection screen is visible."""
        page = RoleSelectionPage(driver)
        assert page.is_role_screen_visible(), "Role selection screen should be visible on launch"

    def test_TC002_customer_button_is_present(self, driver):
        """TC-002: Customer button is rendered on role screen."""
        page = RoleSelectionPage(driver)
        assert page.is_visible("Customer"), "Customer button must be visible"

    def test_TC003_merchant_button_is_present(self, driver):
        """TC-003: Merchant button is rendered on role screen."""
        page = RoleSelectionPage(driver)
        assert page.is_visible("Merchant"), "Merchant button must be visible"

    def test_TC004_tap_customer_navigates_to_login(self, driver):
        """TC-004: Tapping Customer navigates to Login screen."""
        role_page = RoleSelectionPage(driver)
        role_page.tap_customer()
        login = LoginPage(driver)
        assert login.is_login_screen_visible(), "Login screen must appear after selecting Customer"

    def test_TC005_tap_merchant_navigates_to_login(self, driver):
        """TC-005: Tapping Merchant navigates to Login screen."""
        role_page = RoleSelectionPage(driver)
        role_page.tap_merchant()
        login = LoginPage(driver)
        assert login.is_login_screen_visible(), "Login screen must appear after selecting Merchant"

    def test_TC006_merchant_badge_shows_after_merchant_select(self, driver):
        """TC-006: Merchant role badge is visible after tapping Merchant."""
        role_page = RoleSelectionPage(driver)
        role_page.tap_merchant()
        login = LoginPage(driver)
        assert login.is_role_badge_visible("Merchant"), "Merchant badge should be shown on Login screen"


@pytest.mark.usefixtures("driver")
class TestLoginValidation:
    """Validation tests for phone number entry."""

    def _go_to_login(self, driver) -> LoginPage:
        role = RoleSelectionPage(driver)
        role.tap_customer()
        return LoginPage(driver)

    def test_TC007_login_screen_has_logo(self, driver):
        """TC-007: Logo is visible on the login screen."""
        page = self._go_to_login(driver)
        assert page.is_logo_visible(), "App logo must be displayed on login"

    def test_TC008_login_screen_has_continue_button(self, driver):
        """TC-008: Continue button is present on the login screen."""
        page = self._go_to_login(driver)
        assert page.is_continue_button_visible(), "Continue button must be present"

    def test_TC009_login_screen_has_back_button(self, driver):
        """TC-009: Back button is present on the login screen."""
        page = self._go_to_login(driver)
        assert page.is_back_button_visible(), "Back button must be present"

    def test_TC010_secure_text_visible(self, driver):
        """TC-010: 'Secure Context-Aware Payments' text is visible."""
        page = self._go_to_login(driver)
        assert page.is_secure_text_visible(), "Security tagline must be visible"

    def test_TC011_empty_phone_shows_error(self, driver):
        """TC-011: Tapping Continue with empty phone shows validation error."""
        page = self._go_to_login(driver)
        page.tap_continue()
        assert page.is_error_visible(), "Error must appear for empty phone number"

    def test_TC012_short_phone_shows_error(self, driver):
        """TC-012: 9-digit phone number shows validation error."""
        page = self._go_to_login(driver)
        page.enter_phone_number("987654321")  # 9 digits
        page.tap_continue()
        assert page.is_error_visible(), "Error must appear for 9-digit phone number"

    def test_TC013_valid_10_digit_phone_proceeds(self, driver):
        """TC-013: Valid 10-digit phone proceeds to OTP screen."""
        page = self._go_to_login(driver)
        page.login_with_phone("9876543210")
        otp_page = OTPPage(driver)
        # Wait for OTP dev alert
        if otp_page.wait_for_otp_alert(timeout=15):
            otp_page.confirm_alert()
        assert otp_page.is_otp_screen_visible(), "OTP screen should appear after valid phone entry"

    def test_TC014_phone_field_accepts_only_digits(self, driver):
        """TC-014: Phone field accepts numeric input correctly."""
        page = self._go_to_login(driver)
        page.enter_phone_number("9876543210")
        val = page.get_phone_field_value()
        assert val.replace("+91", "").strip().isdigit() or "9876543210" in val, \
            "Phone field should contain the entered digits"

    def test_TC015_back_button_returns_to_role_screen(self, driver):
        """TC-015: Back button on login returns to role selection screen."""
        role = RoleSelectionPage(driver)
        role.tap_customer()
        login = LoginPage(driver)
        login.tap_back()
        assert role.is_role_screen_visible(), "Role selection screen should be shown after back"

    def test_TC016_clear_phone_field_works(self, driver):
        """TC-016: Phone field can be cleared."""
        page = self._go_to_login(driver)
        page.enter_phone_number("1234567890")
        page.clear_phone_field()
        val = page.get_phone_field_value()
        assert val == "" or val is None, "Phone field should be empty after clear"

    def test_TC017_customer_badge_shows_on_login(self, driver):
        """TC-017: Customer badge is visible on login screen."""
        page = self._go_to_login(driver)
        assert page.is_role_badge_visible("Customer"), "Customer badge should appear on login for Customer role"

    def test_TC018_login_screen_scrolls_without_crash(self, driver):
        """TC-018: Login screen scrolls without crashing."""
        page = self._go_to_login(driver)
        page.scroll_down()
        page.scroll_up()
        assert page.is_login_screen_visible(), "Login screen should remain stable after scroll"
