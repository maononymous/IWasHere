//
//  ContentView.swift
//  IWasHere
//
//  Created by Abdullah Omer Mohammed on 5/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFrame: String = "Test_Frame"
    @State private var capturedImage: UIImage?
    @State private var showPreviewDialog = false
    @State private var showShareSheet = false
    @State private var showFramePicker = false

    let availableFrames = ["Test_Frame", "Frame_India", "Frame_Aidni"]

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let targetHeight = screenWidth * (4.0 / 3.0)
            let verticalPadding = max((screenHeight - targetHeight) / 2, 0)

            ZStack {
                CameraView()
                    .edgesIgnoringSafeArea(.all)

                // Overlay filter image
                Image(selectedFrame)
                    .resizable()
                    .frame(width: screenWidth, height: targetHeight)
                    .position(x: screenWidth / 2, y: verticalPadding + targetHeight / 2)
                    .allowsHitTesting(false)

                // Black bars
                VStack(spacing: 0) {
                    Rectangle().fill(Color.black).frame(height: verticalPadding)
                    Spacer()
                    Rectangle().fill(Color.black).frame(height: verticalPadding)
                }
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    if showFramePicker {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(availableFrames, id: \.self) { frame in
                                    Image(frame)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(frame == selectedFrame ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            selectedFrame = frame
                                            showFramePicker = false
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    } else {
                        HStack {
                            // Filter thumbnail button
                            Button(action: {
                                showFramePicker = true
                            }) {
                                Image(selectedFrame)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }

                            Spacer()

                            // Capture button
                            Button(action: {
                                PhotoCaptureManager.shared.capturePhoto(with: selectedFrame) { image in
                                    self.capturedImage = image
                                    self.showPreviewDialog = true
                                }
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .shadow(radius: 5)
                                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 2))
                            }
                            .sheet(isPresented: $showShareSheet) {
                                if let image = capturedImage {
                                    ShareSheet(activityItems: [image])
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }

                // Overlay: Preview dialog
                if showPreviewDialog, let image = capturedImage {
                    PreviewOverlay(
                        image: image,
                        onSnapAgain: {
                            capturedImage = nil
                            showPreviewDialog = false
                        },
                        onUse: {
                            showShareSheet = true
                            showPreviewDialog = false
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Preview Overlay

struct PreviewOverlay: View {
    let image: UIImage
    var onSnapAgain: () -> Void
    var onUse: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 500)
                    .cornerRadius(12)
                    .shadow(radius: 10)

                HStack(spacing: 30) {
                    Button("Snap Again", action: onSnapAgain)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)

                    Button("Use This", action: onUse)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
