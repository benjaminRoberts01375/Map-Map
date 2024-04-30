//
//  MappableEditor.swift
//  Map Map
//
//  Created by Ben Roberts on 4/29/24.
//

import Bottom_Drawer
import CoreData
import SwiftUI

struct MapDisplayableEditorV: View {
    @State var viewModel: ViewModel
    @Environment(MapDetailsM.self) var mapDetails
    
    init(
        editing: any MapDisplayable & ListItem & EditableDataBlock & NSManagedObject,
        actionButtons: [EditorButton] = [],
        overlay: @escaping () -> any View,
        additionalSaveAction: @escaping () -> Void
    ) {
        self.viewModel = ViewModel(
            actionButtons: actionButtons,
            additionalSaveAction: additionalSaveAction,
            overlay: overlay,
            editing: editing
        )
    }
    
    var body: some View {
        ZStack {
            Color.clear
            AnyView(viewModel.overlay())
                .ignoresSafeArea()
            BottomDrawer(verticalDetents: [.content], horizontalDetents: [.center], shortCardSize: 350) { isShortCard in
                BottomButtonsV(viewModel: $viewModel)
                    .padding(.bottom, isShortCard ? 0 : 10)
            }
        }
        .onAppear { mapDetails.preventFollowingUser() }
    }
}
