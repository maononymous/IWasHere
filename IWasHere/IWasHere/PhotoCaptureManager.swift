//
//  PhotoCaptureManager.swift
//  IWasHere
//
//  Created by Abdullah Omer Mohammed on 5/4/25.
//


import UIKit
import AVFoundation
import Photos

class PhotoCaptureManager: NSObject, AVCapturePhotoCaptureDelegate {
    static let shared = PhotoCaptureManager()

    private var photoOutput = AVCapturePhotoOutput()
    private var session: AVCaptureSession?
    private var currentOverlayName: String?

    func attach(to session: AVCaptureSession) {
        self.session = session
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }

    func capturePhoto(with overlayName: String, completion: @escaping (UIImage?) -> Void) {
        guard let session = session else {
            completion(nil)
            return
        }
        self.currentOverlayName = overlayName
        self.captureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private var captureCompletion: ((UIImage?) -> Void)?


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let cameraImage = UIImage(data: data),
              let overlayName = currentOverlayName,
              let overlayImage = UIImage(named: overlayName)
        else { return }

        let size = cameraImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let finalImage = renderer.image { ctx in
            cameraImage.draw(in: CGRect(origin: .zero, size: size))
            overlayImage.draw(in: CGRect(origin: .zero, size: size))
        }

        self.captureCompletion?(finalImage)
        self.captureCompletion = nil
        print("✅ Photo with overlay saved!")
    }
}
