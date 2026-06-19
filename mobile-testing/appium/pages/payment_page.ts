import { BasePage } from './base_page';

export class PaymentPage extends BasePage {
    // Selectors
    public get merchantNameText() { return '~paymentMerchantName'; }
    public get amountInputField() { return '~paymentAmountInput'; }
    public get notesInputField() { return '~paymentNotesInput'; }
    public get proceedPayButton() { return '~proceedToPayButton'; }
    public get successAlert() { return '~paymentSuccessModal'; }
    public get failureAlert() { return '~paymentFailureModal'; }
    public get closeSuccessButton() { return '~closeSuccessModalBtn'; }
    public get closeFailureButton() { return '~closeFailureModalBtn'; }

    // Actions
    public async fillPaymentDetails(amount: string, notes: string) {
        await this.setValue(this.amountInputField, amount);
        await this.setValue(this.notesInputField, notes);
    }

    public async clickProceed() {
        await this.click(this.proceedPayButton);
    }

    public async isSuccessDisplayed(): Promise<boolean> {
        return this.isDisplayed(this.successAlert);
    }

    public async isFailureDisplayed(): Promise<boolean> {
        return this.isDisplayed(this.failureAlert);
    }

    public async closeSuccess() {
        await this.click(this.closeSuccessButton);
    }

    public async closeFailure() {
        await this.click(this.closeFailureButton);
    }
}
export const paymentPage = new PaymentPage();
