import SwiftUI

struct MerchantUPIScanView: View {

    let merchantData:
    MerchantRegistrationData

    @EnvironmentObject
    private var session: SessionManager

    @StateObject
    private var merchantVM =
    MerchantViewModel()
    @State private var scannedCode = ""

    @State private var showScanner = false

    @State private var navigateToMerchantHome = false

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack(
                spacing: 24
            ) {

                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)

                    RegistrationProgressView(
                        currentStep: 3,
                        totalSteps: 3
                    )
                    .padding(.horizontal)

                    Text("Scan UPI QR")
                        .font(
                            .system(
                                size: 30,
                                weight: .bold
                            )
                        )

                    Text(
                        "Scan your existing UPI QR code."
                    )
                    .foregroundColor(
                        AppColors.secondaryText
                    )

                    if scannedCode.isEmpty {

                        Image(
                            systemName:
                            "qrcode.viewfinder"
                        )
                        .font(.system(size: 90))
                        .foregroundColor(
                            AppColors.primaryBlue
                        )

                    } else {

                        VStack(
                            spacing: 12
                        ) {

                            Image(
                                systemName:
                                "checkmark.circle.fill"
                            )
                            .font(.system(size: 60))
                            .foregroundColor(
                                .green
                            )

                            Text(
                                "QR Successfully Scanned"
                            )
                            .fontWeight(.bold)
                        }
                    }

                    Button {

                        showScanner = true

                    } label: {

                        Text("Open Scanner")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                AppColors.primaryBlue
                            )
                            .cornerRadius(18)
                    }
                    .padding(.horizontal)

                    #if targetEnvironment(simulator)
                    Button {
                        scannedCode = "upi://pay?pa=merchant@upi&pn=SupreethStore&am=0.00"
                    } label: {
                        Text("Mock Scan QR (Simulator)")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.orange)
                            .cornerRadius(18)
                    }
                    .accessibilityIdentifier("mockScanQrButton")
                    .padding(.horizontal)
                    #endif

                    if !scannedCode.isEmpty {

                        Text(
                            scannedCode
                        )
                        .font(.caption)
                        .padding()
                        .background(
                            AppColors.cardBackground
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)

                        Button {

                            Task {
                                let request =
                                MerchantRegisterRequest(
                                    business_name:
                                        merchantData.businessName,
                                    owner_name:
                                        merchantData.ownerName,
                                    category:
                                        merchantData.category,
                                    gst_number:
                                        merchantData.gstNumber,
                                    description:
                                        merchantData.description,
                                    latitude:
                                        merchantData.latitude,
                                    longitude:
                                        merchantData.longitude,
                                    altitude:
                                        merchantData.altitude,
                                    accuracy:
                                        merchantData.accuracy,
                                    heading:
                                        merchantData.heading,
                                    speed:
                                        merchantData.speed,
                                    
                                    upi_deep_link:
                                        
                                        scannedCode
                                    
                                )
                                
                                await merchantVM
                                
                                    .registerMerchant(
                                        
                                        request: request
                                        
                                    )
                            }
                        } label: {

                            if merchantVM.isLoading {

                                ProgressView()
                                    .tint(.white)

                            } else {
                                
                                Text(
                                    "Complete Registration"
                                )
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(.green)
                                .cornerRadius(18)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(
                isPresented: $showScanner
            ) {

                QRScannerView(
                    scannedCode: $scannedCode
                )
            }
            .navigationBarBackButtonHidden(true)
            .onChange(

                of: merchantVM.registrationSuccess

            ) { _, value in

                if value {

                    session.completeRegistration(
                        fullName: merchantData.ownerName,
                        role: .merchant
                    )

                }

            }
            .navigationDestination(
                isPresented: $navigateToMerchantHome
            ) {

                MerchantHomeView()
            }
    }
}
