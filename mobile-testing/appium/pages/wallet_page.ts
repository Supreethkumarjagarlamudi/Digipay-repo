import { BasePage } from './base_page';

export class WalletPage extends BasePage {
    // Selectors
    public get spentAmount() { return '~totalSpentText'; }
    public get budgetProgress() { return '~budgetProgressBar'; }
    public get transactionList() { return '~transactionList'; }
    public get addExpenseButton() { return '~addExpenseBtn'; }
    public get expenseTitleInput() { return '~expenseTitleField'; }
    public get expenseAmountInput() { return '~expenseAmountField'; }
    public get expenseCategorySelector() { return '~expenseCategoryPicker'; }
    public get saveExpenseButton() { return '~saveExpenseBtn'; }

    // Actions
    public async getSpentAmountText(): Promise<string> {
        return this.getText(this.spentAmount);
    }

    public async clickAddExpense() {
        await this.click(this.addExpenseButton);
    }

    public async addNewExpense(title: string, amount: string, category: string) {
        await this.setValue(this.expenseTitleInput, title);
        await this.setValue(this.expenseAmountInput, amount);
        await this.click(this.expenseCategorySelector);
        // Select category helper
        await this.click(`~categoryOption_${category}`);
        await this.click(this.saveExpenseButton);
    }
}
export const walletPage = new WalletPage();
