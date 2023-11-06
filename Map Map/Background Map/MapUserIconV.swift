//
//  UserIconV.swift
//  Map Map
//
//  Created by Ben Roberts on 10/27/23.
//

import SwiftUI

struct MapUserIcon: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundStyle(.white, .blue)
            .frame(width: 24, height: 24)
    }
}
