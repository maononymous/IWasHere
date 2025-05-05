//
//  CameraView.swift
//  IWasHere
//
//  Created by Abdullah Omer Mohammed on 5/4/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Nothing to update for now
    }
}

class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Run full setup on background thread to avoid UI blocking
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCamera()

            // Once setup is done, attach the preview layer on the main thread
            DispatchQueue.main.async {
                self.previewLayer.session = self.session
                self.previewLayer.videoGravity = .resizeAspectFill
                
                let viewWidth = self.view.bounds.width
                let targetHeight = viewWidth * (4.0 / 3.0)
                let yOffset = (self.view.bounds.height - targetHeight) / 2

                self.previewLayer.frame = CGRect(
                    x: 0,
                    y: yOffset,
                    width: viewWidth,
                    height: targetHeight
                )
                
                self.view.layer.addSublayer(self.previewLayer)
            }

            self.session.startRunning()
        }
    }


    private func setupCamera() {
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        PhotoCaptureManager.shared.attach(to: session)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewWidth = self.view.bounds.width
        let targetHeight = viewWidth * (4.0 / 3.0)
        let yOffset = (self.view.bounds.height - targetHeight) / 2

        self.previewLayer.frame = CGRect(
            x: 0,
            y: yOffset,
            width: viewWidth,
            height: targetHeight
        )
    }
}
