const path = require('path');
const fs = require('fs');
require('dotenv').config();

const reportsDir = path.join(__dirname, 'reports');
const screenshotsDir = path.join(reportsDir, 'screenshots');
const logsDir = path.join(reportsDir, 'logs');

// Create directories if they don't exist
[reportsDir, screenshotsDir, logsDir].forEach(dir => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

exports.config = {
    runner: 'local',
    port: 4723,
    path: '/',
    specs: [
        './appium/tests/**/*.js'
    ],
    exclude: [],
    maxInstances: 5,
    capabilities: [{
        platformName: 'iOS',
        'appium:deviceName': 'iPhone 17',
        'appium:platformVersion': '17.0',
        'appium:automationName': 'XCUITest',
        'appium:app': path.join(__dirname, '../Build/Digipay.app'),
        'appium:noReset': true,
        'appium:newCommandTimeout': 300
    }],
    logLevel: 'info',
    bail: 0,
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    services: ['appium'],
    framework: 'mocha',
    reporters: [
        'spec',
        ['allure', {
            outputDir: 'reports/allure',
            disableWebdriverStepsReporting: true,
            disableWebdriverScreenshotsReporting: false,
        }]
    ],
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    },
    specFileRetries: 2,
    specFileRetriesDelay: 5,
    
    // Hooks
    beforeSession: function () {
        // Pre-checks or variables setup
    },
    before: function () {
        const chai = require('chai');
        global.expect = chai.expect;
        global.assert = chai.assert;
    },
    afterStep: async function (step, scenario, result) {
        if (!result.passed) {
            const tempFilename = `fail-${Date.now()}.png`;
            const screenshotPath = path.join(screenshotsDir, tempFilename);
            await browser.saveScreenshot(screenshotPath);
            console.log(`Step failed. Screenshot captured to: ${screenshotPath}`);
        }
    },
    afterTest: async function(test, context, { error, result, duration, passed, retries }) {
        // Log individual test result
        const logMsg = `${new Date().toISOString()} [${test.parent}] ${test.title} -> ${passed ? 'PASSED' : 'FAILED'} (Duration: ${duration}ms)\n`;
        fs.appendFileSync(path.join(logsDir, 'execution.log'), logMsg);
    }
};
