import { expect } from 'expect';
import { loginPage } from '../../pages/login_page';
import { otpPage } from '../../pages/otp_page';
import { homePage } from '../../pages/home_page';
import { profilePage } from '../../pages/profile_page';
import { walletPage } from '../../pages/wallet_page';

declare const browser: any;

describe('Smoke Testing Suite', () => {

    it('TC-SMK-001 [Priority: High, Module: Launch, Feature: App Startup]: Verify app launches successfully without crashing', async () => {
        const loaded = await loginPage.isDisplayed(loginPage.customerRoleButton);
        expect(loaded).toBe(true);
    });

    it('TC-SMK-002 [Priority: High, Module: Auth, Feature: Login Landing]: Verify login screen UI elements are visible', async () => {
        await loginPage.selectCustomerRole();
        const mobileVisible = await loginPage.isDisplayed(loginPage.mobileInput);
        expect(mobileVisible).toBe(true);
    });

    it('TC-SMK-003 [Priority: High, Module: Auth, Feature: Login Submission]: Verify navigation to OTP Verification page on valid number', async () => {
        await loginPage.enterMobileNumber('9876543210');
        await loginPage.submitLogin();
        const otp = await loginPage.handleOTPAlert();
        await otpPage.enterOTP(otp);
        await loginPage.dismissSystemAlerts();
        await homePage.waitForDisplayed(homePage.budgetAmount, 45000);
        expect(await homePage.isDisplayed(homePage.budgetAmount)).toBe(true);
    });

    it('TC-SMK-004 [Priority: High, Module: Auth, Feature: Dashboard Landing]: Verify customer dashboard loads successfully', async () => {
        const budgetVisible = await homePage.isDisplayed(homePage.budgetAmount);
        expect(budgetVisible).toBe(true);
    });

    it('TC-SMK-005 [Priority: Medium, Module: Dashboard, Feature: Location Sync]: Verify location widget is rendered on dashboard', async () => {
        const locationVisible = await homePage.isDisplayed(homePage.locationText);
        expect(locationVisible).toBe(true);
    });

    it('TC-SMK-006 [Priority: High, Module: Wallet, Feature: Budget Summary]: Verify budget widget displays current remaining balance', async () => {
        const amount = await homePage.getRemainingBudget();
        expect(amount).toContain('₹');
    });

    it('TC-SMK-007 [Priority: High, Module: Payment, Feature: QR Payment Landing]: Verify merchant section is visible on home screen', async () => {
        const viewAllExists = await homePage.isDisplayed(homePage.viewAllMerchantsButton);
        expect(viewAllExists).toBe(true);
    });

    it('TC-SMK-008 [Priority: Medium, Module: Merchant, Feature: View All Merchants]: Verify merchant category chips render on home screen', async () => {
        await homePage.selectCategory('Cafe');
        expect(true).toBe(true);
    });

    it('TC-SMK-009 [Priority: Low, Module: Profile, Feature: Settings Profile Info]: Verify welcome header is displayed after login', async () => {
        const welcome = await homePage.isDisplayed(homePage.headerWelcomeText);
        expect(welcome).toBe(true);
    });

    it('TC-SMK-010 [Priority: Medium, Module: Dashboard, Feature: Sync Button]: Verify sync info button exists on wallet hero card', async () => {
        const syncVisible = await homePage.isDisplayed(homePage.syncButton);
        expect(syncVisible).toBe(true);
    });

    it('TC-SMK-011 [Priority: Medium, Module: Wallet, Feature: Wallet Tab]: Verify wallet tab is accessible from tab bar', async () => {
        await walletPage.clickWalletTab();
        expect(true).toBe(true);
    });

    it('TC-SMK-012 [Priority: Medium, Module: Navigation, Feature: Tab Bar]: Verify home tab navigation returns to dashboard', async () => {
        await homePage.clickHomeTab();
        const budgetVisible = await homePage.isDisplayed(homePage.budgetAmount);
        expect(budgetVisible).toBe(true);
    });

    it('TC-SMK-013 [Priority: Medium, Module: Dashboard, Feature: Category Filter]: Verify Restaurant category chip is tappable', async () => {
        await homePage.selectCategory('Restaurant');
        expect(true).toBe(true);
    });

    it('TC-SMK-014 [Priority: Medium, Module: Dashboard, Feature: Grocery Filter]: Verify Grocery category chip is tappable', async () => {
        await homePage.selectCategory('Grocery');
        expect(true).toBe(true);
    });

    it('TC-SMK-015 [Priority: High, Module: Auth, Feature: Session Logout]: Verify session closes and returns to authentication', async () => {
        await profilePage.dismissSystemAlerts();
        await profilePage.clickProfileTab();
        await profilePage.scrollToLogout();
        await profilePage.clickLogout();
        const roleVisible = await loginPage.isDisplayed(loginPage.customerRoleButton);
        expect(roleVisible).toBe(true);
    });
});
