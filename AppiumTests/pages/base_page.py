"""
base_page.py - BasePage object for all Digipay screen interactions
Wraps common Appium / XCUITest element strategies.
"""

import time
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException


class BasePage:
    DEFAULT_WAIT = 15

    def __init__(self, driver):
        self.driver = driver

    # ── Element finders ────────────────────────────────────────────────────────

    def find_by_accessibility(self, label: str, timeout: int = DEFAULT_WAIT):
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((AppiumBy.ACCESSIBILITY_ID, label))
        )

    def find_by_predicate(self, predicate: str, timeout: int = DEFAULT_WAIT):
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((AppiumBy.IOS_PREDICATE, predicate))
        )

    def find_by_class(self, class_name: str, timeout: int = DEFAULT_WAIT):
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((AppiumBy.CLASS_NAME, class_name))
        )

    def find_by_xpath(self, xpath: str, timeout: int = DEFAULT_WAIT):
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((AppiumBy.XPATH, xpath))
        )

    def find_all_by_class(self, class_name: str):
        return self.driver.find_elements(AppiumBy.CLASS_NAME, class_name)

    def find_all_by_accessibility(self, label: str):
        return self.driver.find_elements(AppiumBy.ACCESSIBILITY_ID, label)

    # ── Interactions ───────────────────────────────────────────────────────────

    def tap(self, accessibility_id: str, timeout: int = DEFAULT_WAIT):
        el = self.find_by_accessibility(accessibility_id, timeout)
        el.click()

    def type_text(self, accessibility_id: str, text: str, timeout: int = DEFAULT_WAIT):
        el = self.find_by_accessibility(accessibility_id, timeout)
        el.clear()
        el.send_keys(text)

    def get_text(self, accessibility_id: str, timeout: int = DEFAULT_WAIT) -> str:
        el = self.find_by_accessibility(accessibility_id, timeout)
        return el.text

    def is_visible(self, accessibility_id: str, timeout: int = 5) -> bool:
        try:
            self.find_by_accessibility(accessibility_id, timeout)
            return True
        except (TimeoutException, NoSuchElementException):
            return False

    def is_element_enabled(self, accessibility_id: str) -> bool:
        try:
            el = self.find_by_accessibility(accessibility_id, 5)
            return el.is_enabled()
        except Exception:
            return False

    def wait_for_text(self, accessibility_id: str, expected_text: str, timeout: int = 15) -> bool:
        try:
            WebDriverWait(self.driver, timeout).until(
                lambda d: d.find_element(AppiumBy.ACCESSIBILITY_ID, accessibility_id).text == expected_text
            )
            return True
        except TimeoutException:
            return False

    def scroll_down(self, swipe_fraction: float = 0.4):
        size = self.driver.get_window_size()
        w, h = size["width"], size["height"]
        self.driver.swipe(w // 2, int(h * 0.7), w // 2, int(h * 0.7 - h * swipe_fraction), 500)

    def scroll_up(self, swipe_fraction: float = 0.4):
        size = self.driver.get_window_size()
        w, h = size["width"], size["height"]
        self.driver.swipe(w // 2, int(h * 0.3), w // 2, int(h * 0.3 + h * swipe_fraction), 500)

    def scroll_to_element(self, accessibility_id: str, max_scrolls: int = 5):
        for _ in range(max_scrolls):
            if self.is_visible(accessibility_id, timeout=2):
                return True
            self.scroll_down()
        return False

    def dismiss_keyboard(self):
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass

    def wait_seconds(self, seconds: float):
        time.sleep(seconds)

    def take_screenshot(self, name: str = "screenshot"):
        import os
        ss_dir = os.path.join(os.path.dirname(__file__), "..", "reports", "screenshots")
        os.makedirs(ss_dir, exist_ok=True)
        path = os.path.join(ss_dir, f"{name}_{int(time.time())}.png")
        self.driver.save_screenshot(path)
        return path

    def get_page_source(self) -> str:
        return self.driver.page_source

    def get_current_activity(self) -> str:
        try:
            return self.driver.current_activity
        except Exception:
            return ""

    # ── Alert handling ─────────────────────────────────────────────────────────

    def accept_alert(self, timeout: int = 5):
        try:
            WebDriverWait(self.driver, timeout).until(EC.alert_is_present())
            self.driver.switch_to.alert.accept()
        except TimeoutException:
            pass

    def dismiss_alert(self, timeout: int = 5):
        try:
            WebDriverWait(self.driver, timeout).until(EC.alert_is_present())
            self.driver.switch_to.alert.dismiss()
        except TimeoutException:
            pass

    def get_alert_text(self, timeout: int = 5) -> str:
        try:
            WebDriverWait(self.driver, timeout).until(EC.alert_is_present())
            return self.driver.switch_to.alert.text
        except TimeoutException:
            return ""
