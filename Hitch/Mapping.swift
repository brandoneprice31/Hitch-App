//
//  Mapping.swift
//  Hitch
//
//  Created by Brandon Price on 2/9/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Mapbox
import MapKit
import MapboxDirections
import Foundation


class Mapping {
    
    // Function used for drawing drives on map views.
    class func DrawDriveOnMapView (mapView: MGLMapView, drive: Drive) {
        
        // Configure Annotations.
        let startAnnotation = MGLPointAnnotation()
        startAnnotation.coordinate = drive.start.coordinate!
        startAnnotation.title = drive.start.title
        startAnnotation.subtitle = drive.start.subtitle
        
        let endAnnotation = MGLPointAnnotation()
        endAnnotation.coordinate = drive.end.coordinate!
        endAnnotation.title = drive.end.title
        endAnnotation.subtitle = drive.end.subtitle
        
        // Set annotations.
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
        
        // Check if this is a hitched drive.
        if drive.pickingUpHiker {
            
            let pickUpAnnotation = MGLPointAnnotation()
            pickUpAnnotation.coordinate = drive.pickUpLocation!.coordinate!
            pickUpAnnotation.title = drive.pickUpLocation!.title
            pickUpAnnotation.subtitle = drive.pickUpLocation!.subtitle
            
            let dropOffAnnotation = MGLPointAnnotation()
            dropOffAnnotation.coordinate = drive.dropOffLocation!.coordinate!
            dropOffAnnotation.title = drive.dropOffLocation!.title
            dropOffAnnotation.subtitle = drive.dropOffLocation!.subtitle
            
            mapView.addAnnotation(pickUpAnnotation)
            mapView.addAnnotation(dropOffAnnotation)
            mapView.addAnnotations(drive.pickUpPolyLines)
            
        } else {
            mapView.add(drive.polyLine!)
        }
        
        mapView.showAnnotations(mapView.annotations!, animated: false)
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
