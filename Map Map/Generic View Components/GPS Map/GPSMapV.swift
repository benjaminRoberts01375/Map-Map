//
//  GPSMapV.swift
//  Map Map
//
//  Created by Ben Roberts on 2/16/24.
//

import MapKit
import SwiftUI

struct GPSMapV: View {
    /// Info about the base map.
    @Environment(MapDetailsM.self) var mapDetails
    /// GPS Map to view.
    @ObservedObject var gpsMap: GPSMap
    
    @State var lines: [Connection] = []
    
    @State var lineEnds: [GPSMapCoordinate : CGPoint] = [:]
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
    
    /// Based on the notification ``NSManagedObjectContextObjectsDidChange`` Core Data notification, check to see how Core Data has updated,
    /// and if it's neccessary for the displayed connections.
    /// If it is neccessary, then update as needed.
    /// - Parameter notification: Notification from Core Data
   private func interpretCDNotification(_ notification: NotificationCenter.Publisher.Output) {
       for userInfoElement in notification.userInfo ?? [:] {
           if let message = userInfoElement.key as? String {
               if message == .invalidatedAll || message == .deleted || message == .inserted {
                   self.lines = connectionsToDraw()
                   break
               }
               else if message == .update, let mapCoordinates = userInfoElement.value as? Set<GPSMapCoordinate> {
                   if mapCoordinates.count > 1 { self.lines = connectionsToDraw() }
                   updateCoordinate(mapCoordinates)
               }
           }
       }
       Task {
           let positions = await calculateSSlineEndPos()
           DispatchQueue.main.async { self.lineEnds = positions }
       }
   }
    
    func calculateSSlineEndPos() async -> [GPSMapCoordinate : CGPoint] {
        var result: [GPSMapCoordinate : CGPoint] = [:]
        for line in lines {
            result[line.start] = mapDetails.mapProxy?.convert(line.start.coordinates, to: .global)
            result[line.end] = mapDetails.mapProxy?.convert(line.end.coordinates, to: .global)
        }
        return result
    }
    
    /// Update lines to use correct distances.
    /// - Parameter mapCoordinates: Map Coordinates to be updated.
    private func updateCoordinate(_ mapCoordinates: Set<GPSMapCoordinate>) {
        for mapCoordinate in mapCoordinates {
            for lineIndex in lines.indices {
                if lines[lineIndex].start == mapCoordinate {
                    let startLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                    let endLocation = CLLocation(latitude: lines[lineIndex].end.latitude, longitude: lines[lineIndex].end.longitude)
                }
                else if lines[lineIndex].end == mapCoordinate {
                    let startLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
                    let endLocation = CLLocation(latitude: lines[lineIndex].start.latitude, longitude: lines[lineIndex].start.longitude)
                }
            }
        }
    }
    
    func connectionsToDraw() -> [Connection] {
        var visited: Set<GPSMapCoordinate> = []
        var connections: [Connection] = []
        for firstNode in gpsMap.unwrappedCoordinates {
            if visited.contains(firstNode) { continue }
            var queue: Set<GPSMapCoordinate> = [firstNode]
            
            while !queue.isEmpty {
                let current = queue.removeFirst()
                for connectedNode in current.unwrappedNeighbors {
                    if visited.contains(connectedNode) { continue }
                    queue.insert(connectedNode)
                    connections.append(Connection(connectedNode, current))
                }
                visited.insert(current)
            }
        }
        return connections
    }
}
