//
//  CameraVM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import SwiftUI

/// Camera preview view mdeol to handle image processing.
final class CameraPreviewVM {
    /// Current camera session.
    private var session: AVCaptureSession?
    /// Interface for AVFoundation
    private var delegate: AVCapturePhotoCaptureDelegate?
    /// Output photo from camera.
    private let output: AVCapturePhotoOutput
    /// Preview of the camera.
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    init() {
        output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .quality
    }
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> Void) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                Task { await self.setupCamera(completion: completion) }
            }
        case .authorized:
            Task { await setupCamera(completion: completion) }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping (Error?) -> Void) async {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                session.sessionPreset = .photo
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                previewLayer.session = session
                previewLayer.videoGravity = .resizeAspect
                session.startRunning()
                self.session = session
            } catch {
                completion(error)
            }
        }
    }
    
    func capturePhoto() {
        checkPermissions { if $0 == nil { return } }
        guard let delegate = delegate else { return }
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .quality
        output.capturePhoto(with: settings, delegate: delegate)
    }
}
