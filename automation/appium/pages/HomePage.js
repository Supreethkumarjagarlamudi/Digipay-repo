const BasePage = require('./BasePage');

class HomePage extends BasePage {
    get welcomeText() { return this.findByAccessibilityId('personalized_welcome_text'); }
    get upiBudgetCard() { return this.findByAccessibilityId('upi_budget_card'); }
    get remainingBudgetVal() { return this.findByAccessibilityId('remaining_budget_value_label'); }
    get totalLimitVal() { return this.findByAccessibilityId('total_limit_value_label'); }
    
    get payNowBtn() { return this.findByAccessibilityId('pay_now_button'); }
    get requestFundsBtn() { return this.findByAccessibilityId('request_funds_button'); }
    get scanQrBtn() { return this.findByAccessibilityId('scan_qr_button'); }
    
    get categoriesGrid() { return this.findByAccessibilityId('categories_grid'); }
    get recentActivitySection() { return this.findByAccessibilityId('recent_activity_section'); }

    async clickPayNow() {
        const btn = await this.payNowBtn;
        await this.click(btn);
    }
}

module.exports = new HomePage();
