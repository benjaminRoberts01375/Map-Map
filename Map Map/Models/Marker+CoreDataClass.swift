//
//  Marker+CoreDataClass.swift
//  Map Map
//
//  Created by Ben Roberts on 11/20/23.
//
//

import CoreData
import SwiftUI

@objc(Marker)
public class Marker: NSManagedObject {
    var thumbnail: some View {
        get {
            Circle()
                .fill(.red)
                .overlay {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.6)
                        .foregroundStyle(.white)
                }
                .ignoresSafeArea(.all)
        }
    }
}
