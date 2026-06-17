const BasePage = require('./BasePage');

class ProfilePage extends BasePage {
    get editProfileBtn() { return this.findByAccessibilityId('Edit Profile Button'); }
    get nameField() { return this.findByAccessibilityId('Edit Name TextField'); }
    get saveProfileBtn() { return this.findByAccessibilityId('Save Profile Changes Button'); }
    
    get logoutBtn() { return this.findByAccessibilityId('Logout'); }
    get faqsLink() { return this.findByAccessibilityId('faq_header_item'); }
    get diagnosticsLink() { return this.findByAccessibilityId('System Diagnostics Navigation'); }

    async clickEditProfile() {
        const btn = await this.editProfileBtn;
        await this.click(btn);
    }

    async updateName(name) {
        const input = await this.nameField;
        await this.type(input, name);
        const save = await this.saveProfileBtn;
        await this.click(save);
    }
}

module.exports = new ProfilePage();
