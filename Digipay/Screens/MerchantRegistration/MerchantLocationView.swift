import SwiftUI

struct MerchantLocationView: View {

    @StateObject
    private var locationManager =
    MerchantLocationManager()

    let merchantData:
    MerchantRegistrationData

    @State private var navigateNext = false

    var body: some View {

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
                            .frame(width: 80)

                        // MARK: PROGRESS

                        RegistrationProgressView(
                            currentStep: 2,
                            totalSteps: 3
                        )
                        .padding(.horizontal, 24)

                        // MARK: ILLUSTRATION

                        ZStack {

                            Circle()
                                .fill(
                                    AppColors.primaryBlue
                                        .opacity(0.12)
                                )
                                .frame(
                                    width: 180,
                                    height: 180
                                )

                            Image(
                                systemName:
                                "location.circle.fill"
                            )
                            .font(
                                .system(size: 90)
                            )
                            .foregroundColor(
                                AppColors.primaryBlue
                            )
                        }

                        // MARK: TITLE

                        VStack(
                            spacing: 8
                        ) {

                            Text(
                                "Business Location"
                            )
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
                                "We are securely capturing your business location and contextual information."
                            )
                            .multilineTextAlignment(
                                .center
                            )
                            .foregroundColor(
                                AppColors.secondaryText
                            )
                            .padding(.horizontal)
                        }

                        // MARK: LOADING STATE

                        if !locationManager
                            .locationCaptured {

                            VStack(
                                spacing: 18
                            ) {

                                ProgressView()
                                    .scaleEffect(1.4)

                                Text(
                                    "Detecting Location..."
                                )
                                .font(
                                    .headline
                                )

                                Text(
                                    "Please keep the app open while we collect accurate location data."
                                )
                                .font(
                                    .subheadline
                                )
                                .multilineTextAlignment(
                                    .center
                                )
                                .foregroundColor(
                                    AppColors.secondaryText
                                )
                            }
                            .padding(28)
                            .frame(
                                maxWidth: .infinity
                            )
                            .background(
                                AppColors.cardBackground
                            )
                            .cornerRadius(28)
                            .padding(.horizontal)

                        } else {

                            // MARK: SUCCESS CARD

                            VStack(
                                spacing: 16
                            ) {

                                Image(
                                    systemName:
                                    "checkmark.circle.fill"
                                )
                                .font(
                                    .system(size: 60)
                                )
                                .foregroundColor(
                                    .green
                                )

                                Text(
                                    "Location Captured"
                                )
                                .font(
                                    .title2
                                )
                                .fontWeight(
                                    .bold
                                )

                                Text(
                                    "Your business location and contextual information have been captured successfully."
                                )
                                .multilineTextAlignment(
                                    .center
                                )
                                .foregroundColor(
                                    AppColors.secondaryText
                                )
                            }
                            .padding(28)
                            .frame(
                                maxWidth: .infinity
                            )
                            .background(
                                AppColors.cardBackground
                            )
                            .cornerRadius(28)
                            .padding(.horizontal)

                            // MARK: CONTEXT DATA

                            LazyVGrid(
                                columns: [

                                    GridItem(
                                        .flexible()
                                    ),

                                    GridItem(
                                        .flexible()
                                    )
                                ],
                                spacing: 14
                            ) {

                                ContextChip(
                                    title:
                                        "Altitude",
                                    value:
                                        "\(Int(locationManager.altitude)) m"
                                )

                                ContextChip(
                                    title:
                                        "Accuracy",
                                    value:
                                        "\(Int(locationManager.accuracy)) m"
                                )

                                ContextChip(
                                    title:
                                        "Heading",
                                    value:
                                        "\(Int(locationManager.heading))°"
                                )

                                ContextChip(
                                    title:
                                        "Speed",
                                    value:
                                        "\(Int(locationManager.speed)) m/s"
                                )
                            }
                            .padding(.horizontal)
                        }

                        // MARK: CONTINUE BUTTON

                        Button {

                            navigateNext = true

                        } label: {

                            Text("Continue")
                                .fontWeight(
                                    .semibold
                                )
                                .foregroundColor(
                                    .white
                                )
                                .frame(
                                    maxWidth: .infinity
                                )
                                .frame(
                                    height: 58
                                )
                                .background(

                                    locationManager
                                        .locationCaptured

                                    ? AppColors
                                        .primaryBlue

                                    : Color.gray
                                        .opacity(0.3)
                                )
                                .cornerRadius(18)
                                .shadow(
                                    color:
                                        AppColors
                                        .primaryBlue
                                        .opacity(0.25),
                                    radius: 12,
                                    y: 6
                                )
                        }
                        .padding(.horizontal)
                        .disabled(
                            !locationManager
                                .locationCaptured
                        )

                        Spacer()
                            .frame(height: 30)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(
                isPresented:
                    $navigateNext
            ) {

                MerchantUPIScanView(
                    merchantData:
                        MerchantRegistrationData(

                            businessName:
                                merchantData.businessName,

                            ownerName:
                                merchantData.ownerName,

                            category:
                                merchantData.category,

                            gstNumber:
                                merchantData.gstNumber,

                            description:
                                merchantData.description,

                            latitude:
                                locationManager.latitude,

                            longitude:
                                locationManager.longitude,

                            altitude:
                                locationManager.altitude,

                            accuracy:
                                locationManager.accuracy,

                            heading:
                                locationManager.heading,

                            speed:
                                locationManager.speed
                        )
                )
            }
            .onAppear {

                locationManager
                    .requestLocation()
            }
    }
}

