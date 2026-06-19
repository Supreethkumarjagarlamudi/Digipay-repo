# Digipay iOS Appium Automation Framework (TypeScript + WebdriverIO)

This directory contains the production-ready automation testing pipeline for the Digipay iOS application. It is built using **WebdriverIO** and **Appium** with **TypeScript** support and parses test results into structured executive PDF summaries and spreadsheet data reports.

---

## 📂 Folder Structure

```text
mobile-testing/
└── appium/
    ├── config/
    │   └── wdio.conf.ts           # WebdriverIO capabilities and execution hooks
    ├── pages/                     # Page Object Model (POM) classes
    │   ├── base_page.ts           # Shared UI action wrappers
    │   ├── login_page.ts          # Authenticate inputs and selectors
    │   ├── otp_page.ts            # Verification view elements
    │   ├── home_page.ts           # Customer dashboard view
    │   ├── wallet_page.ts         # Transactions tracker
    │   ├── payment_page.ts        # Payment processing flow elements
    │   ├── profile_page.ts        # Setting profile parameter values
    │   └── merchant_page.ts       # Registration dashboard
    ├── tests/                     # 115+ TypeScript automated cases
    │   ├── smoke/                 # Core startup and smoke tests
    │   ├── functional/            # Interactive workflows
    │   ├── uiux/                  # Layout and spacing checks
    │   ├── validation/            # Boundaries and invalid parameters inputs
    │   ├── navigation/            # Tab routing and landing sequences
    │   ├── regression/            # System-wide regression suites
    │   ├── performance/           # Speed benchmarks
    │   └── accessibility/         # VoiceOver label verification
    ├── utilities/                 # Analytical report generators
    │   ├── logger.ts              # Winston structured logging
    │   └── report_compiler.ts     # Excel & PDF compiler script
    ├── package.json               # NPM package dependencies
    ├── tsconfig.json              # TypeScript compilation setup
    └── README.md                  # Documentation (this file)
```

---

## 🛠️ Installation & Setup

1. **Install Node.js** (Node 22 is recommended).
2. **Install Appium** globally:
   ```bash
   npm install -g appium@2.11.5
   ```
3. **Install XCUITest Driver** globally:
   ```bash
   appium driver install xcuitest@7.26.4
   ```
4. **Install Framework Dependencies**:
   ```bash
   cd mobile-testing/appium
   npm install
   ```

---

## 🚀 Execution & Report Compilation

### 1. Compile TypeScript
To compile the test scripts:
```bash
npm run compile
```

### 2. Launch Appium Server
Start Appium on the default port:
```bash
appium --port 4723 --relaxed-security
```

### 3. Run Tests
You can run all suites or specific suite runs:
```bash
# Run all suites
npm run test

# Run smoke tests
npm run test:smoke

# Run regression tests
npm run test:regression
```

### 4. Compile Excel & PDF Reports
Run the compiler standalone to bundle the output JSON results into formatted PDF reports and Excel spreadsheets:
```bash
npm run generate-reports
```
Reports will be output to:
- **Excel Spreadsheet**: `reports/excel/test_analytics.xlsx`
- **PDF Executive Summary**: `reports/pdf/executive_summary.pdf`
- **Screenshots**: Failure screenshots saved automatically to `reports/screenshots/`
- **Logs**: Winston log file saved to `reports/logs/execution.log`

---

## 🐳 CI/CD Integration

The workflow config file is located at `.github/workflows/appium-tests.yml`. When you push to the `main` branch, the pipeline will automatically:
1. Boot the macOS simulator.
2. Build the `.app` using xcodebuild.
3. Launch Appium server.
4. Execute WebdriverIO Mocha test suites.
5. Generate Excel and PDF analytics summaries.
6. Upload the reports as standard GitHub execution artifacts.

---

## 💡 Best Practices & Maintenance

- **Adding a Test**: Create a new `.ts` spec file under `tests/<category>/`. Add standard mocha `describe()` blocks with the proper TC-XXX metadata standard.
- **Modifying Locators**: If selectors in the app change, update them in the corresponding file in `pages/` (POM structure).
- **Screenshots**: The afterTest hook inside `wdio.conf.ts` automatically captures screenshots on failure. Do not manually capture screenshots inside tests.
- **Reporting**: `report_compiler.ts` handles styled columns, backgrounds, and conditional text formatting using standard ARGB codes.
