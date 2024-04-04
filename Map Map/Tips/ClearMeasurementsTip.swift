//
//  AddMapMaps.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import TipKit

struct ClearMeasurementsTip: Tip {
    @Parameter
    static var discovered: Bool = false
    
    var title: Text {
        Text("Remove Them All!")
    }
    
    var message: Text? {
        Text("Tap and hold on the measurement button to delete all measurements.")
    }
    
    var image: Image? {
        Image(systemName: "ruler")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$discovered) { $0 }
        ]
    }
}
