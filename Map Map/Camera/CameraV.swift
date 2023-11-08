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
}

@Observable
final class CameraViewModel: NSObject, AVCapturePhotoCaptureDelegate {
    private var captureSession = AVCaptureSession()

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
    }
}
