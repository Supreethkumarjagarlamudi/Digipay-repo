"""
test_01_landing.py — Landing Page functional tests for Digipay.
"""

import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import FRONTEND_URL, wait_for_visible


class TestLandingPage:
    """All tests for the Digipay landing page."""

    @pytest.fixture(autouse=True)
    def navigate(self, driver):
        """Navigate to landing page before each test."""
        driver.get(FRONTEND_URL)
        # Wait for page to load — look for the header
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.TAG_NAME, "header"))
        )
        self.driver = driver

    # ── 1. Page Load ────────────────────────────────────────────────────────

    def test_page_loads_successfully(self, driver):
        """Landing page returns a loaded state (body is non-empty)."""
        body = driver.find_element(By.TAG_NAME, "body").text.strip()
        assert len(body) > 20, \
            "Landing page body appears empty — page may have failed to load."

    def test_page_title_contains_digipay(self, driver):
        """Browser tab title should contain 'DIGIPAY' or 'Digipay'."""
        title = driver.title
        assert "digipay" in title.lower() or "DIGIPAY" in title, \
            f"Page title '{title}' does not contain DIGIPAY."

    # ── 2. Brand / Hero ─────────────────────────────────────────────────────

    def test_hero_heading_visible(self, driver):
        """The main <h1> element should be visible on the landing page."""
        h1 = wait_for_visible(driver, By.TAG_NAME, "h1")
        assert h1.is_displayed(), "Hero <h1> heading is not displayed."

    def test_hero_heading_contains_upi(self, driver):
        """Hero heading should mention 'UPI Payments'."""
        h1 = driver.find_element(By.TAG_NAME, "h1")
        text = h1.text
        assert "UPI" in text or "Payments" in text, \
            f"Hero heading does not mention UPI/Payments. Got: '{text}'"

    def test_brand_logo_text_visible(self, driver):
        """DIGIPAY brand logo/name should appear in the header."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "DIGIPAY" in body_text, \
            "Brand name 'DIGIPAY' is not visible on the landing page."

    def test_hero_subtext_visible(self, driver):
        """Hero description paragraph should be present."""
        paras = driver.find_elements(By.TAG_NAME, "p")
        combined = " ".join([p.text for p in paras])
        assert "DIGIPAY" in combined or "UPI" in combined or "payment" in combined.lower(), \
            "No descriptive paragraph found in landing page body."

    # ── 3. Navigation Buttons ────────────────────────────────────────────────

    def test_signin_button_exists(self, driver):
        """'Sign In' button should be present in the header nav."""
        btn = driver.find_element(By.CSS_SELECTOR, '[data-testid="login-nav-button"]')
        assert btn.is_displayed(), "Sign In nav button is not displayed."
        assert "Sign In" in btn.text or "sign" in btn.text.lower(), \
            f"Sign In button text mismatch: '{btn.text}'"

    def test_go_to_console_button_exists(self, driver):
        """'Go to Console' button should be present in the header nav."""
        btn = driver.find_element(By.CSS_SELECTOR, '[data-testid="login-nav-admin"]')
        assert btn.is_displayed(), "Go to Console nav button is not displayed."
        assert "Console" in btn.text or "Go" in btn.text, \
            f"Console button text mismatch: '{btn.text}'"

    def test_open_web_portal_cta_exists(self, driver):
        """'Open Web Portal' CTA button should be in the hero section."""
        btn = driver.find_element(By.CSS_SELECTOR, 'main [data-testid="login-button"]')
        assert btn.is_displayed(), "Open Web Portal CTA button is not displayed."

    def test_launch_ios_app_link_exists(self, driver):
        """'Launch iOS App' link should be present in the hero section."""
        link = driver.find_element(By.CSS_SELECTOR, '[data-testid="open-app-link"]')
        assert link.is_displayed(), "Launch iOS App link is not displayed."
        assert "Launch" in link.text or "iOS" in link.text, \
            f"iOS link text mismatch: '{link.text}'"

    # ── 4. Feature Section ──────────────────────────────────────────────────

    def test_features_section_heading_visible(self, driver):
        """The 'Intelligent Context Engine' features section heading should appear."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "Intelligent Context Engine" in body_text, \
            "Features section heading 'Intelligent Context Engine' is missing."

    def test_digipin_feature_card_visible(self, driver):
        """'DIGIPIN Address Translation' feature card should be visible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "DIGIPIN" in body_text, \
            "'DIGIPIN Address Translation' feature card is missing."

    def test_heading_speed_scoring_feature_visible(self, driver):
        """'Heading & Speed Scoring' feature card should be visible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "Heading" in body_text and "Speed" in body_text, \
            "'Heading & Speed Scoring' feature card content is missing."

    def test_autonomous_categorization_feature_visible(self, driver):
        """'Autonomous Categorization' feature card should be visible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "Autonomous Categorization" in body_text or "Categorization" in body_text, \
            "'Autonomous Categorization' feature card is missing."

    # ── 5. Footer ───────────────────────────────────────────────────────────

    def test_footer_copyright_visible(self, driver):
        """Footer should contain the copyright notice."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "2026" in body_text or "DIGIPAY" in body_text, \
            "Footer copyright text (2026 / DIGIPAY) is missing."

    # ── 6. Navigation Flow ──────────────────────────────────────────────────

    def test_signin_button_navigates_to_login(self, driver):
        """Clicking 'Sign In' should render the login portal."""
        btn = driver.find_element(By.CSS_SELECTOR, '[data-testid="login-nav-button"]')
        btn.click()
        # Wait for phone input to appear
        wait_for_visible(driver, By.CSS_SELECTOR, '[data-testid="phone-input"]')
        phone_input = driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]')
        assert phone_input.is_displayed(), \
            "Clicking Sign In did not navigate to the login portal."
