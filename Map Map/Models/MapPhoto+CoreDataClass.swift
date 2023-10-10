//
//  MapPhoto+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 10/8/23.
//
//

import CoreData
import PhotosUI
import SwiftUI

@objc(MapPhoto)
public class MapPhoto: NSManagedObject {
    private var image: ImageStatus = .loading(ProgressView())
    private(set) var isEditing: Bool = true
    private var isSettingUp: Bool = false
    private var failureView: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.yellow)
    }
    
    enum ImageStatus {
        case loading(any View)
        case success(any View)
        case failure(any View)
    }
}

extension MapPhoto {
    convenience public init(rawPhoto: PhotosPickerItem?, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        isSettingUp = true
        Task {
            if let data = try? await rawPhoto?.loadTransferable(type: Data.self) { dataToImage(data) }
            else { self.image = .failure(failureView) }
        }
    }
    
    func markComplete() {
        isEditing = !(mapName?.isEmpty ?? true)
    }
    
    func dataToImage(_ data: Data) {
        if let uiImage = UIImage(data: data) {
            self.image = .success(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            )
            self.map = data
        }
    }
    
    func getImageStatus() -> ImageStatus {
        switch image {
        case .loading(_):
            if !isSettingUp {
                isEditing = false
                if let mapData = self.map {
                    isSettingUp = true
                    dataToImage(mapData)
                }
                else {
                    image = .failure(failureView)
                }
            }
        default:
            break
        }
        return image
    }
    
    func getImage() -> any View {
        let img = getImageStatus()
        switch img {
        case .loading(let loading):
            return loading
        case .failure(let failure):
            return failure
        case .success(let success):
            return success
        }
    }
}
