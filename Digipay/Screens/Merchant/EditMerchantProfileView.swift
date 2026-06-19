import SwiftUI
import CoreLocation

struct EditMerchantProfileView: View {
    @ObservedObject var dashboardVM: MerchantHomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var businessName = ""
    @State private var ownerName = ""
    @State private var category = "Food"
    @State private var gstNumber = ""
    @State private var descriptionText = ""
    @State private var latitudeString = ""
    @State private var longitudeString = ""
    @State private var upiDeepLink = ""
    
    @State private var isSaving = false
    @State private var saveErrorMessage: String? = nil
    @State private var showSuccessAlert = false
    @State private var showScanner = false
    
    @StateObject private var locationManager = CustomerLocationManager()

    enum Field: Hashable {
        case businessName, ownerName, gstNumber, descriptionText, latitude, longitude, upiDeepLink
    }
    @FocusState private var focusedField: Field?

    let categories = ["Food", "Medical", "Shopping", "Retail", "Bills", "Entertainment", "Other"]

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                            Text("Back")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppColors.primaryBlue)
                    }
                    .accessibilityIdentifier("editProfileBackButton")
                    Spacer()
                    Text("Edit Shop Details")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Text("Back").hidden()
                }
                .padding()
                .background(AppColors.primaryBackground)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Section: Basic Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Shop Information")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            VStack(spacing: 12) {
                                inputField(label: "Business Name", text: $businessName, placeholder: "e.g. Starbucks Corner", field: .businessName, accessibilityId: "editMerchantBusinessNameInput")
                                inputField(label: "Owner Name", text: $ownerName, placeholder: "e.g. Sanjay Gupta", field: .ownerName, accessibilityId: "editMerchantOwnerNameInput")
                                
                                // Category Selector
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Business Category")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Picker("Category", selection: $category) {
                                        ForEach(categories, id: \.self) { cat in
                                            Text(cat).tag(cat)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accessibilityIdentifier("editMerchantCategoryPicker")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(AppColors.primaryBackground)
                                    .cornerRadius(12)
                                }
                                
                                inputField(label: "GST Number (Optional)", text: $gstNumber, placeholder: "e.g. 29AAAAA1111A1Z1", field: .gstNumber, accessibilityId: "editMerchantGstInput")
                                inputField(label: "Description (Optional)", text: $descriptionText, placeholder: "e.g. Gourmet bakery and hot coffee.", field: .descriptionText, accessibilityId: "editMerchantDescriptionInput")
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                        }
                        
                        // Section: Location and GPS Telemetry
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Location Coordinates Context")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            VStack(spacing: 12) {
                                inputField(label: "Latitude", text: $latitudeString, placeholder: "e.g. 12.972", field: .latitude, accessibilityId: "editMerchantLatitudeInput").keyboardType(.decimalPad)
                                inputField(label: "Longitude", text: $longitudeString, placeholder: "e.g. 77.595", field: .longitude, accessibilityId: "editMerchantLongitudeInput").keyboardType(.decimalPad)
                                
                                Button(action: refreshCoordinates) {
                                    HStack {
                                        Image(systemName: "location.circle.fill")
                                            .font(.body)
                                        Text("Refresh Coordinates (GPS)")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.secondaryCyan)
                                    .cornerRadius(14)
                                }
                                .accessibilityIdentifier("refreshCoordinatesButton")
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                        }
                        
                        // Section: UPI Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Payments Settings")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            VStack(spacing: 12) {
                                inputField(label: "UPI Deep Link", text: $upiDeepLink, placeholder: "upi://pay?pa=merchant@upi&pn=BusinessName", field: .upiDeepLink, accessibilityId: "editMerchantUpiInput")
                                
                                Button(action: { showScanner = true }) {
                                    HStack {
                                        Image(systemName: "qrcode.viewfinder")
                                            .font(.body)
                                        Text("Scan QR Code")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primaryBlue)
                                    .cornerRadius(14)
                                }
                                .accessibilityIdentifier("scanQrCodeButton")
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                        }
                        
                        if let errorMsg = saveErrorMessage {
                            Text(errorMsg)
                                .font(.caption)
                                .foregroundColor(AppColors.errorRed)
                                .padding(.horizontal)
                        }
                        
                        // Submit Button
                        Button(action: saveChanges) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Save Changes")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(businessName.isEmpty || ownerName.isEmpty || upiDeepLink.isEmpty || isSaving ? Color.gray.opacity(0.4) : AppColors.primaryBlue)
                            .cornerRadius(18)
                        }
                        .accessibilityIdentifier("saveChangesButton")
                        .disabled(businessName.isEmpty || ownerName.isEmpty || upiDeepLink.isEmpty || isSaving)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .accessibilityIdentifier("keyboardDoneButton")
            }
        }
        .onAppear {
            self.businessName = dashboardVM.businessName
            self.ownerName = dashboardVM.ownerName
            self.category = dashboardVM.category
            self.gstNumber = dashboardVM.gstNumber
            self.descriptionText = dashboardVM.descriptionText
            self.latitudeString = String(format: "%.6f", dashboardVM.latitude)
            self.longitudeString = String(format: "%.6f", dashboardVM.longitude)
            self.upiDeepLink = dashboardVM.upiDeepLink
        }
        .onChange(of: locationManager.locationReady) { _, ready in
            if ready {
                self.latitudeString = String(format: "%.6f", locationManager.latitude)
                self.longitudeString = String(format: "%.6f", locationManager.longitude)
            }
        }
        .alert("Shop Updated", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your merchant business context has been successfully updated on the server.")
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView(scannedCode: $upiDeepLink)
        }
    }
    
    private func inputField(label: String, text: Binding<String>, placeholder: String, field: Field, accessibilityId: String = "") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.secondaryText)
            
            TextField(placeholder, text: text)
                .accessibilityIdentifier(accessibilityId)
                .focused($focusedField, equals: field)
                .padding()
                .background(AppColors.primaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.borderColor.opacity(0.4), lineWidth: 1)
                )
        }
    }
    
    private func refreshCoordinates() {
        locationManager.requestLocation()
    }
    
    private func saveChanges() {
        isSaving = true
        saveErrorMessage = nil
        
        let lat = Double(latitudeString) ?? 0.0
        let lon = Double(longitudeString) ?? 0.0
        
        Task {
            do {
                try await dashboardVM.updateMerchantDetails(
                    businessName: businessName,
                    ownerName: ownerName,
                    category: category,
                    gstNumber: gstNumber.isEmpty ? nil : gstNumber,
                    descriptionText: descriptionText.isEmpty ? nil : descriptionText,
                    latitude: lat,
                    longitude: lon,
                    upiDeepLink: upiDeepLink
                )
                await MainActor.run {
                    isSaving = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    saveErrorMessage = "Update failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
