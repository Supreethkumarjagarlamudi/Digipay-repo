"""
login_page.py - Page Object for LoginView (Phone number entry + role selection)
Digipay iOS App
"""

from pages.base_page import BasePage


class RoleSelectionPage(BasePage):
    """Covers the first screen: select Customer or Merchant role."""

    CUSTOMER_BTN  = "Customer"          # accessibility ID on RoleSelectionView
    MERCHANT_BTN  = "Merchant"
    WELCOME_LABEL = "Welcome to Digipay"

    def tap_customer(self):
        self.tap(self.CUSTOMER_BTN)

    def tap_merchant(self):
        self.tap(self.MERCHANT_BTN)

    def is_role_screen_visible(self) -> bool:
        return self.is_visible(self.CUSTOMER_BTN)

    def get_welcome_text(self) -> str:
        return self.get_text(self.WELCOME_LABEL)


class LoginPage(BasePage):
    """Covers the LoginView screen for phone number entry."""

    PHONE_FIELD    = "9876543210"       # placeholder text used as accessibilityLabel
    CONTINUE_BTN   = "Continue"
    BACK_BTN       = "chevron.left"
    LOGO           = "app_logo"
    WELCOME_BACK   = "Welcome Back 👋"
    ERROR_LABEL    = "Please enter a valid mobile number"
    CUSTOMER_BADGE = "Customer"
    MERCHANT_BADGE = "Merchant"
    SECURE_TEXT    = "Secure Context-Aware Payments"

    # ─ Actions ────────────────────────────────────────────────────────────────

    def enter_phone_number(self, number: str):
        """Tap the phone field and type a number."""
        field = self.find_by_predicate(
            f'type == "XCUIElementTypeTextField"'
        )
        field.clear()
        field.send_keys(number)

    def tap_continue(self):
        self.tap(self.CONTINUE_BTN)

    def tap_back(self):
        self.tap(self.BACK_BTN)

    def login_with_phone(self, phone: str):
        self.enter_phone_number(phone)
        self.tap_continue()

    # ─ Assertions ─────────────────────────────────────────────────────────────

    def is_login_screen_visible(self) -> bool:
        return self.is_visible(self.CONTINUE_BTN)

    def is_error_visible(self) -> bool:
        return self.is_visible(self.ERROR_LABEL)

    def is_logo_visible(self) -> bool:
        return self.is_visible(self.LOGO)

    def is_continue_button_visible(self) -> bool:
        return self.is_visible(self.CONTINUE_BTN)

    def is_back_button_visible(self) -> bool:
        return self.is_visible(self.BACK_BTN)

    def is_role_badge_visible(self, role: str = "Customer") -> bool:
        return self.is_visible(role)

    def is_secure_text_visible(self) -> bool:
        return self.is_visible(self.SECURE_TEXT)

    def get_phone_field_value(self) -> str:
        field = self.find_by_predicate('type == "XCUIElementTypeTextField"')
        return field.text

    def clear_phone_field(self):
        field = self.find_by_predicate('type == "XCUIElementTypeTextField"')
        field.clear()

    def get_continue_button_enabled(self) -> bool:
        return self.is_element_enabled(self.CONTINUE_BTN)
