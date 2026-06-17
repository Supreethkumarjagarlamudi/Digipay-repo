"""
wallet_page.py - Page Object for WalletView (Wallet Intelligence)
Digipay iOS App
"""

from pages.base_page import BasePage


class WalletPage(BasePage):
    """Customer wallet screen: balance, budget, pie chart, transactions."""

    WALLET_TITLE        = "Wallet Intelligence"
    SUBTITLE            = "Real-time telemetry-backed expenses"
    EST_BALANCE         = "Estimated Balance"
    EXPENSE_BREAKDOWN   = "Expense Breakdown"
    BUDGET_USAGE        = "Budget Usage"
    CONTEXT_INTEL       = "Context Intelligence Insights"
    AI_SECTION          = "AI Expense Intelligence"
    RECENT_TXN          = "Recent Transactions"
    MONTHLY_INCOME      = "Monthly Income"
    MONTHLY_BUDGET      = "Monthly Budget"
    TOTAL_SPENT         = "Total Spent"
    REMAINING_BUDGET    = "Remaining Budget"
    AUTO_TRACKED        = "Auto-tracked"
    SPARKLES_ICON       = "sparkles"
    PEAK_HOUR_LABEL     = "Peak Spending Hour"
    LOCATION_INSIGHTS   = "Location Insights"

    # ─ Actions ────────────────────────────────────────────────────────────────

    def pull_to_refresh(self):
        size = self.driver.get_window_size()
        self.driver.swipe(
            size["width"] // 2, int(size["height"] * 0.2),
            size["width"] // 2, int(size["height"] * 0.7),
            800
        )

    def scroll_to_transactions(self):
        self.scroll_to_element(self.RECENT_TXN)

    def scroll_to_ai_insights(self):
        self.scroll_to_element(self.AI_SECTION)

    def scroll_to_budget(self):
        self.scroll_to_element(self.BUDGET_USAGE)

    # ─ Assertions ─────────────────────────────────────────────────────────────

    def is_wallet_visible(self) -> bool:
        return self.is_visible(self.WALLET_TITLE)

    def is_balance_card_visible(self) -> bool:
        return self.is_visible(self.EST_BALANCE)

    def is_expense_breakdown_visible(self) -> bool:
        return self.is_visible(self.EXPENSE_BREAKDOWN)

    def is_budget_section_visible(self) -> bool:
        return self.is_visible(self.BUDGET_USAGE)

    def is_context_intel_visible(self) -> bool:
        self.scroll_to_element(self.CONTEXT_INTEL)
        return self.is_visible(self.CONTEXT_INTEL)

    def is_ai_section_visible(self) -> bool:
        self.scroll_to_ai_insights()
        return self.is_visible(self.AI_SECTION)

    def is_transactions_visible(self) -> bool:
        self.scroll_to_transactions()
        return self.is_visible(self.RECENT_TXN)

    def is_monthly_income_card_visible(self) -> bool:
        return self.is_visible(self.MONTHLY_INCOME)

    def is_monthly_budget_card_visible(self) -> bool:
        return self.is_visible(self.MONTHLY_BUDGET)

    def is_total_spent_card_visible(self) -> bool:
        return self.is_visible(self.TOTAL_SPENT)

    def is_remaining_budget_card_visible(self) -> bool:
        return self.is_visible(self.REMAINING_BUDGET)

    def is_auto_tracked_visible(self) -> bool:
        return self.is_visible(self.AUTO_TRACKED)

    def is_subtitle_visible(self) -> bool:
        return self.is_visible(self.SUBTITLE)

    def get_balance_value(self) -> str:
        el = self.find_by_predicate(
            'label CONTAINS "₹" AND type == "XCUIElementTypeStaticText" AND value CONTAINS "."'
        )
        return el.text if el else ""

    def is_sparkles_icon_visible(self) -> bool:
        return self.is_visible(self.SPARKLES_ICON)
