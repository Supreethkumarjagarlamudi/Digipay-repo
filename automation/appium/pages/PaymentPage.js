const BasePage = require('./BasePage');

class PaymentPage extends BasePage {
    get amountInput() { return this.findByAccessibilityId('amount_input_field'); }
    get upiPinInput() { return this.findByAccessibilityId('upi_pin_input_field'); }
    get paySubmitBtn() { return this.findByAccessibilityId('submit_payment_button'); }
    get statusBanner() { return this.findByAccessibilityId('payment_status_banner'); }

    async enterAmount(amount) {
        const input = await this.amountInput;
        await this.type(input, amount.toString());
    }

    async enterPin(pin) {
        const input = await this.upiPinInput;
        await this.type(input, pin);
    }

    async submitPayment() {
        const btn = await this.paySubmitBtn;
        await this.click(btn);
    }
}

module.exports = new PaymentPage();
