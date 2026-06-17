class BasePage {
    get accessibilityIdSelector() {
        return (id) => `~${id}`;
    }

    get predicateSelector() {
        return (pred) => `-ios predicate string:${pred}`;
    }

    get classChainSelector() {
        return (chain) => `-ios class chain:${chain}`;
    }

    async findByAccessibilityId(id) {
        return $(this.accessibilityIdSelector(id));
    }

    async findByPredicate(pred) {
        return $(this.predicateSelector(pred));
    }

    async findByClassChain(chain) {
        return $(this.classChainSelector(chain));
    }

    async click(element) {
        await element.waitForDisplayed({ timeout: 10000 });
        await element.click();
    }

    async type(element, text) {
        await element.waitForDisplayed({ timeout: 10000 });
        await element.setValue(text);
    }

    async getText(element) {
        await element.waitForDisplayed({ timeout: 10000 });
        return await element.getText();
    }

    async isDisplayed(element) {
        try {
            return await element.isDisplayed();
        } catch (err) {
            return false;
        }
    }
}

module.exports = BasePage;
