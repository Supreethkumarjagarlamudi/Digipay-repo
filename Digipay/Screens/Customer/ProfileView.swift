import SwiftUI

struct ProfileView: View {

    @AppStorage("isLoggedIn")
    private var isLoggedIn = false

    @EnvironmentObject
    private var session: SessionManager

    @State private var showLogoutAlert = false
    
    // Payment Settings states
    @State private var showBudgetAlert = false
    @State private var showIncomeAlert = false
    @State private var budgetInput = ""
    @State private var incomeInput = ""
    
    @State private var showResetConfirm = false
    @State private var showResetSuccess = false
    
    @State private var isExporting = false
    @State private var exportItems: [Any] = []
    @State private var showShareSheet = false
    @State private var exportErrorMessage: String? = nil

    var body: some View {

        NavigationStack {

            ZStack {

                AppColors.primaryBackground
                    .ignoresSafeArea()

                ScrollView(
                    showsIndicators: false
                ) {

                    VStack(
                        spacing: 24
                    ) {

                        profileHeader

                        accountSection
                        
                        paymentSettingsSection

                        supportSection

                        appInfoSection

                        logoutButton
                    }
                    .padding()
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            
            // Logout confirmation
            .alert(
                "Logout",
                isPresented: $showLogoutAlert
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            
            // Budget Edit dialog
            .alert("Edit Monthly Budget", isPresented: $showBudgetAlert) {
                TextField("Budget limit (₹)", text: $budgetInput)
                    .accessibilityIdentifier("profileBudgetInput")
                    .keyboardType(.decimalPad)
                Button("Save") {
                    if let val = Double(budgetInput), val > 0 {
                        updateBudget(val)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your new monthly spending limit.")
            }
            
            // Income Edit dialog
            .alert("Edit Monthly Income", isPresented: $showIncomeAlert) {
                TextField("Monthly Income (₹)", text: $incomeInput)
                    .accessibilityIdentifier("profileIncomeInput")
                    .keyboardType(.decimalPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                    }
                Button("Save") {
                    if let val = Double(incomeInput), val > 0 {
                        updateIncome(val)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your new monthly income.")
            }
            
            // Reset confirmation
            .alert("Reset Statistics", isPresented: $showResetConfirm) {
                Button("Reset Everything", role: .destructive) {
                    resetStatistics()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset your transaction analytics. This action cannot be undone.")
            }
            
            // Reset Success dialog
            .alert("Success", isPresented: $showResetSuccess) {
                Button("OK") {}
            } message: {
                Text("Financial statistics have been successfully reset.")
            }
            
            // Export Error dialog
            .alert("Export Failed", isPresented: Binding(
                get: { exportErrorMessage != nil },
                set: { if !$0 { exportErrorMessage = nil } }
            )) {
                Button("OK") {}
            } message: {
                Text(exportErrorMessage ?? "")
            }
            
            // Share Sheet presenter
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: exportItems)
            }
            .onAppear {
                Task {
                    await session.fetchAndSyncProfile()
                }
            }
        }
    }
}

// MARK: - HEADER

extension ProfileView {

    private var profileHeader: some View {

        VStack(
            spacing: 16
        ) {

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryBlue,
                            AppColors.secondaryCyan
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: 110,
                    height: 110
                )
                .overlay {

                    Image(systemName: "person.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }

            VStack(
                spacing: 6
            ) {

                Text(
                    session.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "Complete Profile"
                    : session.fullName
                )
                .font(.title2.bold())
                .foregroundColor(AppColors.primaryText)

                if !session.phoneNumber.isEmpty {
                    Text(session.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }

                Text(session.role.rawValue.capitalized)
                    .font(.caption.bold())
                    .foregroundColor(AppColors.primaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primaryBlue.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 2)
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.top)
    }
}

// MARK: - ACCOUNT

extension ProfileView {

    private var accountSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionTitle(
                "Account"
            )

            NavigationLink(destination: EditProfileView().environmentObject(session)) {
                ProfileRow(
                    icon: "person.crop.circle.fill",
                    title: "Edit Profile"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("editProfileRow")

            NavigationLink(destination: PrivacySecurityView()) {
                ProfileRow(
                    icon: "lock.shield.fill",
                    title: "Privacy & Security"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: NotificationsSubView()) {
                ProfileRow(
                    icon: "bell.badge.fill",
                    title: "Notifications"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - PAYMENT SETTINGS

extension ProfileView {
    
    private var paymentSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Payment Settings")
            
            NavigationLink(destination: UPIAppSelectorView().environmentObject(session)) {
                HStack {
                    Image(systemName: "creditcard.and.123")
                        .frame(width: 24)
                    Text("Default UPI App")
                    Spacer()
                    Text(session.defaultUPIApp)
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryBlue)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(18)
            }
            .buttonStyle(.plain)
            
            Button {
                budgetInput = String(format: "%.0f", session.monthlyBudget)
                showBudgetAlert = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 24)
                    Text("Monthly Budget")
                    Spacer()
                    Text("₹\(Int(session.monthlyBudget))")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(18)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("editBudgetButton")
            
            Button {
                incomeInput = String(format: "%.0f", session.monthlyIncome)
                showIncomeAlert = true
            } label: {
                HStack {
                    Image(systemName: "banknote.fill")
                        .frame(width: 24)
                    Text("Monthly Income")
                    Spacer()
                    Text("₹\(Int(session.monthlyIncome))")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(18)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("editIncomeButton")
            
            Button {
                showResetConfirm = true
            } label: {
                ProfileRow(
                    icon: "arrow.counterclockwise.circle.fill",
                    title: "Reset Statistics"
                )
                .foregroundColor(AppColors.errorRed)
            }
            .buttonStyle(.plain)
            
            Button(action: exportTransactions) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .frame(width: 24)
                    if isExporting {
                        Text("Exporting...")
                        Spacer()
                        ProgressView()
                            .tint(AppColors.primaryBlue)
                    } else {
                        Text("Export Transactions (CSV)")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(18)
            }
            .buttonStyle(.plain)
            .disabled(isExporting)
        }
    }
}

// MARK: - SUPPORT

extension ProfileView {

    private var supportSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionTitle(
                "Support"
            )

            NavigationLink(destination: HelpSupportView()) {
                ProfileRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: ContactUsView()) {
                ProfileRow(
                    icon: "envelope.fill",
                    title: "Contact Us"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - APP INFO

extension ProfileView {

    private var appInfoSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionTitle(
                "App Information"
            )

            NavigationLink(destination: GenericInfoView(
                title: "Terms & Conditions",
                contentText: "DIGIPAY Terms and Conditions specify rules for utilizing the contextual payment system. By scanning UPI codes or configuring telemetry location parameters, you consent to secure HMAC validation of location coordinates for the purpose of identifying nearby merchants and enabling context-sensitive peer-to-peer wallet transfers."
            )) {
                ProfileRow(
                    icon: "doc.text.fill",
                    title: "Terms & Conditions"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: GenericInfoView(
                title: "Privacy Policy",
                contentText: "Our Privacy Policy describes how we secure your altitude, speed, and GPS coordinates. Telemetry location metrics are solely processed to map nearby registered merchants and verify that transactions originate within legitimate merchant bounds. Personal details are never exposed to external or unencrypted redirect links."
            )) {
                ProfileRow(
                    icon: "shield.fill",
                    title: "Privacy Policy"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: GenericInfoView(
                title: "About DIGIPAY",
                contentText: "DIGIPAY is a state-of-the-art secure contextual payment platform. It simplifies merchant discovery and payment routing by scanning context attributes on-device, offering a frictionless single-tap payment experience for customers and store owners alike."
            )) {
                ProfileRow(
                    icon: "info.circle.fill",
                    title: "About DIGIPAY"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: SystemDiagnosticsView().environmentObject(session)) {
                ProfileRow(
                    icon: "cpu.fill",
                    title: "System Diagnostics"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - LOGOUT

extension ProfileView {

    private var logoutButton: some View {

        Button {

            showLogoutAlert = true

        } label: {

            HStack {

                Image(
                    systemName:
                    "rectangle.portrait.and.arrow.right"
                )

                Text("Logout")
                    .fontWeight(.bold)
            }
            .foregroundColor(AppColors.secondaryBackground)

            .frame(
                maxWidth: .infinity
            )

            .frame(height: 58)

            .background(
                AppColors.errorRed
            )

            .cornerRadius(18)
        }
        .accessibilityIdentifier("logoutProfileButton")
        .padding(.top, 12)
    }

    private func logout() {
        session.logout()
    }
}

// MARK: - ACTIONS & HELPERS

extension ProfileView {

    private func sectionTitle(
        _ title: String
    ) -> some View {

        HStack {

            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .padding(.leading, 4)

            Spacer()
        }
    }
    
    private func updateBudget(_ value: Double) {
        session.monthlyBudget = value
        UserDefaults.standard.set(value, forKey: "monthlyBudget")
        
        Task {
            do {
                try await UserService.shared.updateProfile(
                    fullName: session.fullName.isEmpty ? "Complete Profile" : session.fullName,
                    email: nil,
                    role: session.role.rawValue,
                    monthlyBudget: value,
                    monthlyIncome: session.monthlyIncome
                )
                NotificationCenter.default.post(name: NSNotification.Name("WalletTransactionCreated"), object: nil)
            } catch {
                print("Failed to sync budget to backend:", error)
            }
        }
    }
    
    private func updateIncome(_ value: Double) {
        session.monthlyIncome = value
        UserDefaults.standard.set(value, forKey: "monthlyIncome")
        
        Task {
            do {
                try await UserService.shared.updateProfile(
                    fullName: session.fullName.isEmpty ? "Complete Profile" : session.fullName,
                    email: nil,
                    role: session.role.rawValue,
                    monthlyBudget: session.monthlyBudget,
                    monthlyIncome: value
                )
                NotificationCenter.default.post(name: NSNotification.Name("WalletTransactionCreated"), object: nil)
            } catch {
                print("Failed to sync income to backend:", error)
            }
        }
    }
    
    private func resetStatistics() {
        // Trigger statistics reload/reset notification
        NotificationCenter.default.post(name: NSNotification.Name("WalletTransactionCreated"), object: nil)
        showResetSuccess = true
    }
    
    private func exportTransactions() {
        isExporting = true
        exportErrorMessage = nil
        
        Task {
            do {
                let payload = try await WalletService.shared.fetchAnalytics()
                
                var csvString = "ID,Merchant Name,Amount (INR),Category,Timestamp,Latitude,Longitude\n"
                for tx in payload.recent_transactions {
                    let lat = tx.latitude != nil ? "\(tx.latitude!)" : ""
                    let lon = tx.longitude != nil ? "\(tx.longitude!)" : ""
                    csvString += "\(tx.id),\"\(tx.merchant_name)\",\(tx.amount),\"\(tx.category)\",\"\(tx.timestamp)\",\(lat),\(lon)\n"
                }
                
                let tempDirectory = FileManager.default.temporaryDirectory
                let fileURL = tempDirectory.appendingPathComponent("Digipay_Transactions_Export.csv")
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                await MainActor.run {
                    self.isExporting = false
                    self.exportItems = [fileURL]
                    self.showShareSheet = true
                }
            } catch {
                await MainActor.run {
                    self.isExporting = false
                    self.exportErrorMessage = "Could not fetch or format transaction records: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - SUBVIEWS & HELPERS

struct UPIAppSelectorView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    let apps = ["Ask Every Time", "Google Pay", "PhonePe", "Paytm", "BHIM"]

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
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
                    Text("Default UPI App")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Text("Back").hidden()
                }
                .padding()
                .background(AppColors.primaryBackground)

                List {
                    ForEach(apps, id: \.self) { app in
                        Button {
                            session.defaultUPIApp = app
                            UserDefaults.standard.set(app, forKey: "defaultUPIApp")
                            dismiss()
                        } label: {
                            HStack {
                                Text(app)
                                    .foregroundColor(AppColors.primaryText)
                                Spacer()
                                if session.defaultUPIApp == app {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primaryBlue)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                    .listRowBackground(AppColors.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ProfileRow: View {

    let icon: String
    let title: String

    var body: some View {

        HStack {

            Image(
                systemName: icon
            )
            .frame(width: 24)

            Text(title)

            Spacer()

            Image(
                systemName:
                "chevron.right"
            )
            .font(.caption)
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(18)
    }
}
