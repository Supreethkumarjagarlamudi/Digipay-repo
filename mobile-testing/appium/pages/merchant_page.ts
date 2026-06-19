import { BasePage } from './base_page';

export class MerchantPage extends BasePage {
    // Selectors
    public get businessNameField() { return '~merchantNameInput'; }
    public get categoryPicker() { return '~merchantCategoryPicker'; }
    public get addressField() { return '~merchantAddressInput'; }
    public get registerSubmitButton() { return '~merchantRegisterSubmit'; }
    public get dashboardTitle() { return '~merchantDashboardTitle'; }
    public get qrCodeImage() { return '~merchantQrCodeImage'; }
    public get transactionCountText() { return '~merchantTxCount'; }
    public get totalEarningsText() { return '~merchantTotalEarnings'; }

    // Actions
    public async register(name: string, category: string, address: string) {
        await this.setValue(this.businessNameField, name);
        await this.click(this.categoryPicker);
        await this.click(`~categoryOption_${category}`);
        await this.setValue(this.addressField, address);
        await this.click(this.registerSubmitButton);
    }

    public async isDashboardDisplayed(): Promise<boolean> {
        return this.isDisplayed(this.dashboardTitle);
    }

    public async getTotalEarnings(): Promise<string> {
        return this.getText(this.totalEarningsText);
    }
}
export const merchantPage = new MerchantPage();
