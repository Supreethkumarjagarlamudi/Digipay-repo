import SwiftUI

struct LoginView: View {

    let role: UserRole

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var authVM = AuthViewModel()

    @State private var phoneNumber = ""

    @State private var navigateToOTP = false

    @State private var showOTPAlert = false

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {

                VStack( spacing: 28) {

                    // MARK: HEADER

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


                    // MARK: LOGO

                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 95)

                    VStack(spacing: 12) {

                        Text("Welcome Back 👋")

                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold
                                )
                            )

                        Text("Continue as")

                            .foregroundColor(
                                AppColors.secondaryText
                            )

                        HStack(spacing: 8) {

                            Image(

                                systemName:

                                role == .customer

                                ? "person.fill"

                                : "building.2.fill"

                            )

                            Text(

                                role == .customer

                                ? "Customer"

                                : "Merchant"

                            )

                            .fontWeight(.bold)

                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)

                        .background(

                            AppColors.primaryBlue.opacity(0.12)

                        )

                        .foregroundColor(
                            AppColors.primaryBlue
                        )

                        .cornerRadius(24)

                    }


                    // MARK: PHONE CARD


                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        Label(
                            "Mobile Number",
                            systemImage: "phone.fill"
                        )
                        .font(.headline)

                        HStack(
                            spacing: 16
                        ) {

                            Text("+91")
                                .font(.title3.bold())

                            Rectangle()

                                .fill(
                                    AppColors.borderColor.opacity(0.5)
                                )

                                .frame(
                                    width: 1,
                                    height: 28
                                )

                            TextField(
                                "9876543210",
                                text: $phoneNumber
                            )

                            .keyboardType(.numberPad)

                            .font(.title3)
                            .foregroundColor(
                                AppColors.primaryText
                            )

                            .tint(
                                AppColors.primaryBlue
                            )

                        }
                        .padding(.horizontal, 18)

                        .frame(height: 60)

                        .background(

                            RoundedRectangle(
                                cornerRadius: 18
                            )

                            .fill(
                                AppColors.primaryBackground
                            )
                        )

                    }
                    .padding(20)

                    .background(

                        RoundedRectangle(
                            cornerRadius: 24
                        )

                        .fill(
                            AppColors.cardBackground
                        )

                    )

                    .padding(.horizontal)

                    if !authVM.errorMessage.isEmpty {

                        Text(authVM.errorMessage)

                            .font(.caption)

                            .foregroundColor(.red)
                    }


                    // MARK: BUTTON

                    Button {

                        guard phoneNumber.count == 10 else {

                            authVM.errorMessage =
                            "Please enter a valid mobile number"

                            return
                        }

                        Task {

                            await authVM.sendOTP(
                                phoneNumber: phoneNumber
                            )
                        }

                    } label: {

                        HStack {

                            if authVM.isLoading {

                                ProgressView()
                                    .tint(.white)

                            } else {

                                Text("Continue")

                                Image(
                                    systemName:
                                    "arrow.right"
                                )
                            }
                        }

                        .fontWeight(.bold)

                        .foregroundColor(.white)

                        .frame(maxWidth: .infinity)

                        .frame(height: 58)

                        .background(

                            LinearGradient(

                                colors: [

                                    AppColors.primaryBlue,

                                    AppColors.secondaryCyan

                                ],

                                startPoint: .leading,

                                endPoint: .trailing

                            )

                        )

                        .cornerRadius(18)

                    }
                    .padding(.horizontal)


                    Text(

                        "Secure Context-Aware Payments"

                    )

                    .font(.caption)

                    .foregroundColor(
                        AppColors.secondaryText
                    )

                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

            }

            
        }
        .navigationBarBackButtonHidden(true)

        .onChange(
            of: authVM.otp
        ) { _, value in

            if !value.isEmpty {

                showOTPAlert = true
            }
        }

        .navigationDestination(
            isPresented: $navigateToOTP
        ) {

            OTPView(

                phoneNumber: phoneNumber,

                role: role

            )
        }

        .alert(

            "Development Build",

            isPresented: $showOTPAlert

        ) {

            Button("Continue") {

                navigateToOTP = true

            }

        } message: {

            Text(
                "Your OTP is\n\n\(authVM.otp)\n\nUse this code to continue."
            )

        }
    }
}

#Preview {

    NavigationStack {

        LoginView(
            role: .customer
        )

    }
}
