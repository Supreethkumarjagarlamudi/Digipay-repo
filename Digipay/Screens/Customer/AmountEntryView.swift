import SwiftUI

struct AmountEntryView: View {
    let merchant: NearbyMerchant

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    @StateObject private var locationManager = CustomerLocationManager()

    @State private var amountString: String = ""
    @State private var showConfirmationAlert = false
    @State private var isProcessing = false
    @State private var showSuccessAnimation = false
    @State private var errorMessage: String? = nil
    @State private var notes: String = ""
    @State private var showFailureAlert = false
    @FocusState private var isInputActive: Bool

    private let presetAmounts = [100.0, 200.0, 500.0, 1000.0]

    private var parsedAmount: Double {
        Double(amountString.filter { "0123456789.".contains($0) }) ?? 0.0
    }

    private var isValidAmount: Bool {
        parsedAmount > 0.0
    }

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Navigation Bar
                customNavBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // Merchant Header Card
                        merchantCard
                        
                        // Currency Input Section
                        inputSection
                        
                        // Quick Presets
                        presetsSection
                        
                        // Actions & Info
                        VStack(spacing: 16) {
                            if let error = errorMessage {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.errorRed)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Pay Now Button
                            Button(action: initiatePayment) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                    Text("Pay ₹\(parsedAmount > 0.0 ? String(format: "%.2f", parsedAmount) : "0.00")")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(isValidAmount ? AppColors.primaryBlue : Color.gray.opacity(0.4))
                                .cornerRadius(18)
                                .shadow(color: isValidAmount ? AppColors.primaryBlue.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                            }
                            .accessibilityIdentifier("proceedToPayButton")
                            .padding(.horizontal, 24)
                            
                            Text("Secure payment routed via \(session.defaultUPIApp)")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }

            // Custom Glassmorphic Confirmation Modal
            if showConfirmationAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                customConfirmationPopup
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            // Success Loading Overlay
            if isProcessing || showSuccessAnimation {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if showSuccessAnimation {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.successGreen)
                                .scaleEffect(showSuccessAnimation ? 1.0 : 0.5)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: showSuccessAnimation)
                            
                            Text("Payment Recorded!")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Text("₹\(String(format: "%.2f", parsedAmount)) sent to \(merchant.business_name)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(AppColors.primaryBlue)
                                    .cornerRadius(12)
                            }
                            .accessibilityIdentifier("closeSuccessModalBtn")
                            .padding(.top, 8)
                        }
                        .padding(30)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .accessibilityIdentifier("paymentSuccessModal")
                    } else {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        
                        Text("Logging Transaction...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }

            // Failure Custom Alert Modal
            if showFailureAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 24) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.errorRed)
                    
                    Text("Payment Failed")
                        .font(.title3.bold())
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(errorMessage ?? "An error occurred while processing your payment.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showFailureAlert = false
                    } label: {
                        Text("Dismiss")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primaryBlue)
                            .cornerRadius(14)
                    }
                    .accessibilityIdentifier("closeFailureModalBtn")
                }
                .padding(24)
                .background(AppColors.cardBackground)
                .cornerRadius(24)
                .accessibilityIdentifier("paymentFailureModal")
                .padding(.horizontal, 40)
                .zIndex(3)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            locationManager.requestLocation()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputActive = false
                }
                .accessibilityIdentifier("keyboardDoneButton")
            }
        }
    }

    private var customNavBar: some View {
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
            Spacer()
            Text("Send Money")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
            Spacer()
            Text("Back").hidden()
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .background(AppColors.primaryBackground)
    }

    private var merchantCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "storefront.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(merchant.business_name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(merchant.category)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                let upiAddress = extractUPIAddress(from: merchant.upi_deep_link)
                if !upiAddress.isEmpty {
                    Text(upiAddress)
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Enter Amount")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                HStack(spacing: 4) {
                    Text("₹")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    TextField("0", text: $amountString)
                        .accessibilityIdentifier("paymentAmountInput")
                        .keyboardType(.decimalPad)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 240)
                        .focused($isInputActive)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (Optional)")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                TextField("Add notes", text: $notes)
                    .accessibilityIdentifier("paymentNotesInput")
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .focused($isInputActive)
            }
            .padding(.horizontal, 24)
        }
    }

    private var presetsSection: some View {
        HStack(spacing: 12) {
            ForEach(presetAmounts, id: \.self) { amount in
                Button {
                    amountString = String(format: "%.0f", amount)
                } label: {
                    Text("+ ₹\(Int(amount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }

    private var customConfirmationPopup: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primaryBlue)
                
                Text("Confirm Transaction")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.primaryText)
                
                Text("Did you complete the payment inside the UPI app?")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button {
                    withAnimation {
                        showConfirmationAlert = false
                    }
                    recordPayment()
                } label: {
                    Text("Yes, Record Transaction")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primaryBlue)
                        .cornerRadius(14)
                }
                
                Button {
                    withAnimation {
                        showConfirmationAlert = false
                    }
                } label: {
                    Text("No, Cancel")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.clear)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal)
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 40)
    }

    private func extractUPIAddress(from urlString: String) -> String {
        guard let components = URLComponents(string: urlString) else { return "" }
        return components.queryItems?.first(where: { $0.name == "pa" })?.value ?? ""
    }

    private func updateUPIAmount(deepLink: String, amount: Double) -> String {
        guard var components = URLComponents(string: deepLink) else { return deepLink }
        var queryItems = components.queryItems ?? []
        queryItems.removeAll { $0.name == "am" }
        queryItems.append(URLQueryItem(name: "am", value: String(format: "%.2f", amount)))
        components.queryItems = queryItems
        return components.url?.absoluteString ?? deepLink
    }

    private func initiatePayment() {
        guard isValidAmount else {
            errorMessage = "Please enter a valid amount greater than zero"
            showFailureAlert = true
            return
        }
        let finalDeepLink = updateUPIAmount(deepLink: merchant.upi_deep_link, amount: parsedAmount)
        UPIManager.shared.openUPILink(deepLink: finalDeepLink, preferredApp: session.defaultUPIApp)
        
        // Wait a short delay to allow the app transition, then show confirmation popup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showConfirmationAlert = true
            }
        }
    }

    private func recordPayment() {
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await WalletService.shared.createTransaction(
                    merchantName: merchant.business_name,
                    amount: parsedAmount,
                    category: merchant.category,
                    latitude: locationManager.latitude > 0.0 ? locationManager.latitude : nil,
                    longitude: locationManager.longitude > 0.0 ? locationManager.longitude : nil,
                    heading: locationManager.heading > 0.0 ? locationManager.heading : nil,
                    speed: locationManager.speed > 0.0 ? locationManager.speed : nil
                )
                
                await MainActor.run {
                    isProcessing = false
                    withAnimation {
                        showSuccessAnimation = true
                    }
                    
                    // Post a notification or handle dashboard reload
                    NotificationCenter.default.post(name: NSNotification.Name("WalletTransactionCreated"), object: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Failed to record payment on backend: \(error.localizedDescription)"
                }
            }
        }
    }
}
