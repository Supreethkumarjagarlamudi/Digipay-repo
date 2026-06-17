"""
payment_page.py - Page Object for AmountEntryView (Send Money)
Digipay iOS App
"""

from pages.base_page import BasePage


class PaymentPage(BasePage):
    """Amount entry and payment confirmation screen."""

    TITLE           = "Send Money"
    BACK_BTN        = "Back"
    ENTER_AMOUNT    = "Enter Amount"
    PAY_BTN_PREFIX  = "Pay ₹"
    CONFIRM_TITLE   = "Confirm Transaction"
    CONFIRM_MSG     = "Did you complete the payment inside the UPI app?"
    YES_RECORD_BTN  = "Yes, Record Transaction"
    NO_CANCEL_BTN   = "No, Cancel"
    SUCCESS_MSG     = "Payment Recorded!"
    PROCESSING_MSG  = "Logging Transaction..."
    CREDIT_ICON     = "creditcard.fill"
    PRESET_100      = "+ ₹100"
    PRESET_200      = "+ ₹200"
    PRESET_500      = "+ ₹500"
    PRESET_1000     = "+ ₹1000"
    SECURE_UPI_TEXT = "Secure payment routed via"

    # ─ Actions ────────────────────────────────────────────────────────────────

    def enter_amount(self, amount: str):
        field = self.find_by_predicate('type == "XCUIElementTypeTextField"')
        field.clear()
        field.send_keys(amount)

    def tap_preset(self, preset: str):
        """preset one of: '100', '200', '500', '1000'"""
        self.tap(f"+ ₹{preset}")

    def tap_pay(self):
        el = self.find_by_predicate(
            f'label BEGINSWITH "{self.PAY_BTN_PREFIX}" AND type == "XCUIElementTypeButton"'
        )
        el.click()

    def tap_back(self):
        self.tap(self.BACK_BTN)

    def confirm_payment(self):
        self.tap(self.YES_RECORD_BTN)

    def cancel_payment(self):
        self.tap(self.NO_CANCEL_BTN)

    # ─ Assertions ─────────────────────────────────────────────────────────────

    def is_payment_screen_visible(self) -> bool:
        return self.is_visible(self.TITLE)

    def is_enter_amount_visible(self) -> bool:
        return self.is_visible(self.ENTER_AMOUNT)

    def is_confirm_dialog_visible(self) -> bool:
        return self.is_visible(self.CONFIRM_TITLE)

    def is_success_visible(self) -> bool:
        return self.is_visible(self.SUCCESS_MSG)

    def is_processing_visible(self) -> bool:
        return self.is_visible(self.PROCESSING_MSG)

    def get_pay_button_label(self) -> str:
        el = self.find_by_predicate(
            f'label BEGINSWITH "{self.PAY_BTN_PREFIX}" AND type == "XCUIElementTypeButton"'
        )
        return el.text if el else ""

    def is_pay_button_enabled(self) -> bool:
        el = self.find_by_predicate(
            f'label BEGINSWITH "{self.PAY_BTN_PREFIX}" AND type == "XCUIElementTypeButton"'
        )
        return el.is_enabled() if el else False

    def is_preset_100_visible(self) -> bool:
        return self.is_visible(self.PRESET_100)

    def is_preset_500_visible(self) -> bool:
        return self.is_visible(self.PRESET_500)

    def is_secure_text_visible(self) -> bool:
        return self.is_visible(self.SECURE_UPI_TEXT)

    def get_merchant_name(self) -> str:
        el = self.find_by_predicate('type == "XCUIElementTypeStaticText" AND label CONTAINS "Restaurant" OR label CONTAINS "Store" OR label CONTAINS "Shop" OR label CONTAINS "Market"')
        return el.text if el else ""
