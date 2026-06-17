"""
conftest.py - Appium iOS Test Configuration & Fixtures
DIGIPAY Mobile Application - End-to-End Test Suite
"""

import pytest
import os
import time
import datetime
from appium import webdriver
from appium.options import XCUITestOptions

# ─── Excel Reporter ────────────────────────────────────────────────────────────
from utils.excel_reporter import ExcelReporter

# Global results store (populated during test run)
_RESULTS: list[dict] = []
_START_TIME: float = 0.0

# ─── Pytest Hooks ─────────────────────────────────────────────────────────────

def pytest_configure(config):
    """Called after command line options have been parsed."""
    global _START_TIME
    _START_TIME = time.time()


def pytest_runtest_logreport(report):
    """Collect pass/fail/error data for every test phase."""
    if report.when == "call":
        status = "PASS" if report.passed else ("FAIL" if report.failed else "ERROR")
        duration = round(getattr(report, "duration", 0), 3)

        # Extract category & module from nodeid  e.g. tests/auth/test_login.py::TestLogin::test_valid_phone
        parts = report.nodeid.split("::")
        module = parts[0].replace("tests/", "").replace(".py", "").replace("/", " > ")
        test_name = parts[-1] if len(parts) >= 2 else report.nodeid
        class_name = parts[1] if len(parts) >= 3 else ""

        category = _derive_category(module)

        _RESULTS.append(
            {
                "Test ID": f"TC-{len(_RESULTS) + 1:03d}",
                "Module": module,
                "Class": class_name,
                "Test Name": test_name,
                "Category": category,
                "Status": status,
                "Duration (s)": duration,
                "Error Message": str(report.longreprtext)[:300] if report.failed else "",
                "Timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            }
        )


def _derive_category(module: str) -> str:
    mapping = {
        "auth": "Authentication",
        "login": "Authentication",
        "otp": "Authentication",
        "home": "Functional",
        "wallet": "Functional",
        "payment": "Functional",
        "merchant": "Functional",
        "profile": "Functional",
        "navigation": "UI/UX",
        "ui": "UI/UX",
        "ux": "UI/UX",
        "accessibility": "UI/UX",
        "discover": "Functional",
        "validation": "Validation",
        "unit": "Unit",
        "performance": "Performance",
        "security": "Security",
        "regression": "Regression",
    }
    for key, cat in mapping.items():
        if key in module.lower():
            return cat
    return "General"


def pytest_sessionfinish(session, exitstatus):
    """Generate Excel report after the full test session ends."""
    total_time = round(time.time() - _START_TIME, 2)
    reports_dir = os.path.join(os.path.dirname(__file__), "reports")
    os.makedirs(reports_dir, exist_ok=True)

    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_path = os.path.join(reports_dir, f"Digipay_Appium_Report_{timestamp}.xlsx")

    reporter = ExcelReporter(results=_RESULTS, total_duration=total_time)
    reporter.generate(output_path)
    print(f"\n📊 Excel Report saved → {output_path}")


# ─── Appium Driver Fixtures ────────────────────────────────────────────────────

def _build_options() -> XCUITestOptions:
    opts = XCUITestOptions()
    opts.platform_name = "iOS"
    opts.platform_version = os.getenv("IOS_VERSION", "17.0")
    opts.device_name = os.getenv("IOS_DEVICE_NAME", "iPhone 15")
    opts.bundle_id = os.getenv("APP_BUNDLE_ID", "com.supreeth.Digipay")
    opts.automation_name = "XCUITest"
    opts.no_reset = False
    opts.full_reset = False
    opts.new_command_timeout = 120
    opts.wda_launch_timeout = 60000
    opts.wda_connection_timeout = 60000
    # Simulator: build & run from derived data
    app_path = os.getenv("APP_PATH", "")
    if app_path:
        opts.app = app_path
    return opts


@pytest.fixture(scope="session")
def appium_server_url():
    host = os.getenv("APPIUM_HOST", "http://127.0.0.1")
    port = os.getenv("APPIUM_PORT", "4723")
    return f"{host}:{port}"


@pytest.fixture(scope="function")
def driver(appium_server_url):
    """Fresh driver per test – ensures clean app state."""
    opts = _build_options()
    drv = webdriver.Remote(appium_server_url, options=opts)
    drv.implicitly_wait(10)
    yield drv
    drv.quit()


@pytest.fixture(scope="class")
def driver_class(appium_server_url):
    """Shared driver per test class – faster for grouped tests."""
    opts = _build_options()
    drv = webdriver.Remote(appium_server_url, options=opts)
    drv.implicitly_wait(10)
    yield drv
    drv.quit()


# ─── Helper Fixtures ──────────────────────────────────────────────────────────

@pytest.fixture()
def screenshot_on_failure(driver, request):
    """Automatically capture screenshot when a test fails."""
    yield
    if request.node.rep_call.failed:
        ss_dir = os.path.join(os.path.dirname(__file__), "reports", "screenshots")
        os.makedirs(ss_dir, exist_ok=True)
        name = request.node.name.replace(" ", "_")
        path = os.path.join(ss_dir, f"{name}_{int(time.time())}.png")
        driver.save_screenshot(path)
        print(f"📸 Screenshot saved → {path}")


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)
