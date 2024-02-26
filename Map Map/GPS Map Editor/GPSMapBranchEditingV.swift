//
//  GPSMapBranchEditingV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/23/24.
//

import SwiftUI

struct GPSMapBranchEditingV: View {
    @ObservedObject var gpsMapBranch: GPSMapBranch
    @State private var workingName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Branch name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
                ColorPicker("", selection: $gpsMapBranch.branchColor, supportsOpacity: false)
                    .labelsHidden()
            }
            HStack {
                
            }
        }
    }
}
