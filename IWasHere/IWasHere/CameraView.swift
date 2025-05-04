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
                self.previewLayer.frame = self.view.bounds
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
        previewLayer.frame = view.bounds
    }
}
