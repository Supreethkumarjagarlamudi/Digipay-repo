const BasePage = require('./BasePage');

class MerchantPage extends BasePage {
    get merchantTitle() { return this.findByAccessibilityId('merchant_business_name_label'); }
    get revenueLabel() { return this.findByAccessibilityId('today_revenue_metric_label'); }
    get trendChart() { return this.findByAccessibilityId('weekly_revenue_trend_chart'); }
    
    get editShopBtn() { return this.findByAccessibilityId('Edit Shop Context Button'); }
    get editBusinessNameInput() { return this.findByAccessibilityId('edit_business_name_field'); }
    get editCategoryPicker() { return this.findByAccessibilityId('edit_category_picker'); }
    get editDescriptionInput() { return this.findByAccessibilityId('edit_description_field'); }
    get editGstInput() { return this.findByAccessibilityId('edit_gst_field'); }
    get refreshGpsBtn() { return this.findByAccessibilityId('refresh_gps_coordinates_button'); }
    get latitudeLabel() { return this.findByAccessibilityId('edit_latitude_label'); }
    get scanUpiQrBtn() { return this.findByAccessibilityId('scan_upi_qr_button'); }
    get saveProfileBtn() { return this.findByAccessibilityId('Save Profile Changes'); }
    
    get statementBtn() { return this.findByAccessibilityId('View Statement Button'); }
    get totalVolumeLabel() { return this.findByAccessibilityId('statement_total_volume_label'); }
    get paymentsCountLabel() { return this.findByAccessibilityId('statement_total_payments_count'); }
    get statementSearchBar() { return this.findByAccessibilityId('statement_search_field'); }
    get dateGroupHeaderToday() { return this.findByAccessibilityId('date_group_header_Today'); }
    
    get rowPhoneLabel() { return this.findByAccessibilityId('statement_row_phone_label'); }
    get rowTimeLabel() { return this.findByAccessibilityId('statement_row_time_label'); }
    get rowTxnIdLabel() { return this.findByAccessibilityId('statement_row_txn_id_label'); }
    get rowAmountLabel() { return this.findByAccessibilityId('statement_row_amount_label'); }

    async clickEditShop() {
        const btn = await this.editShopBtn;
        await this.click(btn);
    }

    async clickStatement() {
        const btn = await this.statementBtn;
        await this.click(btn);
    }

    async searchStatement(query) {
        const bar = await this.statementSearchBar;
        await this.type(bar, query);
    }
}

module.exports = new MerchantPage();
