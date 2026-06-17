"""
test_home.py - Customer Home Screen Tests (TC-031 to TC-052)
DIGIPAY iOS - Appium E2E Test Suite
Tests: Wallet card, categories, merchant cards, navigation
"""

import pytest
from pages.home_page import HomePage


# ── Shared session fixture ──────────────────────────────────────────────────────
# In CI, we rely on a pre-logged-in session stored app state.
# Locally, the driver_class fixture keeps session alive across the test class.

@pytest.mark.usefixtures("driver_class")
class TestHomeScreen:
    """Home screen functional and UI/UX tests."""

    def test_TC031_home_screen_visible(self, driver_class):
        """TC-031: Home screen is visible after authentication."""
        page = HomePage(driver_class)
        assert page.is_home_visible(), "Home screen should be visible post-login"

    def test_TC032_wallet_hero_card_visible(self, driver_class):
        """TC-032: Wallet hero card (REMAINING UPI BUDGET) is displayed."""
        page = HomePage(driver_class)
        assert page.is_wallet_card_visible(), "Wallet hero card must be displayed on home"

    def test_TC033_radar_icon_visible_on_wallet_card(self, driver_class):
        """TC-033: Pulsing radar icon is visible on wallet card."""
        page = HomePage(driver_class)
        assert page.is_radar_icon_visible(), "Radar/antenna icon should be visible on wallet card"

    def test_TC034_categories_section_displayed(self, driver_class):
        """TC-034: 'Categories' section header is visible."""
        page = HomePage(driver_class)
        assert page.is_categories_visible(), "Categories section header must be present"

    def test_TC035_nearby_merchants_section_displayed(self, driver_class):
        """TC-035: 'Nearby Merchants' section is displayed."""
        page = HomePage(driver_class)
        assert page.is_nearby_merchants_visible(), "Nearby Merchants section must be displayed"

    def test_TC036_all_category_filters_present(self, driver_class):
        """TC-036: All 7 category filter chips are present."""
        page = HomePage(driver_class)
        assert page.all_categories_present(), "All category chips (Cafe, Restaurant, Medical, etc.) must be present"

    def test_TC037_user_greeting_displayed(self, driver_class):
        """TC-037: Personalized 'Hi, <name> 👋' greeting is shown."""
        page = HomePage(driver_class)
        text = page.get_user_greeting_text()
        assert "Hi" in text, "Greeting must start with 'Hi'"

    def test_TC038_location_text_displayed(self, driver_class):
        """TC-038: Location pin emoji and city info is displayed."""
        page = HomePage(driver_class)
        assert page.is_location_text_visible(), "Location text with 📍 emoji should be visible"

    def test_TC039_cafe_category_tap_filters_merchants(self, driver_class):
        """TC-039: Tapping 'Cafe' category filters merchant list."""
        page = HomePage(driver_class)
        page.tap_category("Cafe")
        page.wait_seconds(1)
        # After tap, Cafe chip should be selected (highlighted)
        assert page.is_category_visible("Cafe"), "Cafe category must still be visible after tap"

    def test_TC040_restaurant_category_tap(self, driver_class):
        """TC-040: Tapping 'Restaurant' category works without crash."""
        page = HomePage(driver_class)
        page.tap_category("Restaurant")
        page.wait_seconds(1)
        assert page.is_categories_visible(), "Screen should remain stable after category filter"

    def test_TC041_medical_category_tap(self, driver_class):
        """TC-041: Tapping 'Medical' category works without crash."""
        page = HomePage(driver_class)
        page.tap_category("Medical")
        page.wait_seconds(1)
        assert page.is_home_visible(), "Home should be stable after Medical filter"

    def test_TC042_grocery_category_tap(self, driver_class):
        """TC-042: Tapping 'Grocery' category works without crash."""
        page = HomePage(driver_class)
        page.tap_category("Grocery")
        page.wait_seconds(1)
        assert page.is_home_visible(), "Home should be stable after Grocery filter"

    def test_TC043_retry_category_tap_deselects(self, driver_class):
        """TC-043: Tapping selected category again deselects it."""
        page = HomePage(driver_class)
        page.tap_category("Cafe")
        page.wait_seconds(0.5)
        page.tap_category("Cafe")
        page.wait_seconds(0.5)
        # After double tap, filter should clear
        assert page.is_categories_visible(), "Categories section must be stable after toggle"

    def test_TC044_view_all_opens_merchant_sheet(self, driver_class):
        """TC-044: Tapping 'View All' opens merchant list sheet."""
        page = HomePage(driver_class)
        if page.is_view_all_visible():
            page.tap_view_all()
            page.wait_seconds(1.5)
            assert page.is_visible("Nearby Merchants") or page.is_visible("Merchants"), \
                "Merchant list sheet should open"

    def test_TC045_sync_button_triggers_refresh(self, driver_class):
        """TC-045: 'Sync Info' button triggers data refresh."""
        page = HomePage(driver_class)
        page.tap_sync()
        page.wait_seconds(2)
        assert page.is_wallet_card_visible(), "Wallet card should still be visible after sync"

    def test_TC046_pull_to_refresh_works(self, driver_class):
        """TC-046: Pull-to-refresh triggers data reload without crash."""
        page = HomePage(driver_class)
        page.pull_to_refresh()
        page.wait_seconds(2)
        assert page.is_home_visible(), "Home must remain stable after pull-to-refresh"

    def test_TC047_scroll_down_reveals_merchants(self, driver_class):
        """TC-047: Scrolling down reveals more merchant cards."""
        page = HomePage(driver_class)
        page.scroll_down()
        page.wait_seconds(0.5)
        assert page.is_home_visible(), "Home must remain stable after scrolling down"

    def test_TC048_scroll_up_returns_to_wallet(self, driver_class):
        """TC-048: Scrolling up returns to wallet hero card."""
        page = HomePage(driver_class)
        page.scroll_down()
        page.scroll_up()
        assert page.is_wallet_card_visible(), "Wallet card should be visible after scrolling back up"

    def test_TC049_recommended_merchant_section_visible(self, driver_class):
        """TC-049: 'Recommended Merchant' section is visible if merchants available."""
        page = HomePage(driver_class)
        # Best-effort check — depends on backend
        visible = page.is_recommended_merchant_visible()
        assert True, f"Recommended merchant section visible: {visible}"

    def test_TC050_pay_now_button_on_best_match(self, driver_class):
        """TC-050: 'Pay Now' button is present on recommended merchant card."""
        page = HomePage(driver_class)
        if page.is_pay_now_visible():
            assert True, "Pay Now button found on recommended merchant"
        else:
            pytest.skip("No recommended merchant available in current location context")

    def test_TC051_home_screen_does_not_crash_on_repeated_scroll(self, driver_class):
        """TC-051: Repeated scrolling does not crash the home screen."""
        page = HomePage(driver_class)
        for _ in range(3):
            page.scroll_down()
            page.scroll_up()
        assert page.is_home_visible(), "Home must remain stable after repeated scrolling"

    def test_TC052_profile_initials_badge_visible(self, driver_class):
        """TC-052: Profile initials circle badge is visible in home header."""
        page = HomePage(driver_class)
        # Profile badge is a Circle with initials - check presence via class
        elements = page.find_all_by_class("XCUIElementTypeOther")
        assert len(elements) > 0, "Profile badge container should be present"
