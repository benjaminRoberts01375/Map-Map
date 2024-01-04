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
    /// Editor case where editing this specific Map Map.
    case mapMap(FetchedResults<MapMap>.Element)
    /// Editor case where editing this specific Marker.
    case marker(FetchedResults<Marker>.Element)
    /// Editor case where editing measurements.
    case measurement
    /// Not editing anything.
    case nothing
}
