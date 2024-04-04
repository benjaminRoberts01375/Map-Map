//
//  AddMapMapTip.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import TipKit

struct AddMapMapTip: Tip {
    @Parameter
    static var discovered: Bool = false

    @Parameter
    static var createdMapMap: Bool = false
    
    var title: Text {
        Text("Add Your First Map Map")
    }
    
    var message: Text? {
        Text("Bring in a photo of a map to see where you are on it.")
    }
    
    var image: Image? {
        Image(systemName: "map.fill")
    }
    
    var options: [Option] {
        // Show this tip once.
        Tips.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$discovered) { $0 },
            #Rule(Self.$createdMapMap) { !$0 }
        ]
    }
}
