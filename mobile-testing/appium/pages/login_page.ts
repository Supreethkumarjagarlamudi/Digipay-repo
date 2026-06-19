import { BasePage } from './base_page';

declare const browser: any;

export class LoginPage extends BasePage {
    // Selectors
    public get mobileInput() { return '~mobileNumberInput'; }
    public get loginButton() { return '~loginSubmitButton'; }
    public get customerRoleButton() { return '~roleCustomerButton'; }
    public get merchantRoleButton() { return '~roleMerchantButton'; }
    public get errorMessage() { return '~loginErrorMessage'; }
    public get backButton() { return '~backButton'; }

    // Actions
    public async clickBack() {
        await this.click(this.backButton);
    }
    public async selectCustomerRole() {
        await this.click(this.customerRoleButton);
        await this.click(this.loginButton);
    }

    public async selectMerchantRole() {
        await this.click(this.merchantRoleButton);
        await this.click(this.loginButton);
    }

    public async enterMobileNumber(mobile: string) {
        await this.setValue(this.mobileInput, mobile);
    }

    public async submitLogin() {
        await this.click(this.loginButton);
    }

    public async loginAsCustomer(phoneNumber: string) {
        if (await this.isDisplayed('~tab_home') || await this.isDisplayed('~tab_profile')) {
            console.log('Already logged in. Skipping loginAsCustomer flow.');
            return;
        }
        if (await this.isDisplayed(this.customerRoleButton)) {
            await this.selectCustomerRole();
        }
        if (await this.isDisplayed(this.mobileInput)) {
            await this.enterMobileNumber(phoneNumber);
            await this.submitLogin();
        }
        // handleOTPAlert waits for the "Development Build" alert, extracts the OTP,
        // dismisses it, and blocks until OTPView (~otpInputField) is visible.
        const otp = await this.handleOTPAlert();
        // OTPView auto-submits once 6 digits are entered via onChange handler
        await this.setValue('~otpInputField', otp);
    }

    public async getErrorText(): Promise<string> {
        return this.getText(this.errorMessage);
    }
}
export const loginPage = new LoginPage();
