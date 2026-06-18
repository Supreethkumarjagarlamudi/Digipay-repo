import * as path from 'path';
import * as fs from 'fs';
import { logger } from '../utilities/logger';

// Ensure necessary directories exist
const createDirectory = (dirPath: string) => {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
};

const reportsDir = path.join(__dirname, '../reports');
createDirectory(reportsDir);
createDirectory(path.join(reportsDir, 'screenshots'));
createDirectory(path.join(reportsDir, 'logs'));
createDirectory(path.join(reportsDir, 'excel'));
createDirectory(path.join(reportsDir, 'json'));
createDirectory(path.join(reportsDir, 'pdf'));

// ─── Device Mode ─────────────────────────────────────────────────────────────
// Set DEVICE=real to test on connected iPhone, or leave unset for simulator.
const isRealDevice = process.env.DEVICE === 'real';

// ─── Physical Device Config ───────────────────────────────────────────────────
const REAL_DEVICE_UDID    = process.env.DEVICE_UDID   || '00008140-0002301626FB001C';  // iPhone 16 Pro Max
const REAL_DEVICE_NAME    = process.env.DEVICE_NAME   || 'Supreeth kumar\'s iPhone';
const REAL_IOS_VERSION    = process.env.IOS_VERSION   || '26.5';
const REAL_APP_PATH       = process.env.APP_PATH      || path.join('/Users/supreethkumarjagarlamudi/Library/Developer/Xcode/DerivedData/Build/Products/Debug-iphoneos/Digipay.app');

// ─── Simulator Config ─────────────────────────────────────────────────────────
const SIM_UDID            = process.env.SIMULATOR_UDID || '42583C5A-BB47-45FB-A0DE-B007BFC9FA60';
const SIM_DEVICE_NAME     = process.env.IOS_DEVICE_NAME || 'iPhone 17';
const SIM_IOS_VERSION     = process.env.IOS_VERSION   || '18.6';
const SIM_APP_PATH        = process.env.APP_PATH      || path.join('/Users/supreethkumarjagarlamudi/Library/Developer/Xcode/DerivedData/Build/Products/Debug-iphonesimulator/Digipay.app');

// ─── Active Values ────────────────────────────────────────────────────────────
const appPath       = isRealDevice ? REAL_APP_PATH    : SIM_APP_PATH;
const udid          = isRealDevice ? REAL_DEVICE_UDID : SIM_UDID;
const platformVersion = isRealDevice ? REAL_IOS_VERSION : SIM_IOS_VERSION;
const deviceName    = isRealDevice ? REAL_DEVICE_NAME : SIM_DEVICE_NAME;

// Simulator-only: permissions are pre-granted via xcrun simctl privacy in beforeSession, so we do not use appium:permissions (which requires applesimutils)
const simulatorPermissions = {};

// Real device only: code signing (WDA must be signed)
const realDeviceExtras = isRealDevice ? {
    'appium:xcodeOrgId': process.env.XCODE_ORG_ID || '8KLF3MC9TN',
    'appium:xcodeSigningId': 'iPhone Developer',
    'appium:updatedWDABundleId': 'com.supreethKumarj.WebDriverAgentRunner',
} : {};

interface TestResult {
    id: string;
    name: string;
    suite: string;
    duration: number;
    status: 'PASSED' | 'FAILED' | 'SKIPPED';
    error?: string;
    screenshot?: string;
    timestamp: string;
}

const testResults: TestResult[] = [];

declare const browser: any;

export const config: WebdriverIO.Config = {
    runner: 'local',
    port: parseInt(process.env.APPIUM_PORT || '4723'),
    path: '/',
    specs: [
        '../tests/**/*.ts'
    ],
    exclude: [],
    maxInstances: 1,
    capabilities: [{
        platformName: 'iOS',
        'appium:deviceName': deviceName,
        'appium:platformVersion': platformVersion,
        'appium:automationName': 'XCUITest',
        'appium:app': appPath,
        'appium:udid': udid,
        'appium:newCommandTimeout': 240,
        'appium:wdaLaunchTimeout': 180000,
        'appium:wdaConnectionTimeout': 180000,
        'appium:autoAcceptAlerts': false,
        'appium:relaxedSecurityEnabled': true,
        ...simulatorPermissions,
        ...realDeviceExtras
    } as any],
    logLevel: 'info',
    bail: 0,
    baseUrl: 'http://127.0.0.1',
    waitforTimeout: 30000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    services: [],
    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 120000
    },
    
    suites: {
        smoke: ['../tests/smoke/**/*.ts'],
        functional: ['../tests/functional/**/*.ts'],
        uiux: ['../tests/uiux/**/*.ts'],
        validation: ['../tests/validation/**/*.ts'],
        navigation: ['../tests/navigation/**/*.ts'],
        regression: ['../tests/regression/**/*.ts'],
        performance: ['../tests/performance/**/*.ts'],
        accessibility: ['../tests/accessibility/**/*.ts']
    },

    beforeSession: function () {
        const { execSync } = require('child_process');
        const bundleId = 'com.supreethKumarj.Digipay';
        const simulatorUdid = udid || '42583C5A-BB47-45FB-A0DE-B007BFC9FA60';
        // Pre-grant location and notification permissions so dialogs never appear during tests
        try {
            execSync(`xcrun simctl privacy ${simulatorUdid} grant location-always ${bundleId}`, { stdio: 'ignore' });
            logger.info(`Pre-granted location-always for ${bundleId}`);
        } catch (e: any) {
            logger.info(`simctl location grant skipped: ${e.message}`);
        }
        try {
            execSync(`xcrun simctl privacy ${simulatorUdid} grant notifications ${bundleId}`, { stdio: 'ignore' });
            logger.info(`Pre-granted notifications for ${bundleId}`);
        } catch (e: any) {
            logger.info(`simctl notifications grant skipped: ${e.message}`);
        }
        logger.info(`Starting test runner session on Device: ${deviceName}, UDID: ${simulatorUdid}, iOS: ${platformVersion}`);
    },

    before: async function (capabilities, specs) {
        const isNavigationSpec = specs && specs.some(spec => spec.includes('test_navigation'));
        if (!isNavigationSpec) {
            logger.info("Non-navigation spec detected. Attempting to bypass onboarding...");
            try {
                await browser.pause(3000);
                const skipBtn = await browser.$('~Skip');
                if (await skipBtn.isDisplayed()) {
                    await skipBtn.click();
                    logger.info("Successfully bypassed onboarding via ~Skip");
                    await browser.pause(1000);
                }
            } catch (err: any) {
                logger.info(`Onboarding bypass bypassed: ${err.message}`);
            }

            // Dismiss any lingering system alerts (location, notifications) that Appium
            // did not catch via appium:permissions — tap 'Allow While Using App' if present
            for (let i = 0; i < 3; i++) {
                try {
                    const allowBtn = await browser.$('-ios predicate string:label == "Allow While Using App" AND type == "XCUIElementTypeButton"');
                    if (await allowBtn.isDisplayed()) {
                        await allowBtn.click();
                        logger.info('Dismissed location dialog: Allow While Using App');
                        await browser.pause(500);
                        continue;
                    }
                } catch (e) {}
                try {
                    const allowOnce = await browser.$('-ios predicate string:label == "Allow Once" AND type == "XCUIElementTypeButton"');
                    if (await allowOnce.isDisplayed()) {
                        await allowOnce.click();
                        logger.info('Dismissed location dialog: Allow Once');
                        await browser.pause(500);
                    }
                } catch (e) {}
                break;
            }
        }
    },

    afterTest: async function (test, context, { error, duration, passed }) {
        const timestamp = new Date().toISOString();
        let suiteName = 'default_suite';
        if (test.parent) {
            if (typeof test.parent === 'string') {
                suiteName = test.parent;
            } else if (typeof test.parent === 'object' && (test.parent as any).title) {
                suiteName = (test.parent as any).title;
            }
        }
        const cleanSuiteName = suiteName.replace(/[^a-zA-Z0-9]/g, '_');
        const cleanName = test.title.replace(/[^a-zA-Z0-9]/g, '_');
        let screenshotPath = '';

        let status: 'PASSED' | 'FAILED' | 'SKIPPED' = passed ? 'PASSED' : 'FAILED';
        if (test.pending) {
            status = 'SKIPPED';
        }

        if (!passed && !test.pending) {
            const filename = `${cleanSuiteName}_${cleanName}_${Date.now()}.png`;
            const fullPath = path.join(reportsDir, 'screenshots', filename);
            try {
                await browser.saveScreenshot(fullPath);
                screenshotPath = fullPath;
                logger.error(`Test FAILED: ${test.title}. Screenshot captured at: ${fullPath}`);
            } catch (err: any) {
                logger.warn(`Failed to capture screenshot: ${err.message}`);
            }
        } else if (passed) {
            logger.info(`Test PASSED: ${test.title} (${duration}ms)`);
        }

        // Map Title to a Test ID if matching TC-XXX format
        const tcMatch = test.title.match(/TC-[0-9]+/i);
        const testId = tcMatch ? tcMatch[0].toUpperCase() : `TC-GEN-${testResults.length + 1}`;

        testResults.push({
            id: testId,
            name: test.title,
            suite: suiteName,
            duration: duration || 0,
            status: status,
            error: error?.message,
            screenshot: screenshotPath,
            timestamp: timestamp
        });
    },

    afterSuite: function (suite) {
        logger.info(`Suite Completed: ${suite.title}`);
    },

    after: function (result, capabilities, specs) {
        const finalResultsPath = path.join(reportsDir, 'json', 'test_results.json');
        fs.writeFileSync(finalResultsPath, JSON.stringify(testResults, null, 2));
        logger.info(`All test results compiled and written to: ${finalResultsPath}`);
    }
};
