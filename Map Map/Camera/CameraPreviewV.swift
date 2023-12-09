//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import Bottom_Drawer
import SwiftUI

/// Live preview of the camera.
struct CameraPreviewV: View {
    /// View model of the live camera.
    private let cameraService = CameraPreviewVM()
    /// Dismiss function for this view.
    @Environment(\.dismiss) private var dismiss
    /// Output photo from the live camera view.
    @Binding var finalPhoto: UIImage?
    /// Current rotation of the device.
    @State private var rotationAngle: Angle = .zero
    /// Control if the user's allowed to take a photo.
    @State private var allowsPhoto: Bool = true
    
    @State private var permissionsEnabled: Bool = false
    
    init(photoPassthrough: Binding<UIImage?>) {
        self._finalPhoto = photoPassthrough
        adjustAngle()
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                if permissionsEnabled {
                    CameraPreview(cameraService: cameraService) { result in
                        switch result {
                        case .success(let photo):
                            guard let photoData = photo.cgImageRepresentation() else { return }
                            switch UIDevice.current.orientation {
                            case .landscapeLeft:
                                finalPhoto = UIImage(cgImage: photoData, scale: 1, orientation: .up)
                            case .landscapeRight:
                                finalPhoto = UIImage(cgImage: photoData, scale: 1, orientation: .down).fixOrientation()
                            case .portrait:
                                finalPhoto = UIImage(cgImage: photoData, scale: 1, orientation: .right).fixOrientation()
                            case .portraitUpsideDown:
                                finalPhoto = UIImage(cgImage: photoData, scale: 1, orientation: .left).fixOrientation()
                            default:
                                finalPhoto = UIImage(cgImage: photoData, scale: 1, orientation: .right).fixOrientation()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                        allowsPhoto = true
                    }
                    .rotationEffect(rotationAngle)
                    .onChange(of: geo.size, initial: true) { _, update in
                        cameraService.previewLayer.frame = CGRect(x: 0, y: 0, width: update.width, height: update.height)
                        adjustAngle()
                    }
                }
            }
            .background(.black)
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { isShortCard in
                HStack {
                    Button(action: {
                        allowsPhoto = false
                        cameraService.capturePhoto()
                    }, label: {
                        Text("Capture")
                            .bigButton(backgroundColor: .blue.opacity(permissionsEnabled ? 1 : 0.35))
                    })
                    .disabled(!allowsPhoto || !permissionsEnabled)
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: .gray)
                    })
                }
                .padding(.bottom, isShortCard ? 0 : 10)
            }
            .onChange(of: AVCaptureDevice.authorizationStatus(for: .video), initial: true) { _, update in
                switch update {
                case .authorized:
                    permissionsEnabled = true
                case .notDetermined, .restricted, .denied:
                    permissionsEnabled = false
                @unknown default:
                    permissionsEnabled = false
                }
                print("Permissions:", permissionsEnabled)
            }
        }
    }
    
    func adjustAngle() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            rotationAngle = Angle(degrees: 270)
        case .landscapeRight:
            rotationAngle = Angle(degrees: 90)
        case .portrait:
            rotationAngle = Angle(degrees: 0)
        case .portraitUpsideDown:
            rotationAngle = Angle(degrees: 180)
        default:
            rotationAngle = Angle(degrees: 0)
        }
    }
}

/// Backend component to the camera's live preview.
struct CameraPreview: UIViewControllerRepresentable {
    let cameraService: CameraPreviewVM
    let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        cameraService.start(delegate: context.coordinator) { error in
            if let error = error { didFinishProcessingPhoto(.failure(error)) }
        }
        
        let viewController = UIViewController()
        viewController.view.layer.addSublayer(cameraService.previewLayer)
        cameraService.previewLayer.frame = viewController.view.bounds // Fill the available area
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, didFinishProcessingPhoto: didFinishProcessingPhoto)
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraPreview
        private let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> Void
        
        init(parent: CameraPreview, didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> Void) {
            self.parent = parent
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            didFinishProcessingPhoto(.success(photo))
        }
    }
}
