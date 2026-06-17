"""
otp_page.py - Page Object for OTPView
Digipay iOS App
"""

from pages.base_page import BasePage


class OTPPage(BasePage):
    """Covers the OTP verification screen."""

    VERIFY_OTP_LABEL = "Verify OTP"
    OTP_AUTO_TEXT    = "OTP will auto verify"
    ERROR_ICON       = "exclamationmark.circle.fill"
    BACK_BTN         = "chevron.left"
    LOGO             = "app_logo"
    OTP_FIELD_TYPE   = "XCUIElementTypeTextField"

    def enter_otp(self, otp_code: str):
        field = self.find_by_predicate(f'type == "{self.OTP_FIELD_TYPE}"')
        field.clear()
        field.send_keys(otp_code)

    def tap_back(self):
        self.tap(self.BACK_BTN)

    def is_otp_screen_visible(self) -> bool:
        return self.is_visible(self.VERIFY_OTP_LABEL)

    def is_phone_number_displayed(self, phone: str) -> bool:
        return self.is_visible(f"+91 {phone}")

    def is_error_visible(self) -> bool:
        return self.is_visible(self.ERROR_ICON)

    def is_auto_verify_label_visible(self) -> bool:
        return self.is_visible(self.OTP_AUTO_TEXT)

    def is_logo_visible(self) -> bool:
        return self.is_visible(self.LOGO)

    def get_otp_digit_count(self) -> int:
        """Count the number of digit boxes rendered (should be 6)."""
        boxes = self.find_all_by_class("XCUIElementTypeSecureTextField")
        if not boxes:
            boxes = self.find_all_by_class("XCUIElementTypeTextField")
        return len(boxes)

    def wait_for_otp_alert(self, timeout: int = 20) -> bool:
        """Wait for the dev-mode alert that shows the OTP."""
        try:
            from selenium.webdriver.support.ui import WebDriverWait
            from selenium.webdriver.support import expected_conditions as EC
            WebDriverWait(self.driver, timeout).until(EC.alert_is_present())
            return True
        except Exception:
            return False

    def get_otp_from_alert(self) -> str:
        """Extract OTP from the Development Build alert."""
        text = self.get_alert_text()
        # Format: "Your OTP is\n\n123456\n\nUse this code to continue."
        lines = [l.strip() for l in text.split("\n") if l.strip()]
        for line in lines:
            if line.isdigit() and len(line) == 6:
                return line
        return ""

    def confirm_alert(self):
        self.accept_alert()
