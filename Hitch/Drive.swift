//
//  Route.swift
//  Hitch
//
//  Created by Brandon Price on 1/5/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Mapbox
import CoreData

// Class for storing routes.
class Drive {
    
    
    // Require Properties.
    
    // Driver
    var firstName : String
    var lastName : String
    var profPicName : String
    var driverID : Int
    
    // Routing
    var start : Place
    var end : Place
    var startDateTime : DateTime
    var endDateTime : DateTime
    var repeatWeekDays : [Int]
    var polyLine : MGLPolyline?
    
    // Pricing
    var basePrice : Double = 0
    
    
    // Optional Properties.
    
    // API Data
    var id : Int?
    
    // Pick-Up Route
    var hitchedStartDateTime : DateTime? = nil
    var pickingUpHiker : Bool = false
    var pickUpLocation : Place? = nil
    var dropOffLocation : Place? = nil
    var pickUpTime : DateTime? = nil
    var dropOffTime : DateTime? = nil
    var pickUpPolyLines = [MGLPolyline]()
    
    // Hiker
    var hikerID : Int? = nil
    var hikerFirstName : String? = nil
    var hikerLastName : String? = nil

    // Extra Pricing
    var extraTimePrice : Double = 0
    
    // Canceled Dates
    var canceledDates = [DateTime]()

    
    // Filled init for mkroute.
    init (driverFirstName: String, driverLastName: String, driverID : Int, start: Place, end: Place, startDateTime: DateTime, endDateTime: DateTime, repeatWeekDays: [Int], polyLine: MGLPolyline?, orRoute: MKRoute?) {

        self.driverID = driverID
        self.firstName = driverFirstName
        self.lastName = driverLastName
        self.profPicName = "\(driverID)_profile_pic.png"
        self.start = start
        self.end = end
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.repeatWeekDays = repeatWeekDays
        
        if polyLine == nil &&  orRoute == nil {
            self.polyLine = nil
        }
        else if polyLine == nil {
            self.polyLine = Mapping.MKPolylineToMGLPolyine(mkPolyline: (orRoute?.polyline)!)
        } else {
            self.polyLine = polyLine!
        }
    }
    
    // Configure optional properties.
    func configureOptionalProperties (driveID: Int?, pickingUpHiker: Bool, pickUpLocation: Place?, dropOffLocation: Place?, pickUpTime: DateTime?, dropOffTime: DateTime?, pickUpPolylines: [MGLPolyline]?, hikerID: Int?, hikerFirstName: String?, hikerLastName: String?, extraTimePrice: Double, canceledDates: [DateTime], hitchedStartDateTime: DateTime?) {
        
        // Core Data
        self.id = driveID
        
        // Pick-Up Route
        self.hitchedStartDateTime = hitchedStartDateTime
        self.pickingUpHiker = pickingUpHiker
        self.pickUpLocation = pickUpLocation
        self.dropOffLocation = dropOffLocation
        self.pickUpTime = pickUpTime
        self.dropOffTime = dropOffTime
        self.pickUpPolyLines = pickUpPolylines == nil ? [] : pickUpPolylines!
        
        // Hiker
        self.hikerID = hikerID
        self.hikerFirstName = hikerFirstName
        self.hikerLastName = hikerLastName
        
        // Extra Pricing
        self.extraTimePrice = extraTimePrice
        
        // Canceled Dates
        self.canceledDates = canceledDates
        
    }
    
    // Function used to load in polyline.
    func calculatePolyLine (route: MKRoute) {
        self.polyLine = Mapping.MKPolylineToMGLPolyine(mkPolyline: route.polyline)
    }
    
    // Returns the week days and the actually month and day.
    class func getDateTimeFromDriveList (driveList : [Drive]) -> [DateTime] {
        
        var result = [DateTime]()
        
        for drive in driveList {
            
            // Get date and weekday.
            let dateTime = drive.startDateTime
            
            result.append(dateTime)
        }
        
        return result
    }
    
    func getLongRepeatedWeekDays () -> [String] {
        return self.repeatWeekDays.map({x -> String in return DateTime.longWeekDays[x-1]})
    }
    
    // Get drive copies that are in a date time range.
    func getDriveCopies (startDateTime : DateTime, endDateTime : DateTime) -> [Drive] {
        
        // If specified end date time is before actual start date time then return empty list.
        if endDateTime.date < self.startDateTime.date {
            return []
        }
        
        // If this isn't a repeating drive then just return itself in a list.
        if self.repeatWeekDays == [] {
            return [self]
        }
        
        var adjustedStart : DateTime
        
        // Check to see if the specified start date time is before the actual start date time.
        if self.startDateTime.isDaysAheadOf(dateTime2: startDateTime){
            adjustedStart = self.startDateTime
        } else {
            adjustedStart = startDateTime
        }
        
        // Get the start date time interator.
        var driveList = [Drive]()
        var iterDateTime = adjustedStart
        iterDateTime.hour = self.startDateTime.hour
        iterDateTime.minute = self.startDateTime.minute
        iterDateTime.storeDate()
        let timeInterval = self.endDateTime.date.timeIntervalSince(self.startDateTime.date)
        
        // Iterate through each day from start to finish.
        while !iterDateTime.isSameDayAs(dateTime2: endDateTime) {
            
            // Check to see if the iter datetime is part of the repeated week day.
            if self.repeatWeekDays.contains(iterDateTime.weekDay) {
                
                // Add this drive.
                let drive = Drive(driverFirstName: self.firstName, driverLastName: self.lastName, driverID: self.driverID, start: self.start, end: self.end, startDateTime: iterDateTime, endDateTime: iterDateTime.addTimeInterval(timeInteral: timeInterval), repeatWeekDays: self.repeatWeekDays, polyLine: self.polyLine, orRoute: nil)
                drive.configureOptionalProperties(driveID: self.id, pickingUpHiker: self.pickingUpHiker, pickUpLocation: self.pickUpLocation, dropOffLocation: self.dropOffLocation, pickUpTime: self.pickUpTime, dropOffTime: self.dropOffTime, pickUpPolylines: self.pickUpPolyLines, hikerID: self.hikerID, hikerFirstName: self.hikerFirstName, hikerLastName: self.hikerLastName, extraTimePrice: self.extraTimePrice, canceledDates: self.canceledDates, hitchedStartDateTime: self.hitchedStartDateTime)
                
                driveList.append(drive)

            }
            
            iterDateTime = iterDateTime.add(years: 0, months: 0, days: 1, hours: 0, minutes: 0)
        }
        
        return driveList
        
    }
    
    // Function that returns all drives that are a certain number of days from a startdate.
    func getDrivesDaysFromNow (startDateTime: DateTime, nDays : Int) -> [Drive] {
        
        let daysFromNow = startDateTime.add(years: 0, months: 0, days: nDays, hours: 0, minutes: 0)
        daysFromNow.minute = self.startDateTime.minute
        daysFromNow.hour = self.startDateTime.hour
        daysFromNow.storeDate()
        
        // Check if this is a repeated drive.
        if self.repeatWeekDays == [] {
            
            if self.startDateTime.date < daysFromNow.date {
                // If this drive's date is less than the calculated date n days from now, then return itself.
                return [self]
            } else {
                // Return nothing.
                return []
            }
        }
        
        let numberOfWeeks = Int(nDays / 7) + 1
        
        var driveList = [Drive]()
        
        // Calculate how many weeks to add.
        let weekArray : [Int] = Array(0..<numberOfWeeks)
        let weekDayArray : [Int]
        
        // Calculate the startingWeekDay
        let startingWeekDay : Int
        let onlyFutureWeekDays = repeatWeekDays.filter({ x -> Bool in return x >= startDateTime.weekDay})
        if onlyFutureWeekDays == [] {
            startingWeekDay = repeatWeekDays.min()!
        } else {
            startingWeekDay = onlyFutureWeekDays.min()!
        }
        
        weekDayArray = Array(startingWeekDay...7) + Array(1..<startingWeekDay)
        
        // Go through each week.
        for week in weekArray {
            
            // Go through each week day.
            for weekDay in weekDayArray {
                
                if repeatWeekDays.contains(weekDay) {
                    
                    // Calculate how many days ahead of today this drive is going to be.
                    let weekCount : Int
                    
                    if weekDay < startingWeekDay {
                        weekCount = week + 1
                    } else {
                        weekCount = week
                    }
                    let daysAheadOfToday : Int = weekDay - startDateTime.weekDay + 7 * weekCount
                    
                    let driveStartDateTime = startDateTime.add(years: 0, months: 0, days: daysAheadOfToday, hours: 0, minutes: 0)
                    driveStartDateTime.minute = self.startDateTime.minute
                    driveStartDateTime.hour = self.startDateTime.hour
                    driveStartDateTime.storeDate()
                    
                    let driveEndDateTime = startDateTime.add(years: 0, months: 0, days: daysAheadOfToday, hours: 0, minutes: 0)
                    driveEndDateTime.minute = self.endDateTime.minute
                    driveEndDateTime.hour = self.endDateTime.hour
                    driveEndDateTime.storeDate()
                    
                    if daysFromNow.isDaysAheadOf(dateTime2: driveStartDateTime) {
                        // If the drive start date time is less than days from now.
                        
                        // Construct the drive.
                        let drive = Drive(driverFirstName: self.firstName, driverLastName: self.lastName, driverID: self.driverID, start: self.start, end: self.end, startDateTime: driveStartDateTime, endDateTime: driveEndDateTime, repeatWeekDays: self.repeatWeekDays, polyLine: self.polyLine, orRoute: nil)
                        drive.configureOptionalProperties(driveID: self.id, pickingUpHiker: self.pickingUpHiker, pickUpLocation: self.pickUpLocation, dropOffLocation: self.dropOffLocation, pickUpTime: self.pickUpTime, dropOffTime: self.dropOffTime, pickUpPolylines: self.pickUpPolyLines, hikerID: self.hikerID, hikerFirstName: self.hikerFirstName, hikerLastName: self.hikerLastName, extraTimePrice: self.extraTimePrice, canceledDates: self.canceledDates, hitchedStartDateTime: self.hitchedStartDateTime)
                        
                        driveList.append(drive)
                        
                    } else {
                        break
                    }
                }
            }
        }
        
        return driveList
    }
    
    // Time interval between start and end.
    func getTimeBetweenStartAndEnd () -> TimeInterval {
        return DateTime.timeBetween(dateTime1: startDateTime, dateTime2: endDateTime)
    }
    
    // Loads drive from json.
    class func loadFromJSON (json: [String : Any]) -> Drive? {
        
        // Load start information
        let startLat = json["start_lat"] as! CLLocationDegrees
        let startLong = json["start_long"] as! CLLocationDegrees
        let startTitle = json["start_title"] as! String
        let startSubTitle = json["start_sub_title"] as? String
        let startDateTimeString = json["start_date_time"] as! String
        
        // Load end information
        let endLat = json["end_lat"] as! CLLocationDegrees
        let endLong = json["end_long"] as! CLLocationDegrees
        let endTitle = json["end_title"] as! String
        let endSubTitle = json["end_sub_title"] as? String
        let endDateTimeString = json["end_date_time"] as! String
        
        // Load occurrence
        let repeatedWeekDays = json["repeated_week_days"] as! [Int]
        
        // Parse datetime string.
        
        let startDateTime = DateTime.loadFromJSONRep(jsonRep: startDateTimeString)
        let endDateTime = DateTime.loadFromJSONRep(jsonRep: endDateTimeString)
        
        // Build start and end place.
        let startPlace = Place(title: startTitle, subtitle: startSubTitle, coordinate: CLLocationCoordinate2D(latitude: startLat, longitude: startLong))
        let endPlace = Place(title: endTitle, subtitle: endSubTitle, coordinate: CLLocationCoordinate2D(latitude: endLat, longitude: endLong))
        
        // Load user information.
        let userID = (json["user"] as! [String:Any])["id"] as! Int
        var firstName : String
        var lastName : String
        if userID == User.getCurrentUser()?.id {
            firstName = (User.getCurrentUser()?.firstName)!
            lastName = (User.getCurrentUser()?.lastName)!
        } else {
            firstName = (json["user"]as! [String:Any])["first_name"] as! String
            lastName = (json["user"]as! [String:Any])["last_name"] as! String
        }
        
        // Load drive.
        let drive = Drive(driverFirstName: firstName, driverLastName: lastName, driverID: userID, start: startPlace, end: endPlace, startDateTime: startDateTime, endDateTime: endDateTime, repeatWeekDays: repeatedWeekDays, polyLine: nil, orRoute: nil)
        drive.configureOptionalProperties(driveID: json["id"] as? Int, pickingUpHiker: false, pickUpLocation: nil, dropOffLocation: nil, pickUpTime: nil, dropOffTime: nil, pickUpPolylines: nil, hikerID: nil, hikerFirstName: nil, hikerLastName: nil, extraTimePrice: 0.0, canceledDates: [], hitchedStartDateTime: nil)
        
        // If we have extra features, add them to drive.
        if json.index(forKey: "estimated_pick_up_date_time") != nil {
            drive.pickUpTime = DateTime.loadFromJSONRep(jsonRep: json["estimated_pick_up_date_time"] as! String)
        }
        
        if json.index(forKey: "polyline") != nil {
            let polyLineData = NSData(base64Encoded: (json["polyline"] as! String), options: NSData.Base64DecodingOptions(rawValue: UInt(0))) as! Data
            drive.polyLine = Mapping.loadPolyLineFromGEOJSON(polyLineData: polyLineData)
        }
        
        return drive
    }
    
    func getJSON () -> [String : Any] {
        
        // Encode polyline.
        let polyline = self.polyLine!.geoJSONData(usingEncoding: 1).base64EncodedString()
        
        // Construct JSON.
        var json : [String: Any] = ["user_id" :         self.driverID,
                                    "start_lat" :       self.start.coordinate!.latitude ,
                                    "start_long" :      self.start.coordinate!.longitude ,
                                    "start_title" :     self.start.title!,
                                    "start_sub_title" : self.start.subtitle == nil ? "" : self.start.subtitle!,
                                    "start_date_time" : self.startDateTime.getJSONRepresentation()]
        
        json["end_lat"] = self.end.coordinate!.latitude
        json["end_long"] = self.end.coordinate!.longitude
        json["end_title"] = self.end.title!
        json["end_sub_title"] = self.end.subtitle == nil ? "" : self.end.subtitle!
        json["end_date_time"] = self.endDateTime.getJSONRepresentation()
        json["repeated_week_days"] = self.repeatWeekDays
        json["polyline"] = polyline
        json["max_lat"] = self.polyLine!.overlayBounds.ne.latitude
        json["max_long"] = self.polyLine!.overlayBounds.ne.longitude
        json["min_lat"] = self.polyLine!.overlayBounds.sw.latitude
        json["min_long"] = self.polyLine!.overlayBounds.sw.longitude
        
        return json
    }
    
    
    
    /*
     * Core Data Methods.
     */
    
    class func loadFromCoreData (driveCore : DriveCore) -> Drive {
        
        // Fetch the driver's information.
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == '\(driveCore.driverID)'")
        
        let results : [UserCore]
        
        do {
            results = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Error fetching user: \(error)")
        }
        
        // If the results are empty then the user doesn't exist.
        if results == [] {
            fatalError("User doesn't exist: \(driveCore.driverID)")
        }
        
        // Configure Information into workeable format.
        let user = results.first!
        let start = Place(title: driveCore.startTitle, subtitle: driveCore.startSubTitle, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(driveCore.startLat), longitude: CLLocationDegrees(driveCore.startLong)))
        let end = Place(title: driveCore.endTitle, subtitle: driveCore.endSubTitle, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(driveCore.endLat), longitude: CLLocationDegrees(driveCore.endLong)))
        let repeatWeekDays = driveCore.repeatedWeekDays as! [Int]

        // Get route from GEOJSON Data.
        var polyLine : MGLPolyline!
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: driveCore.polyLine as! Data, options: .mutableContainers) as? [String: Any]
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
            fatalError("Could not parse GEOJSON: \(driveCore.id)")
        }
        
        // Save the user information into a drive object.
        let drive = Drive(driverFirstName: user.firstName!, driverLastName: user.lastName!, driverID: Int(user.id), start: start, end: end, startDateTime: DateTime(date: driveCore.startDate as! Date), endDateTime: DateTime(date: driveCore.endDate as! Date), repeatWeekDays: repeatWeekDays, polyLine: polyLine, orRoute: nil)
        drive.id = Int(driveCore.id)
        
        return drive
    }
    
    // Method which saves drive to core data.
    func saveDriveToCoreData () {
        
        // Construct DriveCore object.
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        let driveCore = NSEntityDescription.insertNewObject(forEntityName: "DriveCore", into: managedContext) as! DriveCore
        driveCore.configure(drive: self)
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Error saving to CoreData: \(error)")
        }
    }
    
    // Get user's drives.
    class func getUsersDrivesDaysFromNow (userID: Int, daysFromNow: Int) -> [Drive] {
        
        // Perform request
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveCore")
        let daysFromNow = DateTime.currentDateTime.add(years: 0, months: 0, days: daysFromNow, hours: 0, minutes: 0)
        request.predicate = NSPredicate(format: "driverID == '\(userID)' && startDate <= %@", daysFromNow.date as NSDate)
        
        // Perform request.
        let result : [DriveCore]
        do {
            result = try managedContext.fetch(request) as! [DriveCore]
        } catch {
            fatalError("Error fetching user's drives days from now: \(error)")
        }
        
        var driveList = [Drive]()
        
        for driveCore in result {
            driveList.append(loadFromCoreData(driveCore: driveCore))
        }
        
        return driveList
    }
    
    // Get all drives specifiying these conditions.
    class func getDrivesForHitch (startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, startDateTime: DateTime, endDateTime: DateTime, hitcherID: Int) -> [Drive] {
        
        // Get the max and min lat / long for the start and end coordinates.
        let hitchMaxLat = Float(max(startCoordinate.latitude, endCoordinate.latitude))
        let hitchMaxLong = Float(max(startCoordinate.longitude, endCoordinate.longitude))
        let hitchMinLat = Float(min(startCoordinate.latitude, endCoordinate.latitude))
        let hitchMinLong = Float(min(startCoordinate.longitude, endCoordinate.longitude))
        
        // Construct Predicat and perform query.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveCore")
        
        //let datePred = NSPredicate(format: "startDate <= %@", [startDateTime.date])
        let maxLatPred = NSPredicate(format: "maxLat >= \(hitchMaxLat - 1.0) && minLat <= \(hitchMaxLat + 1.0)")
        let maxLongPred = NSPredicate(format: "maxLong >= \(hitchMaxLong - 1.0) && minLong <= \(hitchMaxLong + 1.0)")
        let minLatPred = NSPredicate(format: "maxLat >= \(hitchMinLat - 1.0) && minLat <= \(hitchMinLat + 1.0)")
        let minLongPred = NSPredicate(format: "maxLong >= \(hitchMinLong - 1.0) && minLong <= \(hitchMinLong + 1.0)")
        let idPred = NSPredicate(format: "driverID != \(Int16(hitcherID))")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [maxLatPred, maxLongPred, minLatPred, minLongPred, idPred])
        
        let result : [DriveCore]
        
        do {
            result = try managedContext.fetch(request) as! [DriveCore]
        } catch {
            fatalError("Error fetching result: \(error)")
        }
        
        // Load into drive list.
        var driveResults = [Drive]()
        
        for driveCore in result {
            
            // Check if this ride makes sense as a pick up and drop off.
            let drive = Drive.loadFromCoreData(driveCore: driveCore)
            let startDistLesser = Place.distanceBetween(coordinate1: drive.start.coordinate!, coordinate2: startCoordinate)
            let startDistBigger = Place.distanceBetween(coordinate1: drive.start.coordinate!, coordinate2: endCoordinate)
            let endDistLesser = Place.distanceBetween(coordinate1: drive.end.coordinate!, coordinate2: endCoordinate)
            let endDistGreater = Place.distanceBetween(coordinate1: drive.end.coordinate!, coordinate2: startCoordinate)
            
            if startDistLesser < startDistBigger && endDistLesser < endDistGreater {
                driveResults.append(drive)
            }
        }
        
        return driveResults
    }

    class func completeHitchList (driveList: [Drive], pickUpPlace: Place, dropOffPlace: Place, resultList: [Drive], completionHandler: @escaping ([Drive]) -> Void) {
        
        if driveList.count == 0 {
            // Call the completion handler.
            completionHandler(resultList)
        } else {
            
            let drive = driveList.first!
            
            // Complete the hitch for this drive.
            Drive.completeHitch(drive: drive, pickUpPlace: pickUpPlace, dropOffPlace: dropOffPlace, completionHandler: {
                
                (drive: Drive) -> Void in
                                    
                let newResultList = resultList + [drive]
                
                // Recursively call this function to get through the list.
                Drive.completeHitchList(driveList: Array(driveList.dropFirst()), pickUpPlace: pickUpPlace, dropOffPlace: dropOffPlace, resultList: newResultList, completionHandler: completionHandler)
            })
            
        }
    }
    
    class func completeHitch (drive: Drive, pickUpPlace: Place, dropOffPlace: Place,completionHandler: @escaping (Drive) -> Void) {
        
       // Calculate each starting position.
        Drive.calculateRouteFromAToB(pointA: dropOffPlace.coordinate!, pointB: drive.end.coordinate!, endTime: drive.endDateTime.date, completionHandler: {

            (route) -> Void in
            
            // Add polyline and store times.
            drive.pickUpPolyLines.append(Mapping.MKPolylineToMGLPolyine(mkPolyline: route.polyline))
            let dropOffTime = drive.endDateTime.subtractTimeInterval(timeInteral: route.expectedTravelTime)
            
            Drive.calculateRouteFromAToB(pointA: pickUpPlace.coordinate!, pointB: dropOffPlace.coordinate!, endTime: dropOffTime.date, completionHandler: {
                    
                (route) -> Void in
                
                // Add polyline, drop off location, and time.
                drive.pickUpPolyLines.append(Mapping.MKPolylineToMGLPolyine(mkPolyline: route.polyline))
                let pickUpTime = dropOffTime.subtractTimeInterval(timeInteral: route.expectedTravelTime)
                
                Drive.calculateRouteFromAToB(pointA: drive.start.coordinate!, pointB: pickUpPlace.coordinate!,  endTime: pickUpTime.date, completionHandler: {
                        
                    (route) -> Void in
                    
                    // Add the final polyline and calculate start time.
                    drive.pickUpPolyLines.append(Mapping.MKPolylineToMGLPolyine(mkPolyline: route.polyline))
                    let startDateTime = pickUpTime.subtractTimeInterval(timeInteral: route.expectedTravelTime)
                    
                    // Complete the hitch.
                    drive.configureOptionalProperties(driveID: drive.id, pickingUpHiker: true, pickUpLocation: pickUpPlace, dropOffLocation: dropOffPlace, pickUpTime: pickUpTime, dropOffTime: dropOffTime, pickUpPolylines: drive.pickUpPolyLines, hikerID: nil, hikerFirstName: nil, hikerLastName: nil, extraTimePrice: 5.0, canceledDates: [], hitchedStartDateTime: startDateTime)
                    
                    completionHandler(drive)
                })
            })
        })
    }

    class func calculateRouteFromAToB (pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D, endTime: Date, completionHandler: @escaping (MKRoute) -> Void) {
        
        // Get request.
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pointA))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: pointB))
        request.arrivalDate = endTime
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {
            
            (response, error) -> Void in
            
            if error != nil {
                // Handle the error.
                fatalError("\(error)")
            }
            
            if response?.routes.count == 0 {
                fatalError("There is no route from here to here.")
            }
            
            // Add this route to the drives polylines.
            let route = response?.routes.first!
            
            // Recursively call the function again.
            completionHandler(route!)
        })


    }
    
    /* Calculate time duration of hitch on a drive.
    class func driveFromHitchAndDrive (pickUpCoord: CLLocationCoordinate2D, dropOffCoord: CLLocationCoordinate2D, drive: Drive) -> Drive? {
        
        // Build requests.
        let startCoord = drive.start.coordinate
        let endCoord = drive.end.coordinate
        let startToPickUp = MKDirectionsRequest()
        startToPickUp.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoord!))
        startToPickUp.destination = MKMapItem(placemark: MKPlacemark(coordinate: pickUpCoord))
        startToPickUp.transportType = .automobile
        let pickUpToDropOff = MKDirectionsRequest()
        pickUpToDropOff.source = MKMapItem(placemark: MKPlacemark(coordinate: pickUpCoord))
        pickUpToDropOff.destination = MKMapItem(placemark: MKPlacemark(coordinate: dropOffCoord))
        pickUpToDropOff.transportType = .automobile
        let dropOffToEnd = MKDirectionsRequest()
        dropOffToEnd.source = MKMapItem(placemark: MKPlacemark(coordinate: pickUpCoord))
        dropOffToEnd.destination = MKMapItem(placemark: MKPlacemark(coordinate: dropOffCoord))
        dropOffToEnd.transportType = .automobile
        
        // Perform dirctions request.
        var directions = MKDirections(request: startToPickUp)
        directions.calculate(completionHandler: {
                
            (response, error) in
            
            if error != nil {
                // Handle the error.
                fatalError("\(error)")
            }
            
            if let routeResponse = response?.routes {
                
                // Handle the response
                let route = routeResponse.first!
                
                
            }
        })
        
        
        return nil
    }*/
    
    // HELPERS
    class func calculateRoute (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        
        
    }
    
    
}


// DriveCore extension.
extension DriveCore {
    
    func configure(drive: Drive) {
        
        // Set start location.
        self.startTitle = drive.start.title
        self.startSubTitle = drive.start.subtitle
        self.startLat = Float(drive.start.coordinate!.latitude)
        self.startLong = Float(drive.start.coordinate!.longitude)
        
        // Set end location.
        self.endTitle = drive.end.title
        self.endSubTitle = drive.end.subtitle
        self.endLat = Float(drive.end.coordinate!.latitude)
        self.endLong = Float(drive.end.coordinate!.longitude)
        
        // Set times.
        self.startDate = drive.startDateTime.date as NSDate?
        self.endDate = drive.endDateTime.date as NSDate?
        self.repeatedWeekDays = drive.repeatWeekDays as NSObject?
        
        // Set polyLine.
        self.polyLine = drive.polyLine?.geoJSONData(usingEncoding: 1) as NSData?
        
        // IDs
        self.driverID = Int16(drive.driverID)
        
        // Find the max and min lat / long.
        self.maxLong = Float((drive.polyLine?.overlayBounds.ne.longitude)!)
        self.maxLat = Float((drive.polyLine?.overlayBounds.ne.latitude)!)
        self.minLong = Float((drive.polyLine?.overlayBounds.sw.longitude)!)
        self.minLat = Float((drive.polyLine?.overlayBounds.sw.latitude)!)
        
        // Get largest current route id.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveCore")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let result : [DriveCore]
        
        do {
            result = try managedContext.fetch(request) as! [DriveCore]
        } catch {
            fatalError("Could not fetch user: \(error)")
        }
        
        if result == [] {
            self.id = 1
        } else {
            let largest_id = result.first!.id
            
            // Set id to 1 plus largest.
            self.id = largest_id + 1
        }
    }
}
