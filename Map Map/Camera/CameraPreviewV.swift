//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import Bottom_Drawer
import SwiftUI

struct CameraPreviewV: View {
    let cameraService = CameraPreviewVM()
    @Environment(\.dismiss) var dismiss
    @State var finalPhoto: UIImage?
    @State var rotationAngle: Angle = .zero
    @State var allowsPhoto: Bool = true
    
    init() { adjustAngle() }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                CameraPreview(cameraService: cameraService) { result in
                    switch result {
                    case .success(let photo):
                        if let photoData = photo.cgImageRepresentation() {
                            finalPhoto = UIImage(cgImage: photoData)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    allowsPhoto = true
                }
                .rotationEffect(rotationAngle)
                .onChange(of: geo.size, initial: false) { _, update in
                    cameraService.previewLayer.frame = CGRect(x: 0, y: 0, width: update.width, height: update.height)
                    adjustAngle()
                }
            }
            .background(.black)
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center]) { _ in
                HStack {
                    Button(action: {
                        allowsPhoto = false
                        cameraService.capturePhoto()
                    }, label: {
                        Text("Capture")
                            .bigButton(backgroundColor: .blue)
                    })
                    .disabled(!allowsPhoto)
                    
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: .gray)
                    })
                }
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

struct CameraPreview: UIViewControllerRepresentable {
    let cameraService: CameraPreviewVM
    let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
    
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
        private let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
        
        init(parent: CameraPreview, didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> ()) {
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
