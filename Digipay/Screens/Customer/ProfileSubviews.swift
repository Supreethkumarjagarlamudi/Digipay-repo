import SwiftUI
import LocalAuthentication
import UserNotifications

// MARK: - PRIVACY & SECURITY

struct PrivacySecurityView: View {
    @AppStorage("locationServicesEnabled") private var locationServices = true
    @AppStorage("endToEndEncryptionEnabled") private var endToEndEncryption = true
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: "Privacy & Security")
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Security Preferences")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                ToggleRow(icon: "location.fill", title: "Contextual Location Services", isEnabled: $locationServices)
                                ToggleRow(icon: "lock.shield.fill", title: "End-to-End Encryption", isEnabled: $endToEndEncryption)
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(18)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Data Protection Notice")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("DIGIPAY enforces strict cryptographic validation. Your context metrics (altitude, speed, location headers) are hashed locally using HMAC-SHA256 and only verified on-device or with secured production endpoints to prevent transaction spoofing.")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - NOTIFICATIONS

struct NotificationsSubView: View {
    @AppStorage("pushNotificationsEnabled") private var pushNotifications = false
    @AppStorage("transactionAlertsEnabled") private var transactionAlerts = true
    @AppStorage("smsAlertsEnabled") private var smsAlerts = false
    @AppStorage("promoAlertsEnabled") private var promoAlerts = false
    
    @State private var showNotificationError = false
    @State private var notificationErrorMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: "Notifications")
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notification Channels")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                ToggleRow(icon: "bell.fill", title: "Push Notifications", isEnabled: $pushNotifications)
                                ToggleRow(icon: "checkmark.circle.fill", title: "Instant Transaction Alerts", isEnabled: $transactionAlerts)
                                ToggleRow(icon: "message.fill", title: "SMS Backup Alerts", isEnabled: $smsAlerts)
                                ToggleRow(icon: "percent", title: "Promotions & Offers", isEnabled: $promoAlerts)
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(18)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Notifications Access Required", isPresented: $showNotificationError) {
            Button("OK") {}
        } message: {
            Text(notificationErrorMessage)
        }
        .onChange(of: pushNotifications) { _, enabled in
            if enabled {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("Notifications authorized successfully")
                            scheduleMockWelcomeNotification()
                        } else {
                            pushNotifications = false
                            notificationErrorMessage = error?.localizedDescription ?? "Please enable notification permissions for DIGIPAY in your device System Settings."
                            showNotificationError = true
                        }
                    }
                }
            }
        }
    }
    
    private func scheduleMockWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🛡️ DIGIPAY Security Active"
        content.body = "Real-time UPI budget notifications and transaction tracking are now enabled."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.5, repeats: false)
        let request = UNNotificationRequest(identifier: "welcome_notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("Failed to schedule local notification: \(err)")
            }
        }
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - HELP & SUPPORT

struct HelpSupportView: View {
    @State private var expandedFaq: Int? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    let faqs = [
        ("What is DIGIPAY?", "DIGIPAY is a context-aware payment application that uses advanced telemetry metrics (including location, altitude, heading, and speed) to identify merchants directly around you and verify payments in just a tap."),
        ("How does location-based payment work?", "Our system captures your current location metrics and references nearby merchant coordinates to suggest the exact store you're standing in, eliminating the need to search for UPI QR codes manually."),
        ("Are my payment details secure?", "Yes. DIGIPAY relies on secure, standard UPI deep links and hashes all sensitive transaction data. The backend operates over verified HTTPS protocols and blocks external redirects/clickjacking attempt vectors."),
        ("I'm experiencing payment failures. What do I do?", "Please ensure your location services are enabled. If a transaction fails to complete, check your network connection and verify with your bank app if your UPI ID is active."),
        ("How do I update my monthly budget limit?", "Go to the profile settings tab, tap 'Monthly Budget' under 'Payment Settings', enter your new limit in the prompt, and tap 'Save'. It will instantly synchronize with backend analytics."),
        ("What is a DIGIPIN address?", "DIGIPIN is India's National Digital Address system. DIGIPAY translates GPS coordinates into an alphanumeric grid reference that provides highly accurate locations without revealing exact street details."),
        ("Why does DIGIPAY need motion/speed analytics?", "Speed analytics help detect if you are in transit (driving or walking) to better optimize proximity merchant scans and prevent erroneous/accidental background transaction matching."),
        ("Does the app store my UPI PIN?", "No. DIGIPAY handles payment initialization using standard UPI deep-links which redirect securely to your chosen banking app. DIGIPAY never receives or stores your private UPI PIN.")
    ]

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: "Help & Support")
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Frequently Asked Questions")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primaryText)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<faqs.count, id: \.self) { index in
                                faqCell(index: index, question: faqs[index].0, answer: faqs[index].1)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func faqCell(index: Int, question: String, answer: String) -> some View {
        let isExpanded = expandedFaq == index
        
        return VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring()) {
                    expandedFaq = isExpanded ? nil : index
                }
            } label: {
                HStack {
                    Text(question)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(answer)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .lineSpacing(4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - CONTACT US

struct ContactUsView: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: "Contact Us")
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Support Channels")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Support Email: support@digipay.in", systemImage: "envelope.fill")
                                Label("Customer Helpline: +1 (800) 555-DPAY", systemImage: "phone.fill")
                                Label("HQ: Gachibowli, Hyderabad, TS, India", systemImage: "building.2.fill")
                                Label("Support Hours: 24/7 Live Assistance", systemImage: "clock.fill")
                            }
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                            
                            Divider()
                                .background(AppColors.borderColor)
                            
                            Text("Get in Touch")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subject")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primaryText)
                                
                                TextField("e.g. Transaction Issue", text: $subject)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.borderColor, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primaryText)
                                
                                TextEditor(text: $message)
                                    .frame(minHeight: 150)
                                    .padding(8)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.borderColor, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Button(action: submitMessage) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Submit Support Request")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.4) : AppColors.primaryBlue)
                            .cornerRadius(18)
                        }
                        .disabled(subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Request Submitted", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you! Our support team has received your request and will follow up within 24 hours.")
        }
    }
    
    private func submitMessage() {
        isSubmitting = true
        // Mock API Call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
        }
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - GENERIC INFORMATION (TERMS / PRIVACY / ABOUT)

struct GenericInfoView: View {
    let title: String
    let contentText: String
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: title)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(title)
                            .font(.title.bold())
                            .foregroundColor(AppColors.primaryText)
                        
                        Divider()
                            .background(AppColors.borderColor)
                        
                        Text(contentText)
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .lineSpacing(8)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - SYSTEM DIAGNOSTICS

struct SystemDiagnosticsView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var dynamicBiometricStatus = "Checking..."
    @State private var dynamicNotificationStatus = "Checking..."
    @State private var apiReachability = "Checking..."
    
    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                customNavBar(title: "System Diagnostics")
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header info
                        VStack(alignment: .leading, spacing: 6) {
                            Text("System Overview")
                                .font(.title2.bold())
                                .foregroundColor(AppColors.primaryText)
                            Text("Live connectivity parameters and hardware authorization indicators.")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.horizontal)
                        
                        // Device parameters
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Application Info")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                diagnosticRow(label: "App Version", value: "1.2.0 (Build 42)")
                                diagnosticRow(label: "Deployment Environment", value: "Production Railway")
                                diagnosticRow(label: "API Base URL", value: "https://web-production-86613.up.railway.app")
                                diagnosticRow(label: "Active Session Owner", value: session.fullName.isEmpty ? "Complete Profile" : session.fullName)
                                diagnosticRow(label: "Registered Role", value: session.role.rawValue.capitalized)
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(18)
                            .padding(.horizontal)
                        }
                        
                        // Hardware parameters
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Hardware & Permissions")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                diagnosticRow(label: "Biometrics Hardware", value: dynamicBiometricStatus)
                                diagnosticRow(label: "Push Notifications State", value: dynamicNotificationStatus)
                                diagnosticRow(label: "API Connection Status", value: apiReachability)
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(18)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkBiometricSupport()
            checkNotificationStatus()
            testApiReachability()
        }
    }
    
    private func diagnosticRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(AppColors.secondaryText)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(AppColors.cardBackground)
    }
    
    private func checkBiometricSupport() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                dynamicBiometricStatus = "Face ID Supported & Configured"
            case .touchID:
                dynamicBiometricStatus = "Touch ID Supported & Configured"
            case .opticID:
                dynamicBiometricStatus = "Optic ID Supported & Configured"
            case .none:
                dynamicBiometricStatus = "No Hardware Biometrics Available"
            @unknown default:
                dynamicBiometricStatus = "Biometrics Available"
            }
        } else {
            dynamicBiometricStatus = "Unsupported / Disabled"
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    dynamicNotificationStatus = "Authorized"
                case .denied:
                    dynamicNotificationStatus = "Denied"
                case .notDetermined:
                    dynamicNotificationStatus = "Not Determined (Unrequested)"
                default:
                    dynamicNotificationStatus = "Inactive"
                }
            }
        }
    }
    
    private func testApiReachability() {
        guard let url = URL(string: "https://web-production-86613.up.railway.app/") else {
            apiReachability = "Invalid Endpoint"
            return
        }
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    apiReachability = "Connected (HTTP 200 OK)"
                } else {
                    apiReachability = "Offline / Connection Error"
                }
            }
        }.resume()
    }
    
    private func customNavBar(title: String) -> some View {
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
            Text(title)
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
}

// MARK: - SHARED COMPONENTS

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body.bold())
                .foregroundColor(AppColors.primaryBlue)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(AppColors.primaryBlue)
        }
        .padding()
        .background(AppColors.cardBackground)
    }
}
