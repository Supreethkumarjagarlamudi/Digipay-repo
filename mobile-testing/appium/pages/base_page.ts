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

    public async scrollIntoView(selector: string, timeout = 20000) {
        logger.info(`Scrolling into view: ${selector}`);
        await browser.waitUntil(async () => {
            try {
                const el = await this.findElement(selector);
                if (await el.isDisplayed()) return true;
            } catch (e) {}
            await browser.execute('mobile: scroll', { direction: 'down' });
            await browser.pause(300);
            return false;
        }, {
            timeout,
            timeoutMsg: `Element ${selector} not visible after scrolling`
        });
    }

    public async scrollUpIntoView(selector: string, timeout = 20000) {
        logger.info(`Scrolling up into view: ${selector}`);
        await browser.waitUntil(async () => {
            try {
                const el = await this.findElement(selector);
                if (await el.isDisplayed()) return true;
            } catch (e) {}
            await browser.execute('mobile: scroll', { direction: 'up' });
            await browser.pause(300);
            return false;
        }, {
            timeout,
            timeoutMsg: `Element ${selector} not visible after scrolling up`
        });
    }


    public async click(selector: string) {
        logger.info(`Clicking element: ${selector}`);
        if (!(await this.isDisplayed(selector))) {
            try {
                await this.scrollIntoView(selector, 4000);
            } catch (e) {
                try {
                    await this.scrollUpIntoView(selector, 4000);
                } catch (upError) {
                    logger.info(`Scroll in both directions failed for: ${selector}`);
                }
            }
        }
        const el = await this.waitForDisplayed(selector);
        await el.click();
    }

    public async setValue(selector: string, value: string) {
        logger.info(`Setting value for element: ${selector}`);
        if (!(await this.isDisplayed(selector))) {
            try {
                await this.scrollIntoView(selector, 4000);
            } catch (e) {
                try {
                    await this.scrollUpIntoView(selector, 4000);
                } catch (upError) {
                    logger.info(`Scroll in both directions failed for: ${selector}`);
                }
            }
        }
        const el = await this.waitForDisplayed(selector);
        await el.setValue(value);
        await browser.pause(500);
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
        // 1. Wait for the alert to actually be present on screen
        try {
            await browser.waitUntil(async () => {
                try {
                    await browser.getAlertText();
                    return true;
                } catch (e) { return false; }
            }, { timeout: 4000, timeoutMsg: 'no system alert appeared' });
        } catch (e) {
            logger.info('dismissSystemAlerts: No alert appeared');
            return;
        }

        const allowLabels = [
            'Allow While Using App',
            'Allow Once',
            'Allow',
            'OK'
        ];

        // 2. Try mobile: alert first (most reliable for system dialogs)
        try {
            const buttons = await browser.execute('mobile: alert', { action: 'getButtons' }) as string[];
            logger.info(`System alert buttons found: ${JSON.stringify(buttons)}`);
            for (const label of allowLabels) {
                if (buttons.includes(label)) {
                    await browser.execute('mobile: alert', { action: 'accept', buttonLabel: label });
                    logger.info(`Dismissed system dialog using mobile:alert and tapping: ${label}`);
                    await browser.pause(1000);
                    return;
                }
            }
        } catch (err: any) {
            logger.info(`mobile: alert interaction failed: ${err.message}. Trying element-based fallback...`);
        }

        // 3. Fallback: Try tapping common allow/grant buttons via predicate search
        for (const label of allowLabels) {
            try {
                const btn = await browser.$(`-ios predicate string:label == "${label}" AND type == "XCUIElementTypeButton"`);
                if (await btn.isDisplayed()) {
                    await btn.click();
                    logger.info(`Dismissed system dialog by tapping: ${label}`);
                    await browser.pause(500);
                    return;
                }
            } catch (e) {}
        }

        // 4. Fallback to standard acceptAlert if none of the custom buttons matched
        try {
            await browser.acceptAlert();
            logger.info('Dismissed system alert via acceptAlert fallback');
        } catch (e: any) {
            logger.warn(`Failed acceptAlert fallback: ${e.message}`);
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
