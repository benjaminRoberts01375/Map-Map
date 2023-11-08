//
//  CameraVM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import SwiftUI

@Observable
final class CameraVM: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
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

