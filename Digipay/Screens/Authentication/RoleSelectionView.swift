import SwiftUI

struct RoleSelectionView: View {

    @State private var selectedRole: UserRole?

    @State private var navigate = false

    var body: some View {

        NavigationStack {

            ZStack {

                AppColors.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 32) {

                    Spacer()

                    // MARK: LOGO

                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)

                    // MARK: TITLE

                    VStack(spacing: 10) {

                        Text("Welcome to")

                            .font(.title3)

                            .foregroundColor(
                                AppColors.secondaryText
                            )

                        Text("DIGIPAY")

                            .font(
                                .system(
                                    size: 40,
                                    weight: .bold
                                )
                            )

                        Text(
                            "Context-Aware Digital Payments"
                        )
                        .font(.subheadline)

                        .foregroundColor(
                            AppColors.secondaryText
                        )
                    }

                    // MARK: ROLE CARDS

                    VStack(spacing: 18) {

                        roleCard(

                            role: .customer,

                            title: "Customer",

                            subtitle: "Discover nearby merchants and pay instantly.",

                            icon: "person.fill"

                        )

                        roleCard(

                            role: .merchant,

                            title: "Merchant",

                            subtitle: "Register your business and receive seamless payments.",

                            icon: "building.2.fill"

                        )

                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // MARK: CONTINUE BUTTON

                    Button {

                        guard selectedRole != nil else {

                            return
                        }

                        navigate = true

                    } label: {

                        HStack {

                            Text("Continue")
                                .fontWeight(.bold)

                            Image(
                                systemName:
                                    "arrow.right"
                            )
                        }
                        .foregroundColor(.white)

                        .frame(maxWidth: .infinity)

                        .frame(height: 58)

                        .background(

                            selectedRole == nil

                            ? Color.gray.opacity(0.4)

                            : AppColors.primaryBlue

                        )

                        .cornerRadius(18)
                    }
                    .disabled(selectedRole == nil)
                    .accessibilityIdentifier("loginSubmitButton")
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 20)
                }
            }
            .navigationDestination(
                isPresented: $navigate
            ) {

                if let role = selectedRole {

                    LoginView(
                        role: role
                    )
                }
            }
        }
    }

    // MARK: ROLE CARD

    @ViewBuilder

    private func roleCard(

        role: UserRole,

        title: String,

        subtitle: String,

        icon: String

    ) -> some View {

        Button {

            withAnimation(.spring()) {

                selectedRole = role
            }

        } label: {

            HStack(spacing: 18) {

                ZStack {

                    Circle()

                        .fill(

                            AppColors.primaryBlue.opacity(0.12)

                        )

                        .frame(
                            width: 64,
                            height: 64
                        )

                    Image(systemName: icon)

                        .font(.title2)

                        .foregroundColor(
                            AppColors.primaryBlue
                        )
                }

                VStack(

                    alignment: .leading,

                    spacing: 6

                ) {

                    Text(title)

                        .font(.title3.bold())

                    Text(subtitle)

                        .font(.caption)

                        .foregroundColor(
                            AppColors.secondaryText
                        )
                }

                Spacer()

                Image(

                    systemName:

                        selectedRole == role

                    ? "checkmark.circle.fill"

                    : "circle"

                )

                .font(.title2)

                .foregroundColor(

                    selectedRole == role

                    ? AppColors.primaryBlue

                    : AppColors.tertiaryText
                )
            }
            .padding(20)

            .background(

                AppColors.cardBackground

            )

            .overlay(

                RoundedRectangle(

                    cornerRadius: 24

                )

                .stroke(

                    selectedRole == role

                    ? AppColors.primaryBlue

                    : Color.clear,

                    lineWidth: 2
                )
            )

            .cornerRadius(24)

            .shadow(

                color:

                    selectedRole == role

                ? AppColors.primaryBlue.opacity(0.15)

                : .clear,

                radius: 12
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(role == .customer ? "roleCustomerButton" : "roleMerchantButton")
    }
}

#Preview {

    RoleSelectionView()
}
