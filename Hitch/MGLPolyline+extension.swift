//
//  MGLPolyline+extension.swift
//  Hitch
//
//  Created by Brandon Price on 3/8/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import Mapbox
import MapKit

extension MGLPolyline {
    
    
    // Get byte string.
    func getByteString () -> String {
        let byteString = self.geoJSONData(usingEncoding: 1).base64EncodedString()
        return byteString
    }
    
    // Convert from byte string to mglpolyline.
    class func PolylineFromByteString (byteString : String) -> MGLPolyline {
        let data = Data(base64Encoded: byteString)
        let polyline = MGLPolyline.loadPolyLineFromGEOJSON(polyLineData: data!)
        
        return polyline!
    }
    
    // Convert from MapKit Polyline to MapBox Polyline.
    class func MKPolylineToMGLPolyine (mkPolyline: MKPolyline) -> MGLPolyline {
        
        let pointCount: Int = mkPolyline.pointCount
        
        //allocate a C array to hold this many points/coordinates...
        //var routeCoordinatesUnsafe = malloc(pointCount * MemoryLayout<CLLocationCoordinate2D>.size)
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: pointCount)
        
        //get the coordinates (all of them)...
        mkPolyline.getCoordinates(coordsPointer, range: NSRange(location: 0, length: pointCount))
        
        // Construct MGLPolyline
        let routeLine = MGLPolyline(coordinates: coordsPointer, count: UInt(pointCount))
        
        return routeLine
    }
    
    // Function for loading geojson representation of a polyline into a mglpolyline.
    class func loadPolyLineFromGEOJSON (polyLineData: Data) -> MGLPolyline? {
        
        var polyLine : MGLPolyline? = nil
        do {
            let jsonData = try JSONSerialization.jsonObject(with: polyLineData, options: .mutableContainers) as? [String: Any]
            if jsonData != nil {
                let jsonDict = jsonData!
                
                if let locations = jsonDict["coordinates"] as? [[Double]] {
                    
                    var coordinates = [CLLocationCoordinate2D]()
                    
                    // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                    for location in locations {
                        // Make a CLLocationCoordinate2D with the lat, lng
                        let coordinate = CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
                        coordinates.append(coordinate)
                    }
                    
                    // Store coordinates in polyline.
                    polyLine = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
                }
            }
        } catch {
            fatalError("Could not parse GEOJSON")
        }
        
        return polyLine
    }

    
}
