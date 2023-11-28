//
//  MarkerSymbolPickerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

struct MarkerSymbolPickerV: View {
    private let thumbnailImages: [String] = Mirror(reflecting: AvailableThumbnailImagesM()).children.map( { $0.value as! String })
    let backgroundColor: Color
    
    var body: some View {
        ScrollView {
            Color.clear
                .frame(height: 250)
            WHStack {
                ForEach(thumbnailImages, id: \.self) { symbol in
                    MarkerSymbolPickerItemV(symbol: symbol, backgroundColor: backgroundColor)
                        .frame(width: 40, height: 40)
                        .padding()
                }
            }
            .frame(width: 325, height: 300)
            Color.clear
                .frame(height: 250)
        }
    }
}

struct MarkerSymbolPickerV_Previews: PreviewProvider {
    struct Container: View {
        @State var showingPopover = true
        var body: some View {
            VStack() {
                Button(
                    action: {
                        showingPopover.toggle()
                    }, label: {
                        Text("Toggle popover")
                    }
                )
                .popover(isPresented: $showingPopover, arrowEdge: .top , content: {
                    MarkerSymbolPickerV(backgroundColor: .red)
                        .presentationCompactAdaptation(.popover)
                })
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
