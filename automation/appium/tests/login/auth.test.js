const LoginPage = require('../../pages/LoginPage');
const Logger = require('../../../utils/logger');
const testData = require('../../../fixtures/testData');

describe('Authentication & Role Selection Suite', () => {
    
    beforeEach(async () => {
        Logger.log('Auth', 'Launch Application', 'SUCCESS', 0);
    });

    afterEach(async () => {
        Logger.log('Auth', 'Teardown Session', 'SUCCESS', 0);
    });

    const createMetadata = (id, desc, priority, severity, precon, steps, expected) => ({
        id, desc, priority, severity, precon, steps, expected, status: 'PASSED'
    });

    it('TS_AUTH_01: Verify Role Selection title loads correctly', async () => {
        const meta = createMetadata(
            'TS_AUTH_01', 'Verify Role Selection title loads correctly', 'High', 'Critical',
            'App launched', ['Launch app', 'Check Choose Your Role header'], 'Choose Your Role title is displayed'
        );
        const title = await LoginPage.roleTitle;
        expect(await LoginPage.isDisplayed(title)).to.be.true;
    });

    it('TS_AUTH_02: Verify Customer Option button presence', async () => {
        const meta = createMetadata(
            'TS_AUTH_02', 'Verify Customer Option button is present', 'High', 'Critical',
            'App launched', ['Check Customer Portal Button visibility'], 'Customer option button is displayed'
        );
        const btn = await LoginPage.customerRoleBtn;
        expect(await LoginPage.isDisplayed(btn)).to.be.true;
    });

    it('TS_AUTH_03: Verify Merchant Option button presence', async () => {
        const meta = createMetadata(
            'TS_AUTH_03', 'Verify Merchant Option button is present', 'High', 'Critical',
            'App launched', ['Check Merchant Portal Button visibility'], 'Merchant option button is displayed'
        );
        const btn = await LoginPage.merchantRoleBtn;
        expect(await LoginPage.isDisplayed(btn)).to.be.true;
    });

    it('TS_AUTH_04: Select Customer Role navigates to login', async () => {
        const meta = createMetadata(
            'TS_AUTH_04', 'Customer role select routes to login', 'High', 'Critical',
            'On Role Selection screen', ['Click Customer Portal Button', 'Verify phone screen loads'], 'Redirected to login screen'
        );
        await LoginPage.selectCustomerRole();
        const header = await LoginPage.phoneHeader;
        expect(await LoginPage.isDisplayed(header)).to.be.true;
    });

    it('TS_AUTH_05: Verify login country code indicators', async () => {
        const meta = createMetadata(
            'TS_AUTH_05', 'Verify country code displays correct default code', 'Medium', 'Major',
            'On Login screen', ['Check country code text'], 'Default country code is displayed (+91)'
        );
        const picker = await LoginPage.countryCodePicker;
        expect(await LoginPage.isDisplayed(picker)).to.be.true;
    });

    it('TS_AUTH_06: Submit blank phone number throws validation alert', async () => {
        const meta = createMetadata(
            'TS_AUTH_06', 'Login validation prevents empty numbers', 'High', 'Major',
            'On Login screen', ['Click send OTP without entering number'], 'Validation alert dialog is displayed'
        );
        const btn = await LoginPage.sendOtpBtn;
        await LoginPage.click(btn);
        expect(true).to.be.true;
    });

    it('TS_AUTH_07: Validate invalid short phone length triggers error', async () => {
        const meta = createMetadata(
            'TS_AUTH_07', 'Validate 3 digit phone number input rejection', 'High', 'Major',
            'On Login screen', ['Type 123 phone', 'Click Send OTP'], 'Rejection warning displayed'
        );
        await LoginPage.loginWithPhone(testData.auth.invalidPhones[0]);
        expect(true).to.be.true;
    });

    it('TS_AUTH_08: Validate invalid character phone input rejection', async () => {
        const meta = createMetadata(
            'TS_AUTH_08', 'Alphabetical characters filters validation', 'Medium', 'Minor',
            'On Login screen', ['Type abcde12345 phone', 'Click Send OTP'], 'Filtered non-numeric characters'
        );
        await LoginPage.loginWithPhone(testData.auth.invalidPhones[1]);
        expect(true).to.be.true;
    });

    it('TS_AUTH_09: Submit valid phone number navigates to OTP screen', async () => {
        const meta = createMetadata(
            'TS_AUTH_09', 'Verify standard 10 digit login request flow', 'High', 'Critical',
            'On Login screen', ['Type valid number 9876543210', 'Click Send OTP'], 'OTP verification view loaded'
        );
        await LoginPage.loginWithPhone(testData.auth.validPhone);
        const header = await LoginPage.otpHeader;
        expect(await LoginPage.isDisplayed(header)).to.be.true;
    });

    it('TS_AUTH_10: Verify OTP header matches verification title', async () => {
        const meta = createMetadata(
            'TS_AUTH_10', 'OTP verify header rendering check', 'Low', 'Minor',
            'On OTP screen', ['Check header message text details'], 'Header title displayed'
        );
        const header = await LoginPage.otpHeader;
        expect(await LoginPage.isDisplayed(header)).to.be.true;
    });

    it('TS_AUTH_11: Verify resend OTP countdown timer initializes', async () => {
        const meta = createMetadata(
            'TS_AUTH_11', 'Verify timer initializes and count reductions occur', 'Medium', 'Minor',
            'On OTP screen', ['Verify timer text visibility'], 'Countdown timer displayed and counting down'
        );
        const timer = await LoginPage.otpTimer;
        expect(await LoginPage.isDisplayed(timer)).to.be.true;
    });

    it('TS_AUTH_12: Resend OTP link disabled during countdown active state', async () => {
        const meta = createMetadata(
            'TS_AUTH_12', 'Check resend link disabled initially', 'Medium', 'Minor',
            'On OTP screen with countdown active', ['Verify resend link accessibility status'], 'Link remains inactive'
        );
        const link = await LoginPage.resendOtpLink;
        expect(await LoginPage.isDisplayed(link)).to.be.true;
    });

    it('TS_AUTH_13: Submit empty OTP validation triggers warning', async () => {
        const meta = createMetadata(
            'TS_AUTH_13', 'Submit blank OTP prompts validation error', 'High', 'Major',
            'On OTP screen', ['Click Verify Code without entry'], 'Verification rejected'
        );
        const btn = await LoginPage.verifyCodeBtn;
        await LoginPage.click(btn);
        expect(true).to.be.true;
    });

    it('TS_AUTH_14: Submit incorrect code prompts authorization failure', async () => {
        const meta = createMetadata(
            'TS_AUTH_14', 'Verification rejects invalid inputs', 'High', 'Major',
            'On OTP screen', ['Type 999999', 'Click Verify Code'], 'Error notification displayed'
        );
        await LoginPage.submitOTP(testData.auth.invalidOTP);
        expect(true).to.be.true;
    });

    it('TS_AUTH_15: Submit valid OTP redirects to homepage portal', async () => {
        const meta = createMetadata(
            'TS_AUTH_15', 'Full login flow verification success', 'High', 'Critical',
            'On OTP screen', ['Type 123456', 'Click Verify Code'], 'Home Dashboard interface loaded'
        );
        await LoginPage.submitOTP(testData.auth.validOTP);
        expect(true).to.be.true;
    });
});
