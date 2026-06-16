import Foundation

enum Endpoints {

    static let sendOTP =
    "\(AppConfig.baseURL)/auth/send-otp"

    static let verifyOTP =
    "\(AppConfig.baseURL)/auth/verify-otp"

    static let userProfile =
    "\(AppConfig.baseURL)/user/me"
    
    static let updateProfile =
    "\(AppConfig.baseURL)/user/update-profile"
    
    static let registerMerchant =
    "\(AppConfig.baseURL)/merchant/register"
    static let recommendations =
    "\(AppConfig.baseURL)/merchant/recommendations"
    
    static let merchantDashboard =
    "\(AppConfig.baseURL)/merchant/dashboard"
    
    static let createTransaction =
    "\(AppConfig.baseURL)/wallet/transactions"
    static let fetchTransactions =
    "\(AppConfig.baseURL)/wallet/transactions"
    static let walletAnalytics =
    "\(AppConfig.baseURL)/wallet/analytics"
}
