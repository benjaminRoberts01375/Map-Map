//
//  CameraVM.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import SwiftUI

/// Camera preview view mdeol to handle image processing.
@Observable
final class CameraPreviewVM {
    /// Current camera session.
    private var session: AVCaptureSession?
    /// Interface for AVFoundation
    private var delegate: AVCapturePhotoCaptureDelegate?
    /// Output photo from camera.
    private let output: AVCapturePhotoOutput
    /// Preview of the camera.
    let previewLayer = AVCaptureVideoPreviewLayer()
    /// Track current permission status of the camera
    var permissionsEnabled: Bool = true
    
    init() {
        output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .quality
    }
    
    /// Start up the camera
    /// - Parameters:
    ///   - delegate: Allow for callbacks from system.
    ///   - completion: What to do when a photo is successfully taken.
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> Void) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    /// Ensure the camera's permitted to take a photo.
    /// - Parameter completion: What to do when a photo is successfully taken.
    private func checkPermissions(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { allowedAccess in
                if allowedAccess {
                    Task { await self.setupCamera(completion: completion) }
                }
                DispatchQueue.main.async { self.permissionsEnabled = allowedAccess }
            }
        case .authorized:
            permissionsEnabled = true
            Task { await setupCamera(completion: completion) }
        case .denied, .restricted:
            permissionsEnabled = false
        @unknown default:
            permissionsEnabled = false
        }
    }
    
    /// Configure camera
    /// - Parameter completion: What to do when a photo is successfully taken.
    private func setupCamera(completion: @escaping (Error?) -> Void) async {
        if session != nil { return }
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
    
    /// Shuts down the camera
    public func tearDownCamera() { session?.stopRunning() }
    
    /// Capture the current camera view.
    func capturePhoto() {
        checkPermissions { if $0 == nil { return } }
        guard let delegate = delegate else { return }
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .quality
        output.capturePhoto(with: settings, delegate: delegate)
    }
}
