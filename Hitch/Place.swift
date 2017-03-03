//
//  Place.swift
//  Hitch
//
//  Created by Brandon Price on 2/3/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import CoreLocation

class Place {
    var title : String?
    var subtitle : String?
    var coordinate : CLLocationCoordinate2D?
    
    init (title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D?) {
        self.title = title
        self.subtitle = title
        self.coordinate = coordinate
    }
    
    // Check's the distance between two points.
    class func distanceBetween (coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> Double {
        
        let latDist = pow((coordinate1.latitude - coordinate2.latitude), 2)
        let longDist = pow((coordinate1.longitude - coordinate2.longitude), 2)
        
        return sqrt(latDist + longDist)
    }
}


