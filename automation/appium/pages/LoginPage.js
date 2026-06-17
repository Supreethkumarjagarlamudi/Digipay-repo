const BasePage = require('./BasePage');

class LoginPage extends BasePage {
    get roleTitle() { return this.findByAccessibilityId('Choose Your Role'); }
    get customerRoleBtn() { return this.findByAccessibilityId('Customer Portal Button'); }
    get merchantRoleBtn() { return this.findByAccessibilityId('Merchant Portal Button'); }
    
    get phoneHeader() { return this.findByAccessibilityId('Enter Phone Number'); }
    get phoneInput() { return this.findByAccessibilityId('Phone Number Text Field'); }
    get sendOtpBtn() { return this.findByAccessibilityId('Send OTP Button'); }
    get countryCodePicker() { return this.findByAccessibilityId('Country Code Picker'); }
    
    get otpHeader() { return this.findByAccessibilityId('Verify Your Number'); }
    get otpInputBox() { return this.findByAccessibilityId('otp_entry_box'); }
    get verifyCodeBtn() { return this.findByAccessibilityId('Verify Code Button'); }
    get resendOtpLink() { return this.findByAccessibilityId('Resend OTP Link'); }
    get otpTimer() { return this.findByAccessibilityId('otp_timer_label'); }

    async selectCustomerRole() {
        const btn = await this.customerRoleBtn;
        await this.click(btn);
    }

    async selectMerchantRole() {
        const btn = await this.merchantRoleBtn;
        await this.click(btn);
    }

    async loginWithPhone(phone) {
        const input = await this.phoneInput;
        await this.type(input, phone);
        const btn = await this.sendOtpBtn;
        await this.click(btn);
    }

    async submitOTP(otpCode) {
        const boxes = await $$('~otp_entry_box');
        for (let i = 0; i < Math.min(boxes.length, otpCode.length); i++) {
            await boxes[i].setValue(otpCode[i]);
        }
        const btn = await this.verifyCodeBtn;
        await this.click(btn);
    }
}

module.exports = new LoginPage();
