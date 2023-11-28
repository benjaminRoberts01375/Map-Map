//
//  MarkerSymbolPickerV.swift
//  Map Map
//
//  Created by Ben Roberts on 11/28/23.
//

import SwiftUI

struct MarkerSymbolPickerV: View {
    private let thumbnailImages: [String] = Mirror(reflecting: AvailableThumbnailImagesM()).children.map( { $0.value as! String })
    
    var body: some View {
        ScrollView {
            Color.clear
                .frame(height: 70)
            WHStack {
                ForEach(thumbnailImages, id: \.self) { symbol in
                    MarkerSymbolPickerItemV(symbol: symbol)
                        .frame(width: 40, height: 40)
                        .padding(5)
                }
            }
            .frame(width: 300, height: 300)
            Color.clear
                .frame(height: 70)
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
                    MarkerSymbolPickerV()
                        .presentationCompactAdaptation(.popover)
                })
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
