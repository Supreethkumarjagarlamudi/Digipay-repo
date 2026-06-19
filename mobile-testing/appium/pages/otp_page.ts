import { BasePage } from './base_page';

export class OtpPage extends BasePage {
    // Selectors
    public get otpInput() { return '~otpInputField'; }
    public get verifyButton() { return '~verifyOtpButton'; }
    public get resendLink() { return '~resendOtpLink'; }
    public get errorMessage() { return '~otpErrorMessage'; }

    // Actions
    public async enterOTP(otp: string) {
        await this.setValue(this.otpInput, otp);
    }

    public async submitOTP() {
        await this.click(this.verifyButton);
    }

    public async clickResend() {
        await this.click(this.resendLink);
    }

    public async getErrorText(): Promise<string> {
        return this.getText(this.errorMessage);
    }
}
export const otpPage = new OtpPage();
