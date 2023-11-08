//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State var cameraManager = CameraViewModel()

    var body: some View {
        VStack {
            ZStack {
                if let livePreview = cameraManager.livePreview {
                    Image(uiImage: livePreview)
                        .resizable()
                        .scaledToFit()
                }
                
                Button("Capture") {
                    cameraManager.capturePhoto()
                }
            }
            if let output = cameraManager.finalPhoto {
                Image(uiImage: output)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.endSession()
        }
    }
}

@Observable
final class CameraViewModel: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    var finalPhoto: UIImage?
    var livePreview: UIImage?

    func startSession() {
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(cameraInput) {
                    captureSession.addInput(cameraInput)
                }
                
                photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
                
                Task { captureSession.startRunning() }
                
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                captureSession.addOutput(videoOutput)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func endSession() {
        captureSession.stopRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .quality
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                DispatchQueue.main.async {
                    self.livePreview = UIImage(cgImage: cgImage)
                }
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            finalPhoto = UIImage(data: imageData)
        }
    }
}
