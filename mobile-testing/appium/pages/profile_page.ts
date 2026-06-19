import { BasePage } from './base_page';
import { logger } from '../utilities/logger';

declare const browser: any;

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
        if (await this.isDisplayed('~editProfileRow')) {
            await this.click('~editProfileRow');
        }
        if (await this.isDisplayed(this.nameInput)) {
            await this.setValue(this.nameInput, name);
        }
        if (await this.isDisplayed(this.emailInput)) {
            await this.setValue(this.emailInput, email);
        }
    }

    public async clickSave() {
        if (await this.isDisplayed(this.saveButton)) {
            await this.click(this.saveButton);
        }
    }

    public async updateBudget(budget: string) {
        if (await this.isDisplayed('~editBudgetButton')) {
            await this.click('~editBudgetButton');
            try {
                await browser.waitUntil(async () => await browser.isAlertOpen(), {
                    timeout: 5000,
                    timeoutMsg: 'Budget alert did not appear'
                });
                if (await this.isDisplayed(this.budgetInput)) {
                    await this.setValue(this.budgetInput, budget);
                }
                await browser.acceptAlert();
            } catch (err: any) {
                // Handled
            }
        }
    }

    public async scrollToLogout() {
        // logoutProfileButton is at the bottom of a long ScrollView
        // 'mobile: scroll' direction:'down' = scrolls down = reveals bottom elements
        await browser.waitUntil(async () => {
            try {
                const el = await this.findElement('~logoutProfileButton');
                if (await el.isDisplayed()) return true;
            } catch (e) {}
            // Scroll down (reveals content below/at bottom of page)
            await browser.execute('mobile: scroll', { direction: 'down' });
            await browser.pause(300);
            return false;
        }, {
            timeout: 20000,
            timeoutMsg: 'logoutProfileButton not visible after scrolling'
        });
    }

    public async clickLogout() {
        await this.click(this.logoutButton);
        await browser.pause(1000);
        try {
            const btn = await browser.$('-ios predicate string:label == "Logout" AND type == "XCUIElementTypeButton"');
            if (await btn.isDisplayed()) {
                await btn.click();
                logger.info('Tapped Logout button on confirmation alert');
                await browser.pause(1000);
                return;
            }
        } catch (e) {}
        try {
            await browser.acceptAlert();
            logger.info('Dismissed logout alert via acceptAlert');
        } catch (err: any) {
            logger.warn(`Failed to dismiss logout alert: ${err.message}`);
        }
    }
}
export const profilePage = new ProfilePage();
