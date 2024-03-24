//
//  MeasurementsV.swift
//  Map Map
//
//  Created by Ben Roberts on 3/24/24.
//

import SwiftUI

struct MeasurementsV: View {
    @Environment(MapDetailsM.self) var mapDetails
    @FetchRequest(sortDescriptors: []) var measurementCoords: FetchedResults<MapMeasurementCoordinate>
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}
