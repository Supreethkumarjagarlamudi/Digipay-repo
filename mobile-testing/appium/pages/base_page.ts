import { logger } from '../utilities/logger';

declare const $: any;
declare const $$: any;
declare const browser: any;

export class BasePage {
    protected async findElement(selector: string) {
        return $(selector);
    }

    public async waitForDisplayed(selector: string, timeout = 30000) {
        logger.info(`Waiting for element to be displayed: ${selector}`);
        const el = await this.findElement(selector);
        await el.waitForDisplayed({ timeout });
        return el;
    }

    public async click(selector: string) {
        logger.info(`Clicking element: ${selector}`);
        const el = await this.waitForDisplayed(selector);
        await el.click();
    }

    public async setValue(selector: string, value: string) {
        logger.info(`Setting value for element: ${selector}`);
        const el = await this.waitForDisplayed(selector);
        await el.setValue(value);
        try {
            if (await this.isDisplayed('~keyboardDoneButton')) {
                await this.click('~keyboardDoneButton');
            }
        } catch (err: any) {
            logger.info(`Dismiss keyboard error: ${err.message}`);
        }
    }

    public async addValue(selector: string, value: string) {
        logger.info(`Adding value for element: ${selector}`);
        const el = await this.waitForDisplayed(selector);
        await el.addValue(value);
    }

    public async getText(selector: string): Promise<string> {
        logger.info(`Getting text of element: ${selector}`);
        const el = await this.waitForDisplayed(selector);
        return el.getText();
    }

    public async isDisplayed(selector: string): Promise<boolean> {
        try {
            const el = await this.findElement(selector);
            return await el.isDisplayed();
        } catch {
            return false;
        }
    }

    public async getAttribute(selector: string, attributeName: string): Promise<string> {
        const el = await this.waitForDisplayed(selector);
        return el.getAttribute(attributeName);
    }

    public async clickHomeTab() {
        await this.click('~tab_home');
    }

    public async clickWalletTab() {
        await this.click('~tab_wallet');
    }

    public async clickDiscoverTab() {
        await this.click('~tab_discover');
    }

    public async clickProfileTab() {
        await this.click('~tab_profile');
    }

    public async isAlertOpen(): Promise<boolean> {
        try {
            await browser.getAlertText();
            return true;
        } catch {
            return false;
        }
    }

    public async waitForAlert(timeout = 5000): Promise<void> {
        await browser.waitUntil(async () => {
            return await this.isAlertOpen();
        }, {
            timeout,
            timeoutMsg: 'Alert did not appear'
        });
    }

    public async dismissSystemAlerts(): Promise<void> {
        // Dismiss any iOS system permission dialogs (location, notifications, etc.)
        // that may be blocking the UI
        try {
            await browser.waitUntil(async () => {
                try {
                    await browser.getAlertText();
                    return true;
                } catch (e) { return false; }
            }, { timeout: 2000, timeoutMsg: 'no system alert' });
            await browser.acceptAlert();
            logger.info('Dismissed system alert via acceptAlert');
            return;
        } catch (e) {}

        // Try tapping common allow buttons used in location/notification dialogs
        const allowLabels = [
            'Allow While Using App',
            'Allow Once',
            'Allow',
            'OK',
            'Don\'t Allow'
        ];
        for (const label of allowLabels) {
            try {
                const btn = await browser.$(`-ios predicate string:label == "${label}" AND type == "XCUIElementTypeButton"`);
                if (await btn.isDisplayed()) {
                    // For location we prefer "Allow While Using App"; for others just accept first hit
                    await btn.click();
                    logger.info(`Dismissed system dialog by tapping: ${label}`);
                    await browser.pause(500);
                    return;
                }
            } catch (e) {}
        }
    }

    public async handleOTPAlert(): Promise<string> {
        let otp = '123456';

        // Wait for the "Development Build" native iOS alert to appear
        await browser.waitUntil(async () => {
            try {
                const text = await browser.getAlertText();
                if (text && text.includes('OTP')) return true;
            } catch (e) {}

            try {
                // SwiftUI .alert renders as a native UIAlertController
                const alertEl = await $('~Development Build');
                if (await alertEl.isDisplayed()) return true;
            } catch (e) {}

            return false;
        }, {
            timeout: 30000,
            timeoutMsg: 'OTP alert did not appear within 30s'
        });

        // Extract 6-digit OTP from alert text
        try {
            const alertText = await browser.getAlertText();
            console.log('Alert text received:', alertText);
            const match = alertText.match(/\d{6}/);
            if (match) {
                otp = match[0];
                console.log('Extracted OTP from alert:', otp);
            }
        } catch (err: any) {
            console.log('getAlertText failed, falling back to element scan:', err.message);
            try {
                const staticTexts = await $$('XCUIElementTypeStaticText');
                for (const textEl of staticTexts) {
                    const label = await textEl.getAttribute('label');
                    if (!label) continue;
                    console.log('Scanning static text label:', label);
                    const match = label.match(/\d{6}/);
                    if (match) {
                        otp = match[0];
                        console.log('Extracted OTP from static text:', otp);
                        break;
                    }
                }
            } catch (elemErr: any) {
                console.log('Static text scan failed:', elemErr.message);
            }
        }

        // Dismiss the alert — try native acceptAlert first, then tap "Continue" button
        try {
            await browser.acceptAlert();
            console.log('Alert dismissed via acceptAlert()');
        } catch (err: any) {
            console.log('acceptAlert failed, tapping Continue button:', err.message);
            try {
                // "Continue" is the button label inside the SwiftUI .alert
                await $('~Continue').click();
                console.log('Alert dismissed by tapping ~Continue');
            } catch (clickErr: any) {
                console.log('Tapping ~Continue failed:', clickErr.message);
                // Last resort: try by button label text
                try {
                    const btn = await $('XCUIElementTypeButton[label="Continue"]');
                    await btn.click();
                    console.log('Alert dismissed by XCUIElementTypeButton Continue');
                } catch (btnErr: any) {
                    console.log('All dismiss attempts failed:', btnErr.message);
                }
            }
        }

        // CRITICAL: Wait for OTPView to finish navigating and otpInputField to appear
        // The SwiftUI .alert's "Continue" button sets navigateToOTP=true which triggers
        // a NavigationStack push — give it time to animate and render OTPView
        console.log(`OTP captured: ${otp}. Waiting for OTPView to appear...`);
        await browser.waitUntil(async () => {
            try {
                const otpField = await $('~otpInputField');
                return await otpField.isDisplayed();
            } catch (e) {
                return false;
            }
        }, {
            timeout: 12000,
            timeoutMsg: 'OTPView (~otpInputField) did not appear after alert was dismissed'
        });
        console.log('OTPView is ready. Returning OTP:', otp);

        return otp;
    }
}
