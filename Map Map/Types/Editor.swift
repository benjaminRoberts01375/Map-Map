//
//  Editor.swift
//  Map Map
//
//  Created by Ben Roberts on 12/23/23.
//

import CoreData
import SwiftUI

/// Available editors.
public enum Editor {
    case mapMap(FetchedResults<MapMap>.Element)
    case marker(FetchedResults<Marker>.Element)
    case measurement
    case nothing
}
