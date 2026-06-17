"""
profile_page.py - Page Object for ProfileView
Digipay iOS App
"""

from pages.base_page import BasePage


class ProfilePage(BasePage):
    """Customer profile screen."""

    ACCOUNT_SECTION     = "Account"
    EDIT_PROFILE        = "Edit Profile"
    PRIVACY_SECURITY    = "Privacy & Security"
    NOTIFICATIONS       = "Notifications"
    PAYMENT_SETTINGS    = "Payment Settings"
    DEFAULT_UPI         = "Default UPI App"
    MONTHLY_BUDGET      = "Monthly Budget"
    MONTHLY_INCOME      = "Monthly Income"
    RESET_STATS         = "Reset Statistics"
    EXPORT_CSV          = "Export Transactions (CSV)"
    SUPPORT_SECTION     = "Support"
    HELP_SUPPORT        = "Help & Support"
    CONTACT_US          = "Contact Us"
    APP_INFO            = "App Information"
    TERMS               = "Terms & Conditions"
    PRIVACY_POLICY      = "Privacy Policy"
    ABOUT               = "About DIGIPAY"
    SYSTEM_DIAGNOSTICS  = "System Diagnostics"
    LOGOUT_BTN          = "Logout"
    LOGOUT_CONFIRM_MSG  = "Are you sure you want to logout?"
    LOGOUT_CANCEL       = "Cancel"
    LOGOUT_CONFIRM      = "Logout"

    # ─ Actions ────────────────────────────────────────────────────────────────

    def tap_edit_profile(self):
        self.tap(self.EDIT_PROFILE)

    def tap_privacy_security(self):
        self.tap(self.PRIVACY_SECURITY)

    def tap_notifications(self):
        self.tap(self.NOTIFICATIONS)

    def tap_default_upi(self):
        self.tap(self.DEFAULT_UPI)

    def tap_monthly_budget(self):
        self.tap(self.MONTHLY_BUDGET)

    def tap_monthly_income(self):
        self.tap(self.MONTHLY_INCOME)

    def tap_reset_statistics(self):
        self.tap(self.RESET_STATS)

    def tap_export_csv(self):
        self.tap(self.EXPORT_CSV)

    def tap_logout(self):
        self.tap(self.LOGOUT_BTN)

    def confirm_logout(self):
        self.tap(self.LOGOUT_CONFIRM)

    def cancel_logout(self):
        self.tap(self.LOGOUT_CANCEL)

    def tap_terms(self):
        self.scroll_to_element(self.TERMS)
        self.tap(self.TERMS)

    def tap_privacy_policy(self):
        self.scroll_to_element(self.PRIVACY_POLICY)
        self.tap(self.PRIVACY_POLICY)

    def tap_about(self):
        self.scroll_to_element(self.ABOUT)
        self.tap(self.ABOUT)

    def tap_system_diagnostics(self):
        self.scroll_to_element(self.SYSTEM_DIAGNOSTICS)
        self.tap(self.SYSTEM_DIAGNOSTICS)

    def tap_help_support(self):
        self.tap(self.HELP_SUPPORT)

    def tap_contact_us(self):
        self.tap(self.CONTACT_US)

    # ─ Assertions ─────────────────────────────────────────────────────────────

    def is_profile_visible(self) -> bool:
        return self.is_visible(self.LOGOUT_BTN)

    def is_account_section_visible(self) -> bool:
        return self.is_visible(self.ACCOUNT_SECTION)

    def is_payment_settings_visible(self) -> bool:
        return self.is_visible(self.PAYMENT_SETTINGS)

    def is_support_section_visible(self) -> bool:
        return self.is_visible(self.SUPPORT_SECTION)

    def is_app_info_visible(self) -> bool:
        return self.is_visible(self.APP_INFO)

    def is_logout_confirmation_visible(self) -> bool:
        return self.is_visible(self.LOGOUT_CONFIRM_MSG)

    def is_user_name_visible(self) -> bool:
        return self.is_visible("Complete Profile") or self.find_by_predicate(
            'type == "XCUIElementTypeStaticText" AND value != "" AND label != ""'
        ) is not None

    def get_role_badge_text(self) -> str:
        el = self.find_by_predicate(
            'label == "customer" OR label == "merchant"'
        )
        return el.text if el else ""
