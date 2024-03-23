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
        /// The current file cannot be read.
        var fileNotReadable: Bool = false
        /// The current file cannot even be opened for reading.
        var noFilePermission: Bool = false
        /// Not able to parse a PDF.
        var unableToReadPDF: Bool = false
        /// File type is unsupported.
        var unknownImageType: Bool = false
    }
}
