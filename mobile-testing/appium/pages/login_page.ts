import { BasePage } from './base_page';

export class LoginPage extends BasePage {
    // Selectors
    public get mobileInput() { return '~mobileNumberInput'; }
    public get loginButton() { return '~loginSubmitButton'; }
    public get customerRoleButton() { return '~roleCustomerButton'; }
    public get merchantRoleButton() { return '~roleMerchantButton'; }
    public get errorMessage() { return '~loginErrorMessage'; }

    // Actions
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

    public async getErrorText(): Promise<string> {
        return this.getText(this.errorMessage);
    }
}
export const loginPage = new LoginPage();
