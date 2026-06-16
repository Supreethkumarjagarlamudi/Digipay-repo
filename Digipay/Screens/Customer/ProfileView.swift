import SwiftUI

struct ProfileView: View {

    @AppStorage("isLoggedIn")
    private var isLoggedIn = false

    @AppStorage("fullName")
    private var fullName = ""

    @AppStorage("userRole")
    private var role = "customer"

    @EnvironmentObject
    private var session: SessionManager

    @State private var showLogoutAlert = false

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

                        supportSection

                        appInfoSection

                        logoutButton
                    }
                    .padding()
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .alert(
                "Logout",
                isPresented: $showLogoutAlert
            ) {

                Button(
                    "Cancel",
                    role: .cancel
                ) {}

                Button(
                    "Logout",
                    role: .destructive
                ) {

                    logout()
                }

            } message: {

                Text(
                    "Are you sure you want to logout?"
                )
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

                    Image(
                        systemName:
                        "person.fill"
                    )
                    .font(
                        .system(size: 48)
                    )
                    .foregroundColor(.white)
                }

            VStack(
                spacing: 6
            ) {

                Text(
                    fullName.isEmpty
                    ? "DIGIPAY User"
                    : fullName
                )
                .font(
                    .title2.bold()
                )

                Text(
                    role.capitalized
                )
                .font(.subheadline)

                .foregroundColor(
                    AppColors.secondaryText
                )
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
        .padding(.top, 12)
    }

    private func logout() {
        session.logout()
    }
}

// MARK: - HELPERS

extension ProfileView {

    private func sectionTitle(
        _ title: String
    ) -> some View {

        HStack {

            Text(title)
                .font(
                    .headline
                )

            Spacer()
        }
    }
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
