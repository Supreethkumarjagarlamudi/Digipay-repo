import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var session: SessionManager
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    
    @State private var isFetching = false
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                customNavBar
                
                if isFetching {
                    Spacer()
                    ProgressView("Loading profile...")
                        .tint(AppColors.primaryBlue)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Icon
                            headerIcon
                            
                            // Form Inputs
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Full Name")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    TextField("Enter your name", text: $fullName)
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(16)
                                        .foregroundColor(AppColors.primaryText)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(AppColors.borderColor, lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email Address")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    TextField("example@gmail.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(16)
                                        .foregroundColor(AppColors.primaryText)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(AppColors.borderColor, lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Feedback Messages
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(AppColors.errorRed)
                                    .padding(.horizontal, 24)
                            }
                            
                            if !successMessage.isEmpty {
                                Text(successMessage)
                                    .font(.caption)
                                    .foregroundColor(AppColors.successGreen)
                                    .padding(.horizontal, 24)
                            }
                            
                            // Save Button
                            Button(action: saveProfile) {
                                HStack {
                                    if isSaving {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Save Changes")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.4) : AppColors.primaryBlue)
                                .cornerRadius(18)
                            }
                            .disabled(fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            
                            Spacer()
                        }
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: loadProfile)
    }
}

// MARK: - COMPONENTS

extension EditProfileView {
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
            
            Text("Edit Profile")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            // Spacer to balance the back button
            Text("Back")
                .fontWeight(.semibold)
                .hidden()
        }
        .padding()
        .background(AppColors.primaryBackground)
    }
    
    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 45))
                .foregroundColor(.white)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - LOGIC

extension EditProfileView {
    private func loadProfile() {
        fullName = session.fullName
        isFetching = true
        errorMessage = ""
        
        Task {
            do {
                let user = try await UserService.shared.fetchProfile()
                fullName = user.full_name ?? session.fullName
                email = user.email ?? ""
            } catch {
                errorMessage = "Could not sync latest profile: " + error.localizedDescription
            }
            isFetching = false
        }
    }
    
    private func saveProfile() {
        isSaving = true
        errorMessage = ""
        successMessage = ""
        
        Task {
            do {
                try await UserService.shared.updateProfile(
                    fullName: fullName,
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : email,
                    role: session.role.rawValue
                )
                
                // Update local session manager
                session.fullName = fullName
                UserDefaults.standard.set(fullName, forKey: "fullName")
                
                successMessage = "Profile updated successfully!"
                
                // Automatically dismiss after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}
