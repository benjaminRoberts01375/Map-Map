//
//  AlertManager.swift
//  Map Map
//
//  Created by Ben Roberts on 3/23/24.
//

import SwiftUI

extension DefaultDrawerHeaderV.ViewModel {
    @Observable
    final class AlertManager {
        var fileNotReadable: Bool = false
        var noFilePermission: Bool = false
        var unableToReadPDF: Bool = false
        var unknownImageType: Bool = false
    }
}
