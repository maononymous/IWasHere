//
//  ContentView.swift
//  IWasHere
//
//  Created by Abdullah Omer Mohammed on 5/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFrame: String = "Frame_India"
    @State private var capturedImage: UIImage?
    @State private var showPreviewDialog = false
    @State private var showShareSheet = false



    let availableFrames = ["Frame_India", "Frame_Aidni"] // Add your own names

    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)

            Image(selectedFrame)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)

            VStack {
                Spacer()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(availableFrames, id: \.self) { frame in
                            Image(frame)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(frame == selectedFrame ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedFrame = frame
                                }
                        }
                    }
                    .padding(.horizontal)
                }
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
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 2)
                        )
                }.sheet(isPresented: $showShareSheet) {
                    if let image = capturedImage {
                        ShareSheet(activityItems: [image])
                    }
                }
                .padding(.bottom, 30)
            }.overlay(
                Group {
                    if showPreviewDialog, let image = capturedImage {
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
                                    Button(action: {
                                        // Retake
                                        capturedImage = nil
                                        showPreviewDialog = false
                                    }) {
                                        Text("Snap Again")
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(Color.red.opacity(0.8))
                                            .cornerRadius(10)
                                    }

                                    Button(action: {
                                        // Share
                                        showShareSheet = true
                                        showPreviewDialog = false
                                    }) {
                                        Text("Use This")
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(Color.green.opacity(0.8))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            )
        }
    }
}
