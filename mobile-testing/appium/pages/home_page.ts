import { BasePage } from './base_page';

export class HomePage extends BasePage {
    // Selectors
    public get headerWelcomeText() { return '~welcomeText'; }
    public get locationText() { return '~locationText'; }
    public get budgetAmount() { return '~remainingBudgetAmount'; }
    public get syncButton() { return '~syncInfoButton'; }
    public get viewAllMerchantsButton() { return '~viewAllMerchants'; }
    public get bestMatchCard() { return '~bestMatchCard'; }
    public get payNowButton() { return '~payNowBtn'; }
    
    // Category Chips
    public categoryChip(category: string) {
        return `~categoryChip_${category}`;
    }

    // Nearby Merchant List Card
    public merchantCard(merchantName: string) {
        return `~merchantCard_${merchantName}`;
    }

    // Actions
    public async clickSync() {
        await this.click(this.syncButton);
    }

    public async selectCategory(category: string) {
        await this.click(this.categoryChip(category));
    }

    public async clickMerchant(merchantName: string) {
        await this.click(this.merchantCard(merchantName));
    }

    public async clickPayNow() {
        await this.click(this.payNowButton);
    }

    public async getRemainingBudget(): Promise<string> {
        return this.getText(this.budgetAmount);
    }
}
export const homePage = new HomePage();
