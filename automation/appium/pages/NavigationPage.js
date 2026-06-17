const BasePage = require('./BasePage');

class NavigationPage extends BasePage {
    get homeTab() { return this.findByAccessibilityId('Home Tab Icon'); }
    get discoverTab() { return this.findByAccessibilityId('Discover Tab Icon'); }
    get walletTab() { return this.findByAccessibilityId('Wallet Tab Icon'); }
    get profileTab() { return this.findByAccessibilityId('Profile Tab Icon'); }
    
    get backBtn() { return this.findByAccessibilityId('Back to Role Button'); }

    async selectHome() {
        const tab = await this.homeTab;
        await this.click(tab);
    }

    async selectDiscover() {
        const tab = await this.discoverTab;
        await this.click(tab);
    }

    async selectWallet() {
        const tab = await this.walletTab;
        await this.click(tab);
    }

    async selectProfile() {
        const tab = await this.profileTab;
        await this.click(tab);
    }
}

module.exports = new NavigationPage();
