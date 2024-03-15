//
//  NewGPSDrawerV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/9/24.
//

import SwiftUI

struct NewGPSDrawerContentV: View {
    /// Current managed object context.
    @Environment(\.managedObjectContext) var moc
    /// Current working name of the gps map.
    @Binding var workingName: String
    /// GPS map to edit.
    @ObservedObject var gpsMap: GPSMap
    /// Track the presents of an alert informing the user they have not permitted map map to track location at all.
    @State var locationNeverAvailable: Bool = false
    /// GPS user location.
    @State private var locationsHandler = LocationsHandler.shared
    
    var body: some View {
        VStack {
            HStack {
                TextField("GPS Map Name", text: $workingName)
                    .padding(.all, 5)
                    .background(Color.gray.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 205)
            }
            HStack {
                Button {
                    switch locationsHandler.authorizationStatus {
                    case .authorizedAlways: gpsMap.isTracking = true
                    default: locationNeverAvailable = true
                    }
                } label: {
                    Text("Start").bigButton(backgroundColor: .green)
                }
                Button { moc.delete(gpsMap) } label: { Text("Nevermind").bigButton(backgroundColor: .red) }
            }
        }
        .locationNeverAvailable(isPresented: $locationNeverAvailable) { gpsMap.isTracking = true }
    }
}
