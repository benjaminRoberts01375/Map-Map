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
    @Binding var selectedSymbol: String?
    
    var body: some View {
        ScrollView {
            WHStack {
                ForEach(thumbnailImages, id: \.self) { symbol in
                    MarkerSymbolPickerItemV(symbol: symbol, backgroundColor: backgroundColor)
                        .frame(width: 45, height: 45)
                        .padding()
                        .background {
                            if symbol == selectedSymbol {
                                Color.gray
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                }
            }
        }
        .frame(width: 325, height: 300)
    }
}

struct MarkerSymbolPickerV_Previews: PreviewProvider {
    struct Container: View {
        @State var showingPopover = true
        @State var selectedSymbol: String? = "map"
        
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
                    MarkerSymbolPickerV(backgroundColor: .red, selectedSymbol: $selectedSymbol)
                        .presentationCompactAdaptation(.popover)
                })
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
