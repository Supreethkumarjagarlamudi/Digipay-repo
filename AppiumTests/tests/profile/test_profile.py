"""
test_profile.py - Profile Screen Tests (TC-087 to TC-104)
DIGIPAY iOS - Appium E2E Test Suite
"""

import pytest
from pages.profile_page import ProfilePage


@pytest.mark.usefixtures("driver_class")
class TestProfileScreen:
    """Profile screen: sections, settings, navigation, and logout."""

    def test_TC087_profile_screen_visible(self, driver_class):
        """TC-087: Profile screen is accessible via tab navigation."""
        page = ProfilePage(driver_class)
        assert page.is_profile_visible(), "Profile screen must be accessible"

    def test_TC088_account_section_visible(self, driver_class):
        """TC-088: 'Account' section is visible."""
        page = ProfilePage(driver_class)
        assert page.is_account_section_visible(), "'Account' section header must be visible"

    def test_TC089_edit_profile_row_visible(self, driver_class):
        """TC-089: 'Edit Profile' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Edit Profile"), "'Edit Profile' must be present in Account section"

    def test_TC090_privacy_security_row_visible(self, driver_class):
        """TC-090: 'Privacy & Security' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Privacy & Security"), "'Privacy & Security' row must be present"

    def test_TC091_notifications_row_visible(self, driver_class):
        """TC-091: 'Notifications' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Notifications"), "'Notifications' row must be present"

    def test_TC092_payment_settings_section_visible(self, driver_class):
        """TC-092: 'Payment Settings' section is visible."""
        page = ProfilePage(driver_class)
        assert page.is_payment_settings_visible(), "'Payment Settings' section must be visible"

    def test_TC093_default_upi_row_visible(self, driver_class):
        """TC-093: 'Default UPI App' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Default UPI App"), "'Default UPI App' row must be present"

    def test_TC094_monthly_budget_row_visible(self, driver_class):
        """TC-094: 'Monthly Budget' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Monthly Budget"), "'Monthly Budget' row must be present"

    def test_TC095_monthly_income_row_visible(self, driver_class):
        """TC-095: 'Monthly Income' row is visible."""
        page = ProfilePage(driver_class)
        assert page.is_visible("Monthly Income"), "'Monthly Income' row must be present"

    def test_TC096_export_csv_row_visible(self, driver_class):
        """TC-096: 'Export Transactions (CSV)' row is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Export Transactions (CSV)")
        assert page.is_visible("Export Transactions (CSV)"), "Export CSV row must be present"

    def test_TC097_support_section_visible(self, driver_class):
        """TC-097: 'Support' section header is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Support")
        assert page.is_visible("Support"), "'Support' section header must be visible"

    def test_TC098_help_support_row_visible(self, driver_class):
        """TC-098: 'Help & Support' row is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Help & Support")
        assert page.is_visible("Help & Support"), "'Help & Support' row must be present"

    def test_TC099_terms_row_visible(self, driver_class):
        """TC-099: 'Terms & Conditions' row is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Terms & Conditions")
        assert page.is_visible("Terms & Conditions"), "'Terms & Conditions' row must be present"

    def test_TC100_privacy_policy_row_visible(self, driver_class):
        """TC-100: 'Privacy Policy' row is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Privacy Policy")
        assert page.is_visible("Privacy Policy"), "'Privacy Policy' row must be present"

    def test_TC101_about_digipay_row_visible(self, driver_class):
        """TC-101: 'About DIGIPAY' row is visible."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("About DIGIPAY")
        assert page.is_visible("About DIGIPAY"), "'About DIGIPAY' row must be present"

    def test_TC102_logout_button_visible(self, driver_class):
        """TC-102: Logout button is visible at the bottom of profile."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Logout")
        assert page.is_visible("Logout"), "Logout button must be visible"

    def test_TC103_logout_shows_confirmation_dialog(self, driver_class):
        """TC-103: Tapping Logout shows confirmation dialog."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Logout")
        page.tap_logout()
        page.wait_seconds(0.5)
        assert page.is_logout_confirmation_visible(), "Logout confirmation alert must appear"

    def test_TC104_cancel_logout_keeps_user_in(self, driver_class):
        """TC-104: Cancelling logout keeps user on profile screen."""
        page = ProfilePage(driver_class)
        page.scroll_to_element("Logout")
        page.tap_logout()
        page.wait_seconds(0.5)
        if page.is_logout_confirmation_visible():
            page.cancel_logout()
            page.wait_seconds(0.5)
            assert page.is_profile_visible(), "Profile must still be visible after cancelling logout"
