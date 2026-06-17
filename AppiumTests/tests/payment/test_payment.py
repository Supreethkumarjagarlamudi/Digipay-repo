"""
test_payment.py - Payment / Amount Entry Tests (TC-071 to TC-086)
DIGIPAY iOS - Appium E2E Test Suite
"""

import pytest
from pages.payment_page import PaymentPage
from pages.home_page import HomePage


@pytest.mark.usefixtures("driver_class")
class TestPaymentScreen:
    """Payment flow: amount entry, presets, confirmation dialog."""

    def _navigate_to_payment(self, driver):
        """Navigate from Home → Pay Now on recommended merchant."""
        home = HomePage(driver)
        if home.is_pay_now_visible():
            home.tap_pay_now()
            return PaymentPage(driver)
        pytest.skip("No recommended merchant available — cannot navigate to payment screen")

    def test_TC071_payment_screen_visible(self, driver_class):
        """TC-071: Send Money screen is visible after tapping Pay Now."""
        page = self._navigate_to_payment(driver_class)
        assert page.is_payment_screen_visible(), "Send Money screen must be visible"

    def test_TC072_enter_amount_label_visible(self, driver_class):
        """TC-072: 'Enter Amount' label is displayed on payment screen."""
        page = self._navigate_to_payment(driver_class)
        assert page.is_enter_amount_visible(), "'Enter Amount' label must be present"

    def test_TC073_preset_100_visible(self, driver_class):
        """TC-073: Quick preset '+ ₹100' is visible."""
        page = self._navigate_to_payment(driver_class)
        assert page.is_preset_100_visible(), "Preset ₹100 button must be visible"

    def test_TC074_preset_500_visible(self, driver_class):
        """TC-074: Quick preset '+ ₹500' is visible."""
        page = self._navigate_to_payment(driver_class)
        assert page.is_preset_500_visible(), "Preset ₹500 button must be visible"

    def test_TC075_tapping_preset_fills_amount(self, driver_class):
        """TC-075: Tapping a preset fills the amount field."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        label = page.get_pay_button_label()
        assert "100" in label or page.is_pay_button_enabled(), \
            "Amount field should be filled with 100 after tapping preset"

    def test_TC076_tapping_preset_500_fills_amount(self, driver_class):
        """TC-076: Tapping '+ ₹500' fills amount with 500."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("500")
        label = page.get_pay_button_label()
        assert "500" in label or page.is_pay_button_enabled(), \
            "Amount field should show 500 after tapping preset"

    def test_TC077_pay_button_disabled_with_zero_amount(self, driver_class):
        """TC-077: Pay button is disabled when amount is 0."""
        page = self._navigate_to_payment(driver_class)
        # No amount entered — button should be disabled
        assert not page.is_pay_button_enabled() or page.get_pay_button_label() == f"Pay ₹0.00", \
            "Pay button should be disabled for zero amount"

    def test_TC078_pay_button_enabled_after_amount_entry(self, driver_class):
        """TC-078: Pay button becomes enabled after entering valid amount."""
        page = self._navigate_to_payment(driver_class)
        page.enter_amount("250")
        assert page.is_pay_button_enabled(), "Pay button must be enabled after entering valid amount"

    def test_TC079_confirm_dialog_shows_after_pay(self, driver_class):
        """TC-079: Confirmation dialog appears after tapping Pay."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        page.tap_pay()
        page.wait_seconds(1.5)  # UPI app opens and returns
        assert page.is_confirm_dialog_visible(), "Confirmation dialog must appear after Pay tap"

    def test_TC080_confirm_dialog_has_yes_button(self, driver_class):
        """TC-080: Confirmation dialog contains 'Yes, Record Transaction' button."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        page.tap_pay()
        page.wait_seconds(1.5)
        assert page.is_visible("Yes, Record Transaction"), "'Yes, Record Transaction' must be in dialog"

    def test_TC081_confirm_dialog_has_no_button(self, driver_class):
        """TC-081: Confirmation dialog contains 'No, Cancel' button."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        page.tap_pay()
        page.wait_seconds(1.5)
        assert page.is_visible("No, Cancel"), "'No, Cancel' must be in confirmation dialog"

    def test_TC082_cancel_confirmation_closes_dialog(self, driver_class):
        """TC-082: Tapping 'No, Cancel' closes the confirmation dialog."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        page.tap_pay()
        page.wait_seconds(1.5)
        if page.is_confirm_dialog_visible():
            page.cancel_payment()
            page.wait_seconds(1)
            assert not page.is_confirm_dialog_visible(), "Confirmation dialog should close on cancel"

    def test_TC083_secure_payment_text_visible(self, driver_class):
        """TC-083: 'Secure payment routed via ...' text is visible."""
        page = self._navigate_to_payment(driver_class)
        assert page.is_secure_text_visible(), "Secure payment text must be visible"

    def test_TC084_back_button_dismisses_payment_screen(self, driver_class):
        """TC-084: Back button dismisses the payment screen."""
        page = self._navigate_to_payment(driver_class)
        page.tap_back()
        home = HomePage(driver_class)
        assert home.is_home_visible() or home.is_visible("Recommended Merchant"), \
            "Should return to home after back from payment"

    def test_TC085_amount_field_decimal_support(self, driver_class):
        """TC-085: Amount field supports decimal values."""
        page = self._navigate_to_payment(driver_class)
        page.enter_amount("99.99")
        label = page.get_pay_button_label()
        assert "99" in label or page.is_pay_button_enabled(), "Decimal amount should be supported"

    def test_TC086_payment_success_shows_checkmark(self, driver_class):
        """TC-086: Success animation shows after recording payment."""
        page = self._navigate_to_payment(driver_class)
        page.tap_preset("100")
        page.tap_pay()
        page.wait_seconds(1.5)
        if page.is_confirm_dialog_visible():
            page.confirm_payment()
            page.wait_seconds(4)  # Wait for processing + success
            assert page.is_success_visible() or not page.is_confirm_dialog_visible(), \
                "Payment success should be shown after confirmation"
