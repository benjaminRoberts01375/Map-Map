//
//  EditableDataBlockP.swift
//  Map Map
//
//  Created by Ben Roberts on 4/3/24.
//

import NotificationCenter

protocol EditableDataBlock {
    var isSetup: Bool { get }
    var isEditing: Bool { get set }
    func startEditing()
    func endEditing()
}
