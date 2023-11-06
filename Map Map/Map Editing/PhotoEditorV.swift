//
//  PhotoEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/31/23.
//

import Bottom_Drawer
import CoreImage
import SwiftUI

struct PhotoEditorV: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.pixelLength) var pixelLength
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var mapMap: FetchedResults<MapMap>.Element
    @State var topLeadingPoint: CGSize
    @State var topTrailingPoint: CGSize
    @State var bottomLeadingPoint: CGSize
    @State var bottomTrailingPoint: CGSize
    @State var screenSpaceImageSize: CGSize = .zero
    
    init(mapMap: FetchedResults<MapMap>.Element) {
        self.mapMap = mapMap
        if let corners = mapMap.cropCorners { // If there are pre-defined corners, set those up
            self._topLeadingPoint = State(initialValue: corners.topLeading)
            self._topTrailingPoint = State(initialValue: corners.topTrailing)
            self._bottomLeadingPoint = State(initialValue: corners.bottomLeading)
            self._bottomTrailingPoint = State(initialValue: corners.bottomTrailing)
        }
        else { // No predefined corners, set corners to the actual corners of the photo
            self._topLeadingPoint = State(initialValue: .zero)
            self._topTrailingPoint = State(initialValue: CGSize(width: mapMap.imageWidth, height: .zero))
            self._bottomLeadingPoint = State(initialValue: CGSize(width: .zero, height: mapMap.imageHeight))
            self._bottomTrailingPoint = State(initialValue: CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight))
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    AnyView(mapMap.getMap(.original))
                        .background {
                            GeometryReader { imageGeo in
                                Color.clear
                                    .onChange(of: imageGeo.size, initial: true) { _, update in
                                        screenSpaceImageSize = update
                                        let scaleRatio = screenSpaceImageSize / CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight)
                                        topLeadingPoint *= scaleRatio
                                        topTrailingPoint *= scaleRatio
                                        bottomLeadingPoint *= scaleRatio
                                        bottomTrailingPoint *= scaleRatio
                                    }
                            }
                        }
                        .frame(height: geo.size.height * 0.75)
                    
                    IrregularGridV(
                        topLeading: topLeadingPoint,
                        topTrailing: topTrailingPoint,
                        bottomLeading: bottomLeadingPoint,
                        bottomTrailing: bottomTrailingPoint
                    )
                    .fill(.clear)
                    .stroke(.white.opacity(0.75), lineWidth: 2)
                    .offset(
                        x: (geo.size.width - screenSpaceImageSize.width) / 2,
                        y: (geo.size.height - screenSpaceImageSize.height) / 2
                    )
                    
                    ZStack(alignment: .topLeading) {
                        HandleV(position: $topLeadingPoint)
                        HandleV(position: $topTrailingPoint)
                        HandleV(position: $bottomLeadingPoint)
                        HandleV(position: $bottomTrailingPoint)
                    }
                    .offset(
                        x: (geo.size.width - screenSpaceImageSize.width) / 2,
                        y: (geo.size.height - screenSpaceImageSize.height) / 2
                    )
                }
            }
            .ignoresSafeArea()
            .background(.black)
            
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { _ in
                HStack {
                    Button {
                        let inverseRatio = CGSize(width: mapMap.imageWidth, height: mapMap.imageHeight) / screenSpaceImageSize
                        let topLeading = topLeadingPoint * inverseRatio
                        let topTrailing = topTrailingPoint * inverseRatio
                        let bottomLeading = bottomLeadingPoint * inverseRatio
                        let bottomTrailing = bottomTrailingPoint * inverseRatio
                        mapMap.setCorners(
                            topLeading: topLeading,
                            topTrailing: topTrailing,
                            bottomLeading: bottomLeading,
                            bottomTrailing: bottomTrailing
                        )
                        mapMap.applyPerspectiveCorrectionWithCorners()
                        dismiss()
                    } label: {
                        Text("Save")
                            .bigButton(backgroundColor: .blue)
                    }
                    Button {
                        topLeadingPoint = .zero
                        topTrailingPoint = CGSize(width: screenSpaceImageSize.width, height: .zero)
                        bottomLeadingPoint = CGSize(width: .zero, height: screenSpaceImageSize.height)
                        bottomTrailingPoint = screenSpaceImageSize
                    } label: {
                        Text("Reset")
                            .bigButton(backgroundColor: .gray)
                    }
                    Button {
                        moc.reset()
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bigButton(backgroundColor: .gray)
                    }
                }
            }
        }
    }
}
