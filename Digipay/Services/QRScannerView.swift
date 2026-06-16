import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {

    @Binding var scannedCode: String

    func makeUIViewController(
        context: Context
    ) -> ScannerViewController {

        let vc = ScannerViewController()

        vc.onCodeScanned = { code in

            scannedCode = code
        }

        return vc
    }

    func updateUIViewController(
        _ uiViewController: ScannerViewController,
        context: Context
    ) {}
}
