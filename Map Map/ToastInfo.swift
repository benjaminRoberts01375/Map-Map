//
//  ToastInfo.swift
//  Map Map
//
//  Created by Ben Roberts on 11/15/23.
//

import Foundation

@Observable
final class ToastInfo {
    /// Text to display in a toast notification
    public var info: String = ""
    /// Track if the toast notification should be displayed.
    public var showing: Bool = false
}
