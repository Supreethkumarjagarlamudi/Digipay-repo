const BasePage = require('./BasePage');

class ExpenseIntelligencePage extends BasePage {
    get discoverHeader() { return this.findByAccessibilityId('Discover Nearby'); }
    get merchantsList() { return this.findByAccessibilityId('nearby_merchants_list'); }
    
    get merchantRow() { return this.findByAccessibilityId('merchant_row_item'); }
    get distanceLabel() { return this.findByAccessibilityId('merchant_distance_label'); }
    get recommendationsList() { return this.findByAccessibilityId('recommendation_score_badge'); }
    get relevanceReason() { return this.findByAccessibilityId('ai_relevance_reason_text'); }
    
    get searchBar() { return this.findByAccessibilityId('discover_search_input'); }
    get locationWarning() { return this.findByAccessibilityId('location_warning_banner'); }

    async searchForMerchant(name) {
        const input = await this.searchBar;
        await this.type(input, name);
    }
}

module.exports = new ExpenseIntelligencePage();
