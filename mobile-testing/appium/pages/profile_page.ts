import { BasePage } from './base_page';

export class ProfilePage extends BasePage {
    // Selectors
    public get nameInput() { return '~profileNameInput'; }
    public get emailInput() { return '~profileEmailInput'; }
    public get upiInput() { return '~profileUpiInput'; }
    public get budgetInput() { return '~profileBudgetInput'; }
    public get saveButton() { return '~saveProfileButton'; }
    public get logoutButton() { return '~logoutProfileButton'; }
    public get deleteAccountButton() { return '~deleteAccountButton'; }

    // Actions
    public async fillProfileData(name: string, email: string, upi: string, budget: string) {
        await this.setValue(this.nameInput, name);
        await this.setValue(this.emailInput, email);
        await this.setValue(this.upiInput, upi);
        await this.setValue(this.budgetInput, budget);
    }

    public async clickSave() {
        await this.click(this.saveButton);
    }

    public async clickLogout() {
        await this.click(this.logoutButton);
    }
}
export const profilePage = new ProfilePage();
