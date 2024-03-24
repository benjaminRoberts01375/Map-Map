//
//  MeasurementEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import Bottom_Drawer
import MapKit
import SwiftUI

struct MeasurementEditorV: View {
    /// Editor being used by Map Map.
    @State var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
        }
    }
}
