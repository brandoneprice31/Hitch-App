//
//  Ride.swift
//  Hitch
//
//  Created by Brandon Price on 1/15/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

// Class for storing routes.
class Ride {
    
    // Properties.
    var start : Place?
    var end : Place?
    var drive : Drive?
    
    // Empty init.
    init () {
        self.start = nil
        self.end = nil
        self.drive = nil
    }
    
    // Filled init.
    init (start: Place? , end: Place?, drive: Drive?) {
        self.start = start
        self.end = end
        self.drive = drive
    }
}

