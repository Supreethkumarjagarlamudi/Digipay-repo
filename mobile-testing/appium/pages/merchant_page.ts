import { BasePage } from './base_page';

export class MerchantPage extends BasePage {
    // Basic Info Screen
    public get businessNameInput() { return '~merchantNameInput'; }
    public get ownerNameInput() { return '~merchantOwnerNameInput'; }
    public get categoryPicker() { return '~merchantCategoryPicker'; }
    public get gstInput() { return '~merchantGstInput'; }
    public get descriptionInput() { return '~merchantDescriptionInput'; }
    public get basicInfoSubmitButton() { return '~merchantRegisterSubmit'; }

    // Location Screen
    public get locationSpinner() { return '~locationStatusSpinner'; }
    public get altitudeTelemetry() { return '~altitudeChip'; }
    public get accuracyTelemetry() { return '~accuracyChip'; }
    public get headingTelemetry() { return '~headingChip'; }
    public get speedTelemetry() { return '~speedChip'; }
    public get continueLocationButton() { return '~continueLocationButton'; }

    // UPI Scan Screen
    public get openScannerButton() { return '~openScannerButton'; }
    public get mockScanQrButton() { return '~mockScanQrButton'; }
    public get completeRegistrationButton() { return '~completeMerchantRegistrationButton'; }

    // Dashboard Screen
    public get editProfileButton() { return '~editMerchantProfileButton'; }
    public get logoutButton() { return '~merchantLogoutButton'; }
    public get viewStatementButton() { return '~viewStatementButton'; }

    // Edit Profile Screen
    public get editBackButton() { return '~editProfileBackButton'; }
    public get editBusinessNameInput() { return '~editMerchantBusinessNameInput'; }
    public get editOwnerNameInput() { return '~editMerchantOwnerNameInput'; }
    public get editCategoryPicker() { return '~editMerchantCategoryPicker'; }
    public get editGstInput() { return '~editMerchantGstInput'; }
    public get editDescriptionInput() { return '~editMerchantDescriptionInput'; }
    public get editLatitudeInput() { return '~editMerchantLatitudeInput'; }
    public get editLongitudeInput() { return '~editMerchantLongitudeInput'; }
    public get editUpiInput() { return '~editMerchantUpiInput'; }
    public get refreshCoordinatesButton() { return '~refreshCoordinatesButton'; }
    public get scanQrCodeButton() { return '~scanQrCodeButton'; }
    public get saveChangesButton() { return '~saveChangesButton'; }

    // Payments History Screen
    public get historyBackButton() { return '~paymentsHistoryBackButton'; }
    public get historySearchField() { return '~paymentsHistorySearchField'; }
    public get historySearchClearButton() { return '~paymentsHistorySearchClearButton'; }

    // Actions
    public async fillBasicInfo(businessName: string, ownerName: string, category: string, gst: string, desc: string) {
        await this.setValue(this.businessNameInput, businessName);
        await this.setValue(this.ownerNameInput, ownerName);
        await this.click(this.categoryPicker);
        await this.click(`~categoryOption_${category}`);
        await this.setValue(this.gstInput, gst);
        await this.setValue(this.descriptionInput, desc);
        await this.click(this.basicInfoSubmitButton);
    }
}
export const merchantPage = new MerchantPage();
