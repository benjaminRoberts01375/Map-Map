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
    @State var startingPos: CGSize?
    @State var endingPos: CGSize?
    @State var isDragging: Bool = false
    
    var drawGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { update in
                if !isDragging {
                    startingPos = CGSize(cgPoint: update.startLocation)
                    isDragging = true
                }
                endingPos = CGSize(cgPoint: update.location)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    var body: some View {
        ZStack {
            Color.primary
                .opacity(0.5)
                .ignoresSafeArea()
                .gesture(drawGesture)
            ZStack {
                if let startingPos = startingPos, let endingPos = endingPos {
                    Line(startingPos: startingPos, endingPos: endingPos)
                        .stroke(lineWidth: 5.0)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
                if let checkedStartingPos = startingPos {
                    let convertedStartingPos = Binding { checkedStartingPos } set: { startingPos = $0 }
                    HandleV(position: convertedStartingPos)
                }
                if let checkedEndingPos = endingPos {
                    let convertedEndingPos = Binding { checkedEndingPos } set: { endingPos = $0 }
                    HandleV(position: convertedEndingPos)
                }
            }
            .ignoresSafeArea()
                
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
