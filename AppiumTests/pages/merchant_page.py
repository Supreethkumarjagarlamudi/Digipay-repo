"""
merchant_page.py - Page Object for Merchant screens
Digipay iOS App
"""

from pages.base_page import BasePage


class MerchantHomePage(BasePage):
    """Merchant Home screen."""

    MERCHANT_DASHBOARD  = "Merchant Dashboard"
    PAYMENTS_HISTORY    = "Payments History"
    EDIT_PROFILE_BTN    = "Edit Profile"
    DIGIPIN_LABEL       = "DIGIPIN"
    TOTAL_REVENUE_LABEL = "Total Revenue"
    QR_SECTION          = "QR Code"

    def is_merchant_home_visible(self) -> bool:
        return self.is_visible(self.MERCHANT_DASHBOARD) or self.is_visible("Merchant")

    def tap_payments_history(self):
        self.tap(self.PAYMENTS_HISTORY)

    def tap_edit_profile(self):
        self.tap(self.EDIT_PROFILE_BTN)

    def is_digipin_visible(self) -> bool:
        return self.is_visible(self.DIGIPIN_LABEL)

    def is_revenue_visible(self) -> bool:
        return self.is_visible(self.TOTAL_REVENUE_LABEL)


class MerchantPaymentsPage(BasePage):
    """Merchant Payments History screen."""

    PAGE_TITLE = "Payments History"
    NO_PAYMENTS = "No payments recorded"

    def is_payments_visible(self) -> bool:
        return self.is_visible(self.PAGE_TITLE)

    def get_payment_count(self) -> int:
        cells = self.find_all_by_class("XCUIElementTypeCell")
        return len(cells)
