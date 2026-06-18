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

// Initialize runtime variables
const appPath = process.env.APP_PATH || path.join(__dirname, '../../../../Library/Developer/Xcode/DerivedData/Digipay-bpuxypzotjfvbdftrwkftqzuqnfy/Build/Products/Debug-iphonesimulator/Digipay.app');
const udid = process.env.SIMULATOR_UDID || '';
const platformVersion = process.env.IOS_VERSION || '18.2';
const deviceName = process.env.IOS_DEVICE_NAME || 'iPhone 16';

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
        'appium:autoAcceptAlerts': true,
        'appium:relaxedSecurityEnabled': true
    } as any],
    logLevel: 'info',
    bail: 0,
    baseUrl: 'http://127.0.0.1',
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    services: [],
    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
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
        logger.info(`Starting test runner session on Device: ${deviceName}, UDID: ${udid}, iOS: ${platformVersion}`);
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
        }
    },

    afterTest: async function (test, context, { error, duration, passed }) {
        const timestamp = new Date().toISOString();
        const cleanName = test.title.replace(/[^a-zA-Z0-9]/g, '_');
        const suiteName = test.parent || 'default_suite';
        let screenshotPath = '';

        let status: 'PASSED' | 'FAILED' | 'SKIPPED' = passed ? 'PASSED' : 'FAILED';
        if (test.pending) {
            status = 'SKIPPED';
        }

        if (!passed && !test.pending) {
            const filename = `${suiteName}_${cleanName}_${Date.now()}.png`;
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
