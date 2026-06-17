const BasePage = require('./BasePage');

class BudgetCoachPage extends BasePage {
    get budgetCoachCard() { return this.findByAccessibilityId('budget_coach_insight_card'); }
    get budgetCoachDetails() { return this.findByAccessibilityId('budget_coach_detail_info'); }
    get budgetConfidenceLabel() { return this.findByAccessibilityId('budget_coach_confidence_rating'); }
    get exhaustionAlert() { return this.findByAccessibilityId('budget_exhaustion_alert_label'); }

    async getConfidence() {
        const lbl = await this.budgetConfidenceLabel;
        return await this.getText(lbl);
    }
}

module.exports = new BudgetCoachPage();
