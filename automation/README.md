# Digipay Enterprise Appium iOS Test Automation Framework

This is a production-ready mobile automation framework built for the Digipay SwiftUI iOS application using Appium 2.x, WebDriverIO, Mocha, Chai, and the Page Object Model (POM) design pattern.

---

## 📁 Folder Structure

```
automation/
├── package.json                   # Node package config, scripts, and runners
├── wdio.conf.js                   # WebDriverIO central configuration hook definitions
├── README.md                      # Comprehensive framework documentation
├── appium/
│   ├── config/
│   │   └── env.js                 # Environment mappings (development/staging/production)
│   ├── capabilities/
│   │   └── ios.caps.js            # iOS device profile configurations
│   ├── pages/                     # Page Object Model selectors and reusable logic
│   │   ├── BasePage.js
│   │   ├── LoginPage.js
│   │   ├── HomePage.js
│   │   ├── WalletPage.js
│   │   ├── PaymentPage.js
│   │   ├── ExpenseIntelligencePage.js
│   │   ├── BudgetCoachPage.js
│   │   ├── ProfilePage.js
│   │   ├── SettingsPage.js
│   │   ├── MerchantPage.js
│   │   └── NavigationPage.js
│   └── tests/                     # 116 Unique E2E test cases mapped by module
│       ├── login/
│       │   └── auth.test.js
│       ├── wallet/
│       │   └── wallet.test.js
│       ├── payments/
│       │   └── payments.test.js
│       ├── expenseIntelligence/
│       │   └── expense.test.js
│       ├── budgetCoach/
│       │   └── budget.test.js
│       ├── profile/
│       │   └── profile.test.js
│       ├── settings/
│       │   └── settings.test.js
│       ├── navigation/
│       │   └── navigation.test.js
│       └── regression/
│           └── regression.test.js
├── utils/
│   ├── logger.js                  # Structured logs generation handler
│   ├── excelReporter.js           # Multi-sheet Excel workbook builder (exceljs)
│   └── reportRunner.js            # Programmatic test runner & mock driver fallback
└── fixtures/
    └── testData.js                # decoupled test configurations and coordinates
```

---

## ⚙️ Installation & Prerequisites

1. **Node.js**: Ensure Node.js v18+ is installed on your machine.
2. **Appium**: Install Appium 2.x and the XCUITest driver:
   ```bash
   npm install -g appium
   appium driver install xcuitest
   ```
3. **Project Dependencies**: Install project libraries:
   ```bash
   cd automation
   npm install
   ```

---

## 🔧 Environment Configurations

The framework supports multi-environment mapping via `NODE_ENV` configuration. The settings are defined in `appium/config/env.js`:
- **development**: Targets local emulator builds (`http://localhost:8000`).
- **staging**: Targets testing environments (`https://staging.digipay.in`).
- **production**: Targets Railway cloud services (`https://web-production-86613.up.railway.app`).

Set the target environment by prepending the command:
```bash
NODE_ENV=staging npm run test
```

---

## 🚀 Running Tests

### 1. WebDriverIO Live Execution
To execute tests against a running iOS Simulator and active Appium server:
```bash
npm run test
```

### 2. Standalone Programmatic Execution & Report Compilation
To run tests locally using the programmatic runner and mock driver fallback (perfect for compiling and generating reports instantly in headless or offline environments):
```bash
npm run report
```

### 3. Running Specific Modules
To run a single module spec, use standard WebdriverIO spec filters:
```bash
npx wdio run wdio.conf.js --spec appium/tests/login/auth.test.js
```

---

## 📊 Reports Generation

### Allure Report
1. Run WebdriverIO tests to generate JSON details in `reports/allure/`.
2. Compile results into an HTML report:
   ```bash
   npm run allure:generate
   ```
3. Open Allure in your default web browser:
   ```bash
   npm run allure:open
   ```

### Styled Excel Report
Running `npm run report` automatically outputs a styled, 7-sheet Excel spreadsheet report:
- **Location**: `reports/excel/E2E_Test_Report_Digipay_WDIO.xlsx`
- **Worksheets**:
  1. `Execution Summary` (Pass percentages, durations, visual meter charts, and deployability recomendations)
  2. `Smoke` (Role selections and startup verifications)
  3. `Functional` (Forms editing, logins, and settings adjustments)
  4. `Regression` (Background caching and offline database behaviors)
  5. `Validation` (Digit checks, boundaries, and blank submissions validations)
  6. `UI Testing` (Render layouts, typography, charts, and indicators)
  7. `End-to-End` (Full transactions, biometrics, and push alert notifications)

---

## 🤖 CI/CD Integration (GitHub Actions)

The repository includes a configured GitHub Actions workflow:
- **Location**: `.github/workflows/appium-tests.yml`
- **Runs on**: Push, Pull Request, and Workflow Dispatch.
- **Tasks**: Checkouts, installs Node, boots the target iOS simulator, builds the SwiftUI application, launches the Appium server, executes E2E scripts, compiles styled Excel and Allure reports, and uploads artifacts.

---

## 🛠️ Troubleshooting & Best Practices

- **WDA Connection Issues**: If Appium fails to communicate with the iOS Simulator, restart the Simulator and run:
  ```bash
  killall Simulator
  xcrun simctl erase all
  ```
- **Port Conflicts**: Ensure port `4723` is free:
  ```bash
  lsof -i :4723
  kill -9 <PID>
  ```
- **Locator Practices**: Always prefer **Accessibility Identifiers** (`~identifier`) to verify items. If nesting elements in SwiftUI, use `-ios predicate string:` or `-ios class chain:` configurations. Avoid using hardcoded XPaths.
