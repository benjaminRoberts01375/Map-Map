//
//  MeasurementEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 12/15/23.
//

import Bottom_Drawer
import SwiftUI

struct MeasurementEditorV: View {
    @ObservedObject var measurement: FetchedResults<MapMeasurement>.Element
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        ZStack {
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                Button {
                    try? moc.save()
                    measurement.isEditing = false
                } label: {
                    Text("Done")
                        .bigButton(backgroundColor: .blue)
                }
            }
        }
    }
}
