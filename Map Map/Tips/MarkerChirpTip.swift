//
//  MarkerChirpTip.swift
//  Map Map
//
//  Created by Ben Roberts on 4/3/24.
//

import TipKit

struct MarkerChirpTip: Tip {
    static let count = Event(id: "MarkerChirpTipCount")
    @Parameter(.transient)
    static var discoveredThisSession: Bool = false
    
    var title: Text {
        Text("Marker Sounds")
    }
    
    var message: Text? {
        Text("Leave Map Map open to hear when you get near a Marker.")
    }
    
    var image: Image? {
        Image(systemName: "bolt.fill")
    }
    
    var rules: [Rule] {
        [ 
            #Rule(Self.count) {
                $0.donations.count == 1
            },
            #Rule(Self.$discoveredThisSession) { $0 }
        ]
    }
}
