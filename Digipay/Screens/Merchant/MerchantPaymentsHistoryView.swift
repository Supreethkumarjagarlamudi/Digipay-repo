import SwiftUI

struct MerchantPaymentsHistoryView: View {
    @ObservedObject var dashboardVM: MerchantHomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header NavBar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                            Text("Dashboard")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppColors.primaryBlue)
                    }
                    Spacer()
                    Text("Payment Statement")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Text("Dashboard").hidden()
                }
                .padding()
                .background(AppColors.primaryBackground)
                
                // Summary Panel
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Settled Volume")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.secondaryText)
                            
                            let totalVolume = dashboardVM.allPayments.reduce(0.0) { $0 + $1.amount }
                            Text("₹\(totalVolume, specifier: "%.2f")")
                                .font(.title.bold())
                                .foregroundColor(AppColors.primaryText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Total Payments")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("\(dashboardVM.allPayments.count) Txns")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(22)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.secondaryText)
                    
                    TextField("Search customer phone or amount...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppColors.primaryText)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                if dashboardVM.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.primaryBlue)
                    Spacer()
                } else if dashboardVM.allPayments.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.secondaryText)
                        Text("No payment transactions recorded.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            let groups = groupedFilteredPayments
                            let sortedKeys = sortedGroupKeys
                            
                            if sortedKeys.isEmpty {
                                Text("No transactions match '\(searchText)'")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 40)
                            } else {
                                ForEach(sortedKeys, id: \.self) { dateLabel in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(dateLabel)
                                            .font(.subheadline.bold())
                                            .foregroundColor(AppColors.secondaryText)
                                            .padding(.horizontal, 4)
                                        
                                        if let payments = groups[dateLabel] {
                                            ForEach(payments) { payment in
                                                paymentRow(payment)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await dashboardVM.loadAllPayments()
            }
        }
    }
    
    private func paymentRow(_ payment: MerchantPayment) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("From: \(payment.customer_phone)")
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                HStack(spacing: 8) {
                    Text(formatTime(payment.timestamp))
                        .font(.caption2)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Txn: DP\(payment.id)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Spacer()
            
            Text("+₹\(payment.amount, specifier: "%.2f")")
                .font(.headline.bold())
                .foregroundColor(AppColors.successGreen)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: isoString)
        
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = fallback.date(from: isoString)
        }
        
        guard let validDate = date else { return "Recent" }
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: validDate)
    }
    
    private var groupedFilteredPayments: [String: [MerchantPayment]] {
        let filtered = dashboardVM.allPayments.filter { p in
            if searchText.isEmpty { return true }
            return p.customer_phone.localizedCaseInsensitiveContains(searchText) ||
                   String(format: "%.2f", p.amount).contains(searchText)
        }
        
        return Dictionary(grouping: filtered) { payment in
            formatDateLabel(payment.timestamp)
        }
    }
    
    private var sortedGroupKeys: [String] {
        groupedFilteredPayments.keys.sorted { d1, d2 in
            let date1 = dateFromLabel(d1)
            let date2 = dateFromLabel(d2)
            return date1 > date2
        }
    }
    
    private func formatDateLabel(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: isoString)
        
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = fallback.date(from: isoString)
        }
        
        guard let validDate = date else { return "Unknown Date" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(validDate) {
            return "Today"
        } else if calendar.isDateInYesterday(validDate) {
            return "Yesterday"
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: validDate)
        }
    }
    
    private func dateFromLabel(_ label: String) -> Date {
        if label == "Today" {
            return Date()
        } else if label == "Yesterday" {
            return Date().addingTimeInterval(-86400)
        } else {
            let parser = DateFormatter()
            parser.dateStyle = .medium
            parser.timeStyle = .none
            return parser.date(from: label) ?? Date.distantPast
        }
    }
}
