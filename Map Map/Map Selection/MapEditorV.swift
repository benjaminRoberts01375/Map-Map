//
//  MapEditorV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/9/23.
//

import SwiftUI

struct MapEditor: View {
    let photo: FetchedResults<MapPhoto>.Element
    @State var workingTitle: String = "Untitled"
    
    var body: some View {
        ZStack {
            Color.clear
            switch photo.image {
            case .loading(let loading):
                AnyView(loading)
            case .failure(let failure):
                AnyView(failure)
            case .success(let image):
                AnyView(image)
            }
            
            VStack {
                Spacer(minLength: 0)
                TextField("\(Image(systemName: "pencil")) Map name", text: $workingTitle)
                    .frame(width: 200, height: 35)
                    .padding(.horizontal, 10)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 10)
                    .padding(.bottom, 40)
            }
        }
        .onChange(of: workingTitle) { newText in
            photo.mapName = workingTitle
        }
    }
}
