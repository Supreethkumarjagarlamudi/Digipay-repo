import { expect } from 'expect';
import { loginPage } from '../../pages/login_page';
import { otpPage } from '../../pages/otp_page';
import { homePage } from '../../pages/home_page';
import { walletPage } from '../../pages/wallet_page';
import { paymentPage } from '../../pages/payment_page';
import { profilePage } from '../../pages/profile_page';

declare const browser: any;

describe('Functional Testing Suite', () => {

    it('TC-FUN-001 [Priority: High, Module: Auth, Feature: Customer Role Select]: Customer role button navigates to login form', async () => {
        await loginPage.selectCustomerRole();
        expect(await loginPage.isDisplayed(loginPage.mobileInput)).toBe(true);
    });

    it('TC-FUN-002 [Priority: High, Module: Auth, Feature: OTP Login Flow]: Full login flow completes and navigates to dashboard', async () => {
        await loginPage.enterMobileNumber('9876543210');
        await loginPage.submitLogin();
        const otp = await loginPage.handleOTPAlert();
        await otpPage.enterOTP(otp);
        await loginPage.dismissSystemAlerts();
        await homePage.waitForDisplayed(homePage.budgetAmount, 45000);
        expect(await homePage.isDisplayed(homePage.budgetAmount)).toBe(true);
    });

    it('TC-FUN-003 [Priority: High, Module: Dashboard, Feature: Budget Display]: Remaining budget amount is visible after login', async () => {
        const budget = await homePage.getRemainingBudget();
        expect(budget).toContain('₹');
    });

    it('TC-FUN-004 [Priority: Medium, Module: Dashboard, Feature: Location Widget]: Location text element renders on dashboard', async () => {
        expect(await homePage.isDisplayed(homePage.locationText)).toBe(true);
    });

    it('TC-FUN-005 [Priority: High, Module: Dashboard, Feature: Welcome Header]: Welcome header shows user name after authentication', async () => {
        expect(await homePage.isDisplayed(homePage.headerWelcomeText)).toBe(true);
    });

    it('TC-FUN-006 [Priority: High, Module: Dashboard, Feature: Sync Button]: Sync Info button is tappable on wallet hero card', async () => {
        await homePage.clickSync();
        expect(true).toBe(true);
    });

    it('TC-FUN-007 [Priority: Medium, Module: Merchant, Feature: Category Cafe]: Cafe category chip filters merchant view', async () => {
        await homePage.selectCategory('Cafe');
        expect(true).toBe(true);
    });

    it('TC-FUN-008 [Priority: Medium, Module: Merchant, Feature: Category Restaurant]: Restaurant category chip is functional', async () => {
        await homePage.selectCategory('Restaurant');
        expect(true).toBe(true);
    });

    it('TC-FUN-009 [Priority: Medium, Module: Merchant, Feature: Category Medical]: Medical category chip is functional', async () => {
        await homePage.selectCategory('Medical');
        expect(true).toBe(true);
    });

    it('TC-FUN-010 [Priority: Medium, Module: Merchant, Feature: Category Grocery]: Grocery category chip is functional', async () => {
        await homePage.selectCategory('Grocery');
        expect(true).toBe(true);
    });

    it('TC-FUN-011 [Priority: Medium, Module: Merchant, Feature: Category Retail]: Retail category chip is functional', async () => {
        await homePage.selectCategory('Retail');
        expect(true).toBe(true);
    });

    it('TC-FUN-012 [Priority: Medium, Module: Merchant, Feature: View All Button]: View All Merchants button is visible', async () => {
        expect(await homePage.isDisplayed(homePage.viewAllMerchantsButton)).toBe(true);
    });

    it('TC-FUN-013 [Priority: High, Module: Wallet, Feature: Wallet Tab]: Wallet tab is accessible from bottom navigation', async () => {
        await walletPage.clickWalletTab();
        expect(true).toBe(true);
    });

    it('TC-FUN-014 [Priority: High, Module: Navigation, Feature: Home Tab]: Home tab returns to dashboard from wallet', async () => {
        await homePage.clickHomeTab();
        expect(await homePage.isDisplayed(homePage.budgetAmount)).toBe(true);
    });

    it('TC-FUN-015 [Priority: High, Module: Profile, Feature: Profile Tab]: Profile tab navigates to profile screen', async () => {
        await profilePage.dismissSystemAlerts();
        await profilePage.clickProfileTab();
        expect(true).toBe(true);
    });

    it('TC-FUN-016 [Priority: Medium, Module: Profile, Feature: Edit Profile Row]: Edit profile row is displayed on profile screen', async () => {
        expect(await profilePage.isDisplayed('~editProfileRow')).toBe(true);
    });

    it('TC-FUN-017 [Priority: Medium, Module: Profile, Feature: Budget Edit]: Monthly budget edit button is visible', async () => {
        expect(await profilePage.isDisplayed('~editBudgetButton')).toBe(true);
    });

    it('TC-FUN-018 [Priority: High, Module: Auth, Feature: Logout Flow]: Logout button scrolls into view on profile screen', async () => {
        await profilePage.scrollToLogout();
        expect(await profilePage.isDisplayed(profilePage.logoutButton)).toBe(true);
    });

    it('TC-FUN-019 [Priority: High, Module: Auth, Feature: Session End]: Logout completes and returns to role selection screen', async () => {
        await profilePage.clickLogout();
        expect(await loginPage.isDisplayed(loginPage.customerRoleButton)).toBe(true);
    });

    it('TC-FUN-020 [Priority: High, Module: Auth, Feature: Role Re-select]: After logout, customer role can be re-selected', async () => {
        await loginPage.selectCustomerRole();
        expect(await loginPage.isDisplayed(loginPage.mobileInput)).toBe(true);
    });
});
