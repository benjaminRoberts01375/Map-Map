//
//  UseHUDTip.swift
//  Map Map
//
//  Created by Ben Roberts on 4/4/24.
//

import TipKit

struct UseHUDTip: Tip {
    static var count = Event(id: "UseHUDAppLaunches")
    
    var title: Text {
        Text("HUD Settings")
    }
    
    var message: Text? {
        Text("Tap and hold on the HUD to see additional settings.")
    }
    
    var image: Image? {
        Image(systemName: "info.windshield")
    }

    var options: [Option] {
        // Show this tip once.
        Tips.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [ 
            #Rule(Self.count) { $0.donations.count == 3 }
        ]
    }
}
