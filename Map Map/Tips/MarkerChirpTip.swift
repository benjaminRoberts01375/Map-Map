//
//  MarkerChirpTip.swift
//  Map Map
//
//  Created by Ben Roberts on 4/3/24.
//

import TipKit

struct MarkerChirpTip: Tip {
    static let count = Event(id: "MarkerChirpTipCount")
    
    var title: Text {
        Text("Marker Sounds")
    }
    
    var message: Text? {
        Text("Leave Map Map open to hear when you get near a Marker.")
    }
    
    var image: Image? {
        Image(systemName: "bolt.fill")
    }
    
    var options: [Option] {
        // Show this tip once.
        Tips.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [ 
            #Rule(Self.count) { $0.donations.count == 1 }
        ]
    }
}
