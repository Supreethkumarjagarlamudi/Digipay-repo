import { logger } from '../utilities/logger';

declare const $: any;

export class BasePage {
    protected async findElement(selector: string) {
        return $(selector);
    }

    public async waitForDisplayed(selector: string, timeout = 10000) {
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
}
