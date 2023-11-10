//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    let cameraService = CameraService()
    @State var finalPhoto: UIImage?
    
    var body: some View {
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
            }
            .onChange(of: geo.size, initial: true) { _, update in
                cameraService.previewLayer.frame = CGRect(x: 0, y: 0, width: update.width, height: update.height)
            }
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    let cameraService: CameraService
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
