import UIKit
import AVFoundation

final class ScannerViewController:
UIViewController,
AVCaptureMetadataOutputObjectsDelegate {

    var onCodeScanned:
    ((String) -> Void)?

    private let captureSession =
    AVCaptureSession()

    override func viewDidLoad() {

        super.viewDidLoad()

        guard let videoCaptureDevice =
        AVCaptureDevice.default(
            for: .video
        ) else {

            return
        }

        guard let videoInput =
        try? AVCaptureDeviceInput(
            device: videoCaptureDevice
        ) else {

            return
        }

        captureSession.addInput(
            videoInput
        )

        let metadataOutput =
        AVCaptureMetadataOutput()

        captureSession.addOutput(
            metadataOutput
        )

        metadataOutput.setMetadataObjectsDelegate(
            self,
            queue: .main
        )

        metadataOutput.metadataObjectTypes =
        [.qr]

        let previewLayer =
        AVCaptureVideoPreviewLayer(
            session: captureSession
        )

        previewLayer.frame =
        view.layer.bounds

        previewLayer.videoGravity =
        .resizeAspectFill

        view.layer.addSublayer(
            previewLayer
        )

        captureSession.startRunning()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard
            let metadataObject =
            metadataObjects.first as?
            AVMetadataMachineReadableCodeObject,

            let code =
            metadataObject.stringValue
        else {

            return
        }

        captureSession.stopRunning()

        onCodeScanned?(code)
    }
}
