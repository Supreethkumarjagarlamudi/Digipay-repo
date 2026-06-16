import SwiftUI

// MARK: - PRIVACY & SECURITY

struct PrivacySecurityView: View {
    @State private var biometricLogin = true
    @State private var locationServices = true
    @State private var endToEndEncryption = true
    
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
                                ToggleRow(icon: "faceid", title: "Biometric Login (Face ID)", isEnabled: $biometricLogin)
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
        .padding()
        .background(AppColors.primaryBackground)
    }
}

// MARK: - NOTIFICATIONS

struct NotificationsSubView: View {
    @State private var pushNotifications = true
    @State private var transactionAlerts = true
    @State private var smsAlerts = false
    @State private var promoAlerts = false
    
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
        .padding()
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
        ("I'm experiencing payment failures. What do I do?", "Please ensure your location services are enabled. If a transaction fails to complete, check your network connection and verify with your bank app if your UPI ID is active.")
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
        .padding()
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
        .padding()
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
        .padding()
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
