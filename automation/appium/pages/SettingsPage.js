const BasePage = require('./BasePage');

class SettingsPage extends BasePage {
    get biometricToggle() { return this.findByAccessibilityId('biometric_auth_toggle'); }
    get pushNotificationToggle() { return this.findByAccessibilityId('push_notifications_toggle'); }
    get faqHeader() { return this.findByAccessibilityId('faq_header_item'); }
    
    get diagnosticsList() { return this.findByAccessibilityId('diagnostics_list_view'); }
    get railwayStatusCheck() { return this.findByAccessibilityId('railway_api_status_badge'); }

    async toggleBiometrics() {
        const toggle = await this.biometricToggle;
        await this.click(toggle);
    }

    async toggleNotifications() {
        const toggle = await this.pushNotificationToggle;
        await this.click(toggle);
    }
}

module.exports = new SettingsPage();
