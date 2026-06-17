const path = require('path');

module.exports = {
    simulator: {
        platformName: 'iOS',
        'appium:deviceName': process.env.IOS_DEVICE_NAME || 'iPhone 17',
        'appium:platformVersion': process.env.IOS_PLATFORM_VERSION || '17.0',
        'appium:automationName': 'XCUITest',
        'appium:app': process.env.IOS_APP_PATH || path.join(__dirname, '../../../Build/Digipay.app'),
        'appium:noReset': true,
        'appium:newCommandTimeout': 300,
        'appium:wdaLocalPort': 8100
    },
    device: {
        platformName: 'iOS',
        'appium:deviceName': process.env.IOS_REAL_DEVICE_NAME || 'iPhone',
        'appium:udid': process.env.IOS_DEVICE_UDID || 'auto',
        'appium:automationName': 'XCUITest',
        'appium:app': process.env.IOS_REAL_APP_PATH || path.join(__dirname, '../../../Build/Digipay.ipa'),
        'appium:xcodeOrgId': process.env.XCODE_ORG_ID || '',
        'appium:xcodeSigningId': 'iPhone Developer'
    }
};
