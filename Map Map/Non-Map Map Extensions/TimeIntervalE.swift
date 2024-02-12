//
//  TimeIntervalE.swift
//  Map Map
//
//  Created by Ben Roberts on 2/11/24.
//

import Foundation

extension TimeInterval {
    /// String representation of this TimeInterval
    public var description: String {
        let totalSeconds = Int(self) // Only calculate on whole seconds
        let hours = Int(totalSeconds / 3600) // 3600 seconds in an hour
        let minutes = Int((totalSeconds - hours * 3600) / 60) // Determine how many seconds were used for hrs, then get remaining minutes.
        let seconds = Int(totalSeconds - (hours * 60 + minutes) * 60) // Get remaining seconds leftover from minutes and hours.
        let secondSpacer = "\(seconds < 10 ? "0" : "")" // Add a leading 0 if the seconds are fewer than 10.
        var time: String = "\(minutes):\(secondSpacer)\(seconds)" // Format the time.
        if hours != .zero {
            let minuteSpacer = "\(hours > 0 && minutes < 10 ? "0" : "")" // Add a leading 0 to minutes if there are hours, and minutes <10
            time = "\(hours):\(minuteSpacer)\(time)" // Reformat time.
        }
        return time
    }
}
