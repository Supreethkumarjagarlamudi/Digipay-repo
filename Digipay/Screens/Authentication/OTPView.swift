import SwiftUI

struct OTPView: View {

    let phoneNumber: String
    let role: UserRole

    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject
    private var session: SessionManager

    @StateObject
    private var authVM = AuthViewModel()

    @State private var otpCode = ""

    @FocusState
    private var isFocused: Bool

    @State private var navigateToProfile = false
    @State private var navigateToMerchant = false
    @State private var showSuccess = false
    @State private var isVerifying = false

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {

                // MARK: Back

                HStack {

                    Button {

                        dismiss()

                    } label: {

                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(
                                AppColors.primaryText
                            )
                    }

                    Spacer()

                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)

                VStack(spacing: 10) {

                    Text("Verify OTP")

                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )

                    Text("Code sent to")

                        .foregroundColor(
                            AppColors.secondaryText
                        )

                    Text("+91 \(phoneNumber)")

                        .fontWeight(.bold)

                        .foregroundColor(
                            AppColors.primaryBlue
                        )

                }

                // MARK: OTP BOXES

                ZStack {

                    TextField("", text: $otpCode)

                        .keyboardType(.numberPad)

                        .textContentType(.oneTimeCode)

                        .focused($isFocused)

                        .opacity(0.01)

                    HStack(spacing: 12) {

                        ForEach(0..<6, id: \.self) { index in

                            OTPDigitBox(

                                digit: digit(at: index),

                                active:

                                otpCode.count == index ||

                                (

                                otpCode.count == 6 &&

                                index == 5

                                )

                            )

                        }

                    }

                }

                .contentShape(Rectangle())

                .onTapGesture {

                    isFocused = true

                }


                if !authVM.errorMessage.isEmpty {

                    HStack {

                        Image(systemName: "exclamationmark.circle.fill")

                        Text(authVM.errorMessage)

                    }

                    .foregroundColor(.red)

                    .padding()

                    .background(

                        Color.red.opacity(0.1)

                    )

                    .cornerRadius(16)

                    .padding(.horizontal)

                }

                Spacer()

                Text("OTP will auto verify")

                    .font(.caption)

                    .foregroundColor(
                        AppColors.secondaryText
                    )

                Spacer()

            }
            if isVerifying {

                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                VStack(
                    spacing: 18
                ) {

                    ProgressView()

                        .scaleEffect(1.5)

                        .tint(
                            AppColors.primaryBlue
                        )

                    Text("Verifying OTP")

                        .fontWeight(.semibold)

                }
                .padding(30)

                .background(

                    AppColors.cardBackground

                )

                .cornerRadius(24)

            }

        }

        .navigationBarBackButtonHidden(true)

        .onAppear {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                isFocused = true

            }

        }

        .onChange(of: otpCode) { _, value in

            if value.count > 6 {

                otpCode = String(value.prefix(6))

            }

            if otpCode.count == 6 {

                verifyOTP()

            }

        }

        .onChange(of: authVM.isAuthenticated) { _, value in

            guard value else {

                return

            }

            let profileCompleted = UserDefaults.standard.bool(
                forKey: "profileCompleted"
            )
            let fullName = UserDefaults.standard.string(forKey: "fullName") ?? ""

            if profileCompleted {
                session.login(
                    token: authVM.accessToken,
                    role: role.rawValue,
                    profileCompleted: true,
                    fullName: fullName
                )
            } else {
                // Keep tokens and role in session, but profileCompleted = false
                session.accessToken = authVM.accessToken
                session.role = role
                session.profileCompleted = false
                
                UserDefaults.standard.set(authVM.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(role.rawValue, forKey: "userRole")
                UserDefaults.standard.set(false, forKey: "profileCompleted")

                if role == .customer {
                    navigateToProfile = true
                } else {
                    navigateToMerchant = true
                }
            }

        }

        .navigationDestination(
            isPresented: $navigateToProfile
        ) {

            ProfileSetupView()

        }

        .navigationDestination(
            isPresented: $navigateToMerchant
        ) {

            MerchantBasicInfoView()

        }

    }

    func digit(at index: Int) -> String {

        guard index < otpCode.count else {

            return ""

        }

        let value = otpCode[
            otpCode.index(
                otpCode.startIndex,
                offsetBy: index
            )
        ]

        return String(value)

    }

    func verifyOTP() {

        guard !isVerifying else {

            return

        }

        withAnimation {

            showSuccess = true

        }

        isVerifying = true

        Task {

            await authVM.verifyOTP(

                phoneNumber: phoneNumber,

                otpCode: otpCode

            )

            isVerifying = false

        }

    }

}
