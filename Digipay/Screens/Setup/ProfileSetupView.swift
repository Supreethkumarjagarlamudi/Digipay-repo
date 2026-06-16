import SwiftUI

struct ProfileSetupView: View {

    @State private var fullName = ""
    @State private var email = ""

    @EnvironmentObject
    private var session: SessionManager

    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {

        NavigationStack {

            ZStack {

                AppColors.primaryBackground
                    .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 32) {

                        Spacer()
                            .frame(height: 40)

                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90)

                        VStack(spacing: 10) {

                            Text("Complete Your Profile")
                                .font(
                                    .system(
                                        size: 30,
                                        weight: .bold
                                    )
                                )

                            Text(
                                "Tell us a little about yourself before continuing."
                            )
                            .foregroundColor(
                                AppColors.secondaryText
                            )
                            .multilineTextAlignment(.center)
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                Text("Full Name *")
                                    .fontWeight(.semibold)

                                TextField(
                                    "Enter your name",
                                    text: $fullName
                                )
                                .padding()
                                .background(
                                    AppColors.cardBackground
                                )
                                .cornerRadius(16)
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                Text("Email (Optional)")
                                    .fontWeight(.semibold)

                                TextField(
                                    "example@gmail.com",
                                    text: $email
                                )
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(
                                    AppColors.cardBackground
                                )
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        Button {
                            guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                errorMessage = "Please enter your name"
                                return
                            }
                            isLoading = true
                            errorMessage = ""
                            Task {
                                do {
                                    try await UserService.shared.updateProfile(
                                        fullName: fullName,
                                        email: email.isEmpty ? nil : email,
                                        role: session.role.rawValue
                                    )
                                    session.completeRegistration(
                                        fullName: fullName,
                                        role: session.role
                                    )
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                                isLoading = false
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Complete Setup")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                fullName.isEmpty ? Color.gray.opacity(0.4) : AppColors.primaryBlue
                            )
                            .cornerRadius(18)
                        }
                        .disabled(fullName.isEmpty || isLoading)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {

    ProfileSetupView()
}
