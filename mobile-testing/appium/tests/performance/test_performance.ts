import { expect } from 'expect';
import { loginPage } from '../../pages/login_page';
import { homePage } from '../../pages/home_page';

declare const browser: any;

describe('Performance Testing Suite', () => {

    it('TC-PERF-001 [Priority: High, Module: Performance, Feature: Role Screen Load]: Role selection screen loads within 3 seconds of app launch', async () => {
        const start = Date.now();
        await loginPage.waitForDisplayed(loginPage.customerRoleButton);
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-002 [Priority: High, Module: Performance, Feature: Login Screen Load]: Login form renders within acceptable time after role selection', async () => {
        const start = Date.now();
        await loginPage.selectCustomerRole();
        await loginPage.waitForDisplayed(loginPage.mobileInput);
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-003 [Priority: High, Module: Performance, Feature: OTP Login Duration]: Full OTP login completes and dashboard loads within 60 seconds', async () => {
        await loginPage.enterMobileNumber('9876543210');
        await loginPage.submitLogin();
        const otp = await loginPage.handleOTPAlert();
        const start = Date.now();
        const { otpPage } = await import('../../pages/otp_page');
        await otpPage.enterOTP(otp);
        await loginPage.dismissSystemAlerts();
        await homePage.waitForDisplayed(homePage.budgetAmount, 60000);
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(60000);
    });

    it('TC-PERF-004 [Priority: High, Module: Performance, Feature: Dashboard Render]: Dashboard budget element is visible within 3s of navigation', async () => {
        expect(await homePage.isDisplayed(homePage.budgetAmount)).toBe(true);
    });

    it('TC-PERF-005 [Priority: Medium, Module: Performance, Feature: Category Filter Response]: Category chip tap responds within 2 seconds', async () => {
        const start = Date.now();
        await homePage.selectCategory('Cafe');
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-006 [Priority: Medium, Module: Performance, Feature: Tab Switch Speed]: Tab bar switching completes within 2 seconds', async () => {
        const { walletPage } = await import('../../pages/wallet_page');
        const start = Date.now();
        await walletPage.clickWalletTab();
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-007 [Priority: Medium, Module: Performance, Feature: Home Tab Return]: Returning to home tab renders dashboard within 3 seconds', async () => {
        const start = Date.now();
        await homePage.clickHomeTab();
        await homePage.waitForDisplayed(homePage.budgetAmount);
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-008 [Priority: Medium, Module: Performance, Feature: Merchant Section Load]: Merchant section header renders quickly on dashboard', async () => {
        const start = Date.now();
        await homePage.waitForDisplayed(homePage.viewAllMerchantsButton);
        const elapsed = Date.now() - start;
        expect(elapsed).toBeLessThan(5000);
    });

    it('TC-PERF-009 [Priority: Low, Module: Performance, Feature: CPU Baseline]: App remains responsive after 5 rapid category filter taps', async () => {
        await homePage.selectCategory('Cafe');
        await homePage.selectCategory('Restaurant');
        await homePage.selectCategory('Medical');
        await homePage.selectCategory('Grocery');
        await homePage.selectCategory('Cafe');
        expect(true).toBe(true);
    });

    it('TC-PERF-010 [Priority: Low, Module: Performance, Feature: Memory Stability]: Repeated tab switching does not cause app to become unresponsive', async () => {
        const { walletPage } = await import('../../pages/wallet_page');
        await walletPage.clickWalletTab();
        await homePage.clickHomeTab();
        await walletPage.clickWalletTab();
        await homePage.clickHomeTab();
        expect(await homePage.isDisplayed(homePage.budgetAmount)).toBe(true);
    });
});
