"""
home_page.py - Page Object for HomeView (Customer dashboard)
Digipay iOS App
"""

from pages.base_page import BasePage


class HomePage(BasePage):
    """Customer home screen with wallet hero card, categories, merchants."""

    # Labels / Accessibility IDs
    WALLET_HEADER        = "REMAINING UPI BUDGET"
    SYNC_BTN             = "Sync Info"
    CATEGORIES_HEADER    = "Categories"
    NEARBY_MERCHANTS     = "Nearby Merchants"
    VIEW_ALL_BTN         = "View All"
    RECOMMENDED_HEADER   = "Recommended Merchant"
    AUTO_ID_BADGE        = "Auto-Identified"
    PAY_NOW_BTN          = "Pay Now"
    RADAR_ICON           = "antenna.radiowaves.left.and.right"
    REFRESH_INDICATOR    = "ProgressView"

    CATEGORIES = ["Cafe", "Restaurant", "Medical", "Grocery", "Retail", "Shopping", "Other"]

    # ─ Actions ────────────────────────────────────────────────────────────────

    def tap_sync(self):
        self.tap(self.SYNC_BTN)

    def tap_category(self, category: str):
        self.tap(category)

    def tap_view_all(self):
        self.tap(self.VIEW_ALL_BTN)

    def tap_pay_now(self):
        self.tap(self.PAY_NOW_BTN)

    def pull_to_refresh(self):
        size = self.driver.get_window_size()
        self.driver.swipe(
            size["width"] // 2, int(size["height"] * 0.25),
            size["width"] // 2, int(size["height"] * 0.75),
            800
        )

    # ─ Assertions ─────────────────────────────────────────────────────────────

    def is_home_visible(self) -> bool:
        return self.is_visible(self.WALLET_HEADER)

    def is_wallet_card_visible(self) -> bool:
        return self.is_visible(self.WALLET_HEADER)

    def is_radar_icon_visible(self) -> bool:
        return self.is_visible(self.RADAR_ICON)

    def is_categories_visible(self) -> bool:
        return self.is_visible(self.CATEGORIES_HEADER)

    def is_nearby_merchants_visible(self) -> bool:
        return self.is_visible(self.NEARBY_MERCHANTS)

    def is_recommended_merchant_visible(self) -> bool:
        return self.is_visible(self.RECOMMENDED_HEADER)

    def is_category_visible(self, category: str) -> bool:
        return self.is_visible(category)

    def is_pay_now_visible(self) -> bool:
        return self.is_visible(self.PAY_NOW_BTN)

    def get_wallet_balance_text(self) -> str:
        el = self.find_by_predicate(
            'label CONTAINS "₹" AND type == "XCUIElementTypeStaticText"'
        )
        return el.text

    def get_user_greeting_text(self) -> str:
        el = self.find_by_predicate('label CONTAINS "Hi,"')
        return el.text

    def is_location_text_visible(self) -> bool:
        return self.is_visible("📍")

    def all_categories_present(self) -> bool:
        return all(self.is_visible(cat, timeout=3) for cat in self.CATEGORIES)

    def is_view_all_visible(self) -> bool:
        return self.is_visible(self.VIEW_ALL_BTN)
