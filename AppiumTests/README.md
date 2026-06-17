# 🍎 Digipay iOS — Appium E2E Test Suite

> **160+ unique test cases** covering UI/UX, Functional, Validation, Unit-level, Accessibility, and Regression testing for the Digipay iOS mobile application.

---

## 📁 Folder Structure

```
AppiumTests/
├── conftest.py               # Pytest config, Appium fixtures, Excel report hooks
├── pytest.ini                # Test discovery settings and markers
├── requirements.txt          # Python dependencies
├── .env.example              # Environment variables template
│
├── pages/                    # Page Object Model (POM)
│   ├── base_page.py          # BasePage with common helpers
│   ├── login_page.py         # Role Selection + Login screens
│   ├── otp_page.py           # OTP Verification screen
│   ├── home_page.py          # Customer Home screen
│   ├── wallet_page.py        # Wallet Intelligence screen
│   ├── payment_page.py       # Amount Entry / Send Money screen
│   ├── profile_page.py       # Profile screen
│   └── merchant_page.py      # Merchant Home + Payments History
│
├── tests/
│   ├── auth/
│   │   ├── test_login.py     # TC-001 → TC-018 (Authentication)
│   │   └── test_otp.py       # TC-019 → TC-030 (OTP Verification)
│   ├── home/
│   │   └── test_home.py      # TC-031 → TC-052 (Home Screen)
│   ├── wallet/
│   │   └── test_wallet.py    # TC-053 → TC-070 (Wallet Intelligence)
│   ├── payment/
│   │   └── test_payment.py   # TC-071 → TC-086 (Payment Flow)
│   ├── profile/
│   │   └── test_profile.py   # TC-087 → TC-104 (Profile Screen)
│   ├── navigation/
│   │   └── test_navigation.py # TC-105 → TC-118 (Navigation / UI)
│   ├── validation/
│   │   └── test_validation.py # TC-119 → TC-129 (Input Validation)
│   ├── ui/
│   │   └── test_accessibility.py # TC-130 → TC-143 (Accessibility)
│   └── regression/
│       └── test_regression.py    # TC-144 → TC-160 (E2E Regression)
│
├── utils/
│   └── excel_reporter.py     # Excel report generator (openpyxl)
│
└── reports/                  # Auto-generated (gitignored)
    ├── Digipay_Appium_Report_<timestamp>.xlsx
    └── screenshots/
```

---

## 📊 Test Case Summary

| Suite | Range | Count | Category |
|-------|-------|-------|----------|
| Authentication | TC-001 – TC-018 | 18 | Functional + UI |
| OTP Verification | TC-019 – TC-030 | 12 | Functional + Validation |
| Home Screen | TC-031 – TC-052 | 22 | Functional + UI/UX |
| Wallet Intelligence | TC-053 – TC-070 | 18 | Functional + UI/UX |
| Payment Flow | TC-071 – TC-086 | 16 | Functional + E2E |
| Profile Screen | TC-087 – TC-104 | 18 | Functional + UI/UX |
| Navigation | TC-105 – TC-118 | 14 | UI/UX |
| Validation | TC-119 – TC-129 | 11 | Validation |
| Accessibility | TC-130 – TC-143 | 14 | Accessibility |
| E2E Regression | TC-144 – TC-160 | 17 | Regression + E2E |
| **TOTAL** | **TC-001 – TC-160** | **160** | **All categories** |

---

## 🚀 Quick Start (Local)

### 1. Prerequisites

- macOS with Xcode 15+
- Node.js 20+
- Python 3.12+
- An iPhone Simulator (iOS 17+)

### 2. Install Appium

```bash
npm install -g appium@2.4.1
appium driver install xcuitest@4.35.0
```

### 3. Build the iOS App for Simulator

```bash
xcodebuild build \
  -project Digipay.xcodeproj \
  -scheme Digipay \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=17.0" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### 4. Install Python dependencies

```bash
cd AppiumTests
pip install -r requirements.txt
```

### 5. Configure environment

```bash
cp .env.example .env
# Edit .env with your APP_PATH and simulator settings
```

### 6. Start Appium Server

```bash
appium --port 4723
```

### 7. Run tests

```bash
# Run all 160 tests
cd AppiumTests
python -m pytest tests/ -v

# Run specific suite
python -m pytest tests/auth/ -v
python -m pytest tests/home/ -v
python -m pytest tests/wallet/ -v
python -m pytest tests/payment/ -v
python -m pytest tests/profile/ -v
python -m pytest tests/navigation/ -v
python -m pytest tests/validation/ -v
python -m pytest tests/ui/ -v
python -m pytest tests/regression/ -v

# Run by marker
python -m pytest -m "smoke" -v
python -m pytest -m "regression" -v
```

### 8. View Excel Report

After running, check:
```
AppiumTests/reports/Digipay_Appium_Report_<timestamp>.xlsx
```

The Excel workbook contains:
- 📊 **Dashboard** — KPI cards (Total/Pass/Fail/Rate) + Pie chart
- 📋 **Test Details** — Full test result table with filtering
- 🗂️ **Per-Category sheets** — Auth, Functional, UI/UX, Validation, etc.
- 🔴 **Failures** — Dedicated sheet for failed/errored tests

---

## ☁️ GitHub Actions CI

The workflow at `.github/workflows/appium-tests.yml` provides:

- **Parallel matrix runs** — each suite runs independently
- **Automatic iOS Simulator provisioning**
- **Xcode build + app installation**
- **Appium server lifecycle management**
- **Excel report artifacts** (retained 90 days)
- **PR comment** with test status summary

### Trigger Options

| Trigger | Behavior |
|---------|----------|
| `push` to `main`/`develop` | Runs all suites |
| `pull_request` | Runs all suites + posts PR comment |
| `workflow_dispatch` | Manual run with suite/device selection |

---

## 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APPIUM_HOST` | `http://127.0.0.1` | Appium server host |
| `APPIUM_PORT` | `4723` | Appium server port |
| `IOS_VERSION` | `17.0` | Target iOS version |
| `IOS_DEVICE_NAME` | `iPhone 15` | Simulator name |
| `APP_BUNDLE_ID` | `com.supreeth.Digipay` | App bundle identifier |
| `APP_PATH` | *(empty)* | Path to `.app` bundle |
