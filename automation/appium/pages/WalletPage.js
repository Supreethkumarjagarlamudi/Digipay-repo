const BasePage = require('./BasePage');

class WalletPage extends BasePage {
    get balanceLabel() { return this.findByAccessibilityId('wallet_total_balance'); }
    get aiHeader() { return this.findByAccessibilityId('DIGIPAY AI Insights'); }
    get insightsStack() { return this.findByAccessibilityId('ai_insights_cards_stack'); }
    
    get spendingPatternCard() { return this.findByAccessibilityId('spending_pattern_insight_card'); }
    get proximityCard() { return this.findByAccessibilityId('proximity_insight_card'); }
    get budgetCoachCard() { return this.findByAccessibilityId('budget_coach_insight_card'); }
    
    get confidenceBadge() { return this.findByAccessibilityId('insight_confidence_badge'); }

    async getBalance() {
        const lbl = await this.balanceLabel;
        return await this.getText(lbl);
    }
}

module.exports = new WalletPage();
