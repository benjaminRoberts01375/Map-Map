//
//  TimeIntervalE.swift
//  Map Map
//
//  Created by Ben Roberts on 2/11/24.
//

import Foundation

extension TimeInterval {
    public var description: String {
        let totalSeconds = Int(self)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds - hours * 3600) / 60)
        let seconds = Int(totalSeconds - (hours * 60 + minutes) * 60)
        let secondSpacer = "\(seconds < 10 ? "0" : "")"
        var time: String = "\(minutes):\(secondSpacer)\(seconds)"
        if hours != .zero {
            let minuteSpacer = "\(hours > 0 && minutes < 10 ? "0" : "")"
            time = "\(hours):\(minuteSpacer)\(time)"
        }
        return time
    }
}
