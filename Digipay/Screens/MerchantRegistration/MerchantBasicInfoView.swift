import SwiftUI

struct MerchantBasicInfoView: View {

    @State private var businessName = ""
    @State private var ownerName = ""
    @State private var category = ""

    @State private var gstNumber = ""
    @State private var businessDescription = ""

    @State private var navigateNext = false
    @State private var showValidationError = false

    let categories = [
        "Restaurant",
        "Cafe",
        "Medical",
        "Grocery",
        "Electronics",
        "Clothing",
        "Salon",
        "Stationery",
        "Other"
    ]

    private var isFormValid: Bool {

        !businessName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        &&
        !ownerName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        &&
        !category.isEmpty
    }

    var body: some View {

        NavigationStack {

            ZStack {

                AppColors.primaryBackground
                    .ignoresSafeArea()

                ScrollView(
                    showsIndicators: false
                ) {

                    VStack(
                        spacing: 28
                    ) {

                        Spacer()
                            .frame(height: 12)

                        // MARK: LOGO

                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 82)

                        // MARK: PROGRESS

                        RegistrationProgressView(
                            currentStep: 1,
                            totalSteps: 3
                        )
                        .padding(.horizontal, 24)

                        // MARK: HEADER

                        VStack(
                            spacing: 8
                        ) {

                            Text("Business Details")
                                .font(
                                    .system(
                                        size: 30,
                                        weight: .bold
                                    )
                                )
                                .foregroundColor(
                                    AppColors.primaryText
                                )

                            Text(
                                "Let's setup your merchant profile before we continue."
                            )
                            .font(.system(size: 15))
                            .foregroundColor(
                                AppColors.secondaryText
                            )
                            .multilineTextAlignment(.center)
                            .padding(
                                .horizontal,
                                24
                            )
                        }

                        // MARK: FORM

                        VStack(
                            spacing: 18
                        ) {

                            MerchantTextField(
                                title: "Business Name *",
                                placeholder: "Supreeth Grocery Store",
                                text: $businessName,
                                accessibilityId: "merchantNameInput"
                            )

                            MerchantTextField(
                                title: "Owner Name *",
                                placeholder: "Supreeth Kumar",
                                text: $ownerName,
                                accessibilityId: "merchantOwnerNameInput"
                            )

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                Text("Category *")
                                    .fontWeight(.semibold)
                                    .foregroundColor(
                                        AppColors.primaryText
                                    )

                                Picker(
                                    "Select Category",
                                    selection: $category
                                ) {

                                    Text(
                                        "Select Category"
                                    )
                                    .tag("")

                                    ForEach(
                                        categories,
                                        id: \.self
                                    ) { category in

                                        Text(category)
                                            .tag(category)
                                            .accessibilityIdentifier("categoryOption_\(category)")
                                    }
                                }
                                .pickerStyle(.menu)
                                .accessibilityIdentifier("merchantCategoryPicker")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    AppColors.cardBackground
                                )
                                .cornerRadius(18)
                            }

                            MerchantTextField(
                                title: "GST Number (Optional)",
                                placeholder: "29ABCDE1234F1Z5",
                                text: $gstNumber,
                                accessibilityId: "merchantGstInput"
                            )

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                HStack {

                                    Text(
                                        "Business Description"
                                    )
                                    .fontWeight(.semibold)

                                    Spacer()

                                    Text(
                                        "\(businessDescription.count)/200"
                                    )
                                    .font(.caption)
                                    .foregroundColor(
                                        AppColors.secondaryText
                                    )
                                }

                                TextEditor(
                                    text: $businessDescription
                                )
                                .accessibilityIdentifier("merchantDescriptionInput")
                                .frame(
                                    minHeight: 120,
                                    maxHeight: 120
                                )
                                .padding(8)
                                .background(
                                    AppColors.cardBackground
                                )
                                .cornerRadius(18)
                            }
                        }
                        .padding(.horizontal, 24)

                        // MARK: ERROR

                        if showValidationError {

                            Text(
                                "Please complete all required fields."
                            )
                            .font(.caption)
                            .foregroundColor(.red)
                        }

                        // MARK: CONTINUE

                        Button {

                            guard isFormValid else {

                                showValidationError = true
                                return
                            }

                            showValidationError = false
                            navigateNext = true

                        } label: {

                            Text("Continue")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    AppColors.primaryBlue
                                )
                                .cornerRadius(18)
                                .shadow(
                                    color: AppColors.primaryBlue.opacity(0.25),
                                    radius: 10,
                                    y: 6
                                )
                        }
                        .accessibilityIdentifier("merchantRegisterSubmit")
                        .padding(.horizontal, 24)
                        .opacity(
                            isFormValid ? 1 : 0.85
                        )

                        Spacer()
                            .frame(height: 24)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(
                isPresented: $navigateNext
            ) {

                MerchantLocationView(

                    merchantData:
                        MerchantRegistrationData(
                            businessName: businessName,
                            ownerName: ownerName,
                            category: category,
                            gstNumber: gstNumber,
                            description: businessDescription
                        )
                )
            }
        }
    }
}

struct MerchantTextField: View {

    let title: String
    let placeholder: String

    @Binding var text: String
    var accessibilityId: String = ""

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(title)
                .fontWeight(.semibold)

            TextField(
                placeholder,
                text: $text
            )
            .accessibilityIdentifier(accessibilityId)
            .padding()
            .background(
                AppColors.cardBackground
            )
            .cornerRadius(18)
        }
    }
}

#Preview {

    MerchantBasicInfoView()
}
