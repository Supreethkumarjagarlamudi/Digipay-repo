"""
test_03_dashboard.py — Dashboard Portal functional tests for Digipay.
Tests admin dashboard KPIs, tabs, sidebar navigation, and logout.
"""

import time
import pytest
import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import FRONTEND_URL, BACKEND_URL, ADMIN_PHONE, wait_for_visible


def do_admin_login(driver):
    """
    Full login helper: navigate → phone → OTP → dashboard.
    Returns when the dashboard body is loaded.
    """
    driver.get(FRONTEND_URL)
    WebDriverWait(driver, 20).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="login-nav-button"]'))
    )
    driver.find_element(By.CSS_SELECTOR, '[data-testid="login-nav-button"]').click()
    wait_for_visible(driver, By.CSS_SELECTOR, '[data-testid="phone-input"]')

    # Enter phone
    driver.find_element(By.CSS_SELECTOR, '[data-testid="phone-input"]').send_keys(ADMIN_PHONE)
    driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()

    # Wait for OTP hint
    WebDriverWait(driver, 25).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '[data-testid="otp-help-block"]'))
    )
    hint_text = driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-help-block"]').text
    otp_code = "".join(filter(str.isdigit, hint_text))[-6:]

    # Enter OTP
    driver.find_element(By.CSS_SELECTOR, '[data-testid="otp-input"]').send_keys(otp_code)
    driver.find_element(By.CSS_SELECTOR, '[data-testid="login-button"]').click()

    # Wait for dashboard
    WebDriverWait(driver, 30).until(
        lambda d: "Secure Login Portal" not in d.find_element(By.TAG_NAME, "body").text
        and len(d.find_element(By.TAG_NAME, "body").text.strip()) > 50
    )
    time.sleep(2)  # Allow dashboard components to fully render


class TestAdminDashboard:
    """Functional tests for the Digipay Dashboard Portal (admin role)."""

    @pytest.fixture(scope="class", autouse=True)
    def login_once(self, driver):
        """Login as admin once for the entire class of tests."""
        do_admin_login(driver)
        self.driver = driver

    # ── 1. Dashboard Load ───────────────────────────────────────────────────

    def test_dashboard_body_loaded(self, driver):
        """Dashboard body should be non-empty after login."""
        body = driver.find_element(By.TAG_NAME, "body").text.strip()
        assert len(body) > 50, "Dashboard page body appears empty after login."

    def test_dashboard_shows_admin_name(self, driver):
        """Admin name 'Global Administrator' should appear in the dashboard."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "Administrator" in body_text or "Admin" in body_text, \
            "Admin name not visible on dashboard after login."

    def test_digipay_brand_visible_on_dashboard(self, driver):
        """DIGIPAY brand text should be visible on the dashboard."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "DIGIPAY" in body_text or "Digipay" in body_text, \
            "DIGIPAY brand not visible on dashboard."

    # ── 2. KPI / Stats Cards ────────────────────────────────────────────────

    def test_kpi_cards_render(self, driver):
        """Admin KPI cards (numbers/stats) should be visible on the dashboard."""
        # Look for numeric content that would indicate KPI cards are present
        body_text = driver.find_element(By.TAG_NAME, "body").text
        # The dashboard shows counts/totals — at least some numbers should be there
        import re
        numbers = re.findall(r'\d+', body_text)
        assert len(numbers) >= 3, \
            "Dashboard KPI cards don't appear to show any numeric statistics."

    def test_revenue_or_transaction_info_visible(self, driver):
        """Revenue or transaction-related text should be visible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text.lower()
        assert (
            "revenue" in body_text
            or "transaction" in body_text
            or "merchant" in body_text
            or "user" in body_text
        ), "No revenue/transaction/merchant KPI info visible on admin dashboard."

    # ── 3. Sidebar / Navigation Tabs ────────────────────────────────────────

    def test_sidebar_navigation_renders(self, driver):
        """Sidebar/navigation should be visible with navigation options."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        # Check for common dashboard nav items
        nav_keywords = ["Wallet", "Merchant", "Analytics", "Dashboard", "Logout", "Sign Out"]
        found = [kw for kw in nav_keywords if kw in body_text]
        assert len(found) >= 2, \
            f"Sidebar navigation seems missing. Found only: {found}"

    def test_logout_option_visible(self, driver):
        """Logout/Sign Out option should be visible in the sidebar or header."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert "Logout" in body_text or "Sign Out" in body_text or "Log Out" in body_text, \
            "No Logout/Sign Out option found on dashboard."

    # ── 4. Tab Content ──────────────────────────────────────────────────────

    def test_wallet_tab_content_accessible(self, driver):
        """Wallet-related content or tab should be accessible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert (
            "Wallet" in body_text
            or "Balance" in body_text
            or "Transaction" in body_text
            or "Expense" in body_text
        ), "Wallet/Balance content is not visible on dashboard."

    def test_merchant_info_accessible(self, driver):
        """Merchant-related content or tab should be accessible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert (
            "Merchant" in body_text
            or "Business" in body_text
            or "Store" in body_text
        ), "Merchant/Business content is not visible on admin dashboard."

    def test_analytics_section_accessible(self, driver):
        """Analytics or chart-related content should be accessible."""
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert (
            "Analytics" in body_text
            or "Chart" in body_text
            or "Trend" in body_text
            or "Revenue" in body_text
        ), "Analytics section content not found on admin dashboard."

    # ── 5. Logout Flow ──────────────────────────────────────────────────────

    def test_logout_returns_to_landing(self, driver):
        """Clicking logout should navigate back to the landing page."""
        body_text = driver.find_element(By.TAG_NAME, "body").text

        # Find and click the logout button/link
        all_buttons = driver.find_elements(By.TAG_NAME, "button")
        logout_btn = None
        for btn in all_buttons:
            txt = btn.text.strip().lower()
            if "logout" in txt or "sign out" in txt or "log out" in txt:
                logout_btn = btn
                break

        if logout_btn is None:
            # Try links too
            all_links = driver.find_elements(By.TAG_NAME, "a")
            for link in all_links:
                txt = link.text.strip().lower()
                if "logout" in txt or "sign out" in txt:
                    logout_btn = link
                    break

        assert logout_btn is not None, \
            "Logout button/link not found. Cannot test logout flow."

        logout_btn.click()
        time.sleep(2)

        post_logout_body = driver.find_element(By.TAG_NAME, "body").text
        assert (
            "Open Web Portal" in post_logout_body
            or "UPI Payments" in post_logout_body
            or "DIGIPAY" in post_logout_body
        ), "After logout, landing page did not appear."
        # Must NOT still show the dashboard content
        assert "Global Administrator" not in post_logout_body, \
            "Admin username still visible after logout — session not cleared."
