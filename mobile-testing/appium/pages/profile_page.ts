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
                if (await browser.isAlertOpen()) {
                    await browser.sendAlertText(budget);
                    await browser.pause(500);
                    
                    // Click Save button directly
                    const saveBtn = await browser.$('-ios predicate string:label == "Save" AND type == "XCUIElementTypeButton"');
                    if (await saveBtn.isDisplayed()) {
                        await saveBtn.click();
                    } else {
                        await browser.acceptAlert();
                    }
                    await browser.pause(1000);
                }
            } catch (err: any) {
                try {
                    const cancelBtn = await browser.$('-ios predicate string:label == "Cancel" AND type == "XCUIElementTypeButton"');
                    if (await cancelBtn.isDisplayed()) {
                        await cancelBtn.click();
                    } else if (await browser.isAlertOpen()) {
                        await browser.dismissAlert();
                    }
                } catch (dismissErr) {}
            }
        }
    }

    public async scrollToLogout() {
        // try finding the element
        for (let i = 0; i < 6; i++) {
            try {
                const el = await this.findElement('~logoutProfileButton');
                if (await el.isDisplayed()) return;
            } catch (e) {}
            // Touch action scroll down fallback: swipe up (from y: 600 to y: 200) to reveal bottom content
            try {
                await browser.execute('mobile: dragFromToForDuration', {
                    duration: 0.5,
                    fromX: 200,
                    fromY: 500,
                    toX: 200,
                    toY: 200
                });
            } catch (e) {
                try {
                    await browser.execute('mobile: scroll', { direction: 'down' });
                } catch (scrollError) {}
            }
            await browser.pause(800);
        }
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
