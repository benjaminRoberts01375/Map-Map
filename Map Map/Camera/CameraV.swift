//
//  CameraV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/7/23.
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    @State var cameraVM = CameraVM()

    var body: some View {
        VStack {
            ZStack {
                if let livePreview = cameraVM.livePreview {
                    Image(uiImage: livePreview)
                        .resizable()
                        .scaledToFit()
                }
                
                Button("Capture") {
                    cameraVM.capturePhoto()
                }
            }
            if let output = cameraVM.finalPhoto {
                Image(uiImage: output)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
        }
        .onAppear {
            cameraVM.startSession()
        }
        .onDisappear {
            cameraVM.endSession()
        }
    }
}
struct CameraPreview: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
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
