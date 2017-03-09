//
//  Authentication.swift
//  Hitch
//
//  Created by Brandon Price on 1/29/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

class API {
    
    // ROOT URL
    static let rootURLString : String = "http://127.0.0.1:8000/app/"
    //static let rootURLString : String = "https://sheltered-citadel-17296.herokuapp.com/app/"
    
    
    
    /* Function for checking if a user exists already:
     * returns Success, Error
     */
    class func checkIfUserExists (email: String, completionHandler: @escaping (URLResponse, Bool) -> Void) {
        
        // Create json object.
        let json : [String : String] = ["email" : email]
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/check/", json: json, token: nil, completionHandler: {
            (response, _) in
            
            switch response.statusCode {
            case 409:
                completionHandler(URLResponse.Success, true)
            case 404:
                completionHandler(URLResponse.Success, false)
            default:
                completionHandler(URLResponse.Error, false)
            }
        })
    }
    
    
    
    /* Logs the user in and gets his info:
     * returns success, wrongcredentials
     */
    class func loginUserWithCredentials (email: String, password: String, completionHandler: @escaping (URLResponse, User?) -> Void) {
        
        // Create json.
        let json: [String: String] = ["email" : email,
                                      "password" : password]
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/login/", json: json, token: nil, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 202:
                var decodedImage : UIImage? = nil
                
                let json_user_data = json as! [String: Any]
                
                if json_user_data.keys.contains("profile_image") {
                    let decodedData = NSData(base64Encoded: json_user_data["profile_image"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))
                    
                    decodedImage = UIImage(data: decodedData! as Data)
                }
                
                print("\(json_user_data)")
                
                let user = User(id: json_user_data["id"] as! Int, firstName: (json_user_data["first_name"] as? String)!, lastName: (json_user_data["last_name"] as? String)!, email: json_user_data["email"] as! String, token: (json_user_data["token"]
                    as? String)!, profileImage: decodedImage)
                
                // Login the user.
                User.loginUser(user: user)
                completionHandler(URLResponse.Success, user)

            default:
                 completionHandler(URLResponse.WrongCredentials, nil)
            }
        })
    }
    
    
    
    /* Function that logs out the user in the data base:
     * returns success, error
     */
    class func logOutUser (token: String, completionHandler: @escaping (URLResponse) -> Void) {
        
        // Send request.
        API.performRequest(requestType: "GET", urlPath: "users/log-out/", json: nil, token: token, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 200:
                User.logOutCurrentUser()
                completionHandler(URLResponse.Success)
            default:
                completionHandler(URLResponse.Error)
            }
        })
    }
    

    
    /* Function that is supposed to create a user in the data base:
     * returns success, wrongcredentials
     */
    class func createUserWithCredentials(email: String, password: String, firstName: String, lastName: String, profileImage: UIImage?, completionHandler: @escaping (URLResponse, User?) -> Void) {
        
        // Create json object.
        var json: [String: Any] = ["email" : email,
                                   "password" : password,
                                   "first_name": firstName,
                                   "last_name" : lastName]
        
        // Send profile image data.
        if profileImage != nil {
            let imageData = UIImagePNGRepresentation(profileImage!)
            let profile_image_data = imageData?.base64EncodedString()
            json["profile_image"] = profile_image_data!
        }
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/create/", json: json, token: nil, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 201:
                // Build user object.
                var user : User? = nil
                
                if json != nil {
                    
                    let json_user_data = json as! [String: Any]
                    user = User(id: json_user_data["id"] as! Int, firstName: (json_user_data["first_name"] as? String)!, lastName: (json_user_data["last_name"] as? String)!, email: json_user_data["email"] as! String, token: (json_user_data["token"] as? String)!, profileImage: nil)
                }
                
                completionHandler(URLResponse.Success, user)
            default:
                completionHandler(URLResponse.WrongCredentials, nil)
            }
        })
    }
    
    
    
    /* Function that gets all of the user's drive objects:
     * returns Success, Error
     */
    class func getUsersDrives (token: String, completionHandler: @escaping (URLResponse, [Drive]?) -> Void) {
        
        // Perform request.
        API.performRequest(requestType: "GET", urlPath: "drives/", json: nil, token: token, completionHandler: {
            (response, jsonList) in
            
            switch response.statusCode {
            case 200:
                // Return drive objects.
                let json_drive_data = jsonList as! [[String: Any]]
                
                // Construct drive array.
                var driveList = [Drive]()
                for json in json_drive_data {
                    driveList.append(Drive.loadFromJSON(json: json))
                }
                
                // Return drive list.
                completionHandler(URLResponse.Success, driveList)
            default:
                // Return error.
                completionHandler(URLResponse.Error, nil)
            }
        })
    }
    
    
    
    /* Function that saves user's drive to back-end:
     * returns Success, Error
     */
    class func saveUsersDrive (token: String, drive: Drive, completionHandler: @escaping (URLResponse) -> Void) {
        
        let json = drive.getJSON()
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "drives/create/", json: json, token: token, completionHandler: {
            (response, _) in
            
            if response.statusCode != 201 {
                completionHandler(URLResponse.Error)
            } else {
                completionHandler(URLResponse.Success)
            }
        })
    }
    
    
    
    /* Function that pulls all of the user's hitches:
     * returns Success, Error
     */
    class func getUsersHitches(token: String, completionHandler: @escaping (URLResponse, [Hitch]?) -> Void) {
        
        // Perform request.
        API.performRequest(requestType: "GET", urlPath: "hitches/", json: nil, token: token, completionHandler: {
            (response, jsonList) in
            
            if response.statusCode != 200 {
                // Return error.
                completionHandler(URLResponse.Error, nil)
            } else {
                // Return drive objects.
                let json_hitch_data = jsonList as! [[String: Any]]
                
                // Construct drive array.
                var hitchList = [Hitch]()
                for json in json_hitch_data {
                    hitchList.append(Hitch.loadFromJSON(json: json))
                }
                
                // Return drive list.
                completionHandler(URLResponse.Success, hitchList)
            }
        })
    }
    
    
    
    
    /* Function that adds hitch to data base and send push notification to driver:
     * returns Success, Error
     */
    class func HitchOnToDrive(hitch: Hitch, completionHandler: @escaping (URLResponse) -> Void) {
        
        // Build json.
        let json : [String : Any] = hitch.getJSON()
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "hitches/create/", json: json, token: hitch.hitchHiker.token, completionHandler: {
            (response, json) in
            
            // Handle the response.
            if response.statusCode != 201 {
                completionHandler(URLResponse.Error)
            } else {
                completionHandler(URLResponse.Success)
            }
        })
    }
    
    
    
    
    /* Function search for drives that fit hitch:
     * returns success, error
     */
    class func driveSearch (token: String, pickUpCoordinate: CLLocationCoordinate2D, dropOffCoordinate: CLLocationCoordinate2D, startDateTime: DateTime, endDateTime: DateTime, completionHandler: @escaping (URLResponse, [Drive]?) -> Void) {
        
        // Build json.
        let json : [String : Any] =     ["pick_up_lat"       : pickUpCoordinate.latitude,
                                         "pick_up_long"      : pickUpCoordinate.longitude,
                                         "drop_off_lat"      : dropOffCoordinate.latitude,
                                         "drop_off_long"     : dropOffCoordinate.longitude,
                                         "start_date_time"   : startDateTime.getJSONRepresentation(),
                                         "end_date_time"     : endDateTime.getJSONRepresentation()]
        
        API.performRequest(requestType: "POST", urlPath: "drives/search/", json: json, token: token, completionHandler: {
            (response, jsonList) in
            
            if response.statusCode != 200 {
                completionHandler(URLResponse.Error, nil)
            } else {
                
                let resultList = jsonList as! [[String:Any]]
                
                var driveList = [Drive]()
                for result in resultList {
                    driveList.append(Drive.loadFromJSON(json: result))
                }
                
                completionHandler(URLResponse.Success, driveList)
            }
        })
    }
    
    
    
    // HELPERS
    class func performRequest(requestType: String, urlPath: String, json: [String: Any]?, token: String?,completionHandler: @escaping (HTTPURLResponse, Any?) -> Void) {
        
        // Make url request.
        var request = URLRequest(url: URL(string: API.rootURLString + urlPath)!)
        request.httpMethod = requestType
        
        // If jason is not nil add it to the request.
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json!)
            request.httpBody = jsonData
        }
        
        // If token is not nil, add it to the request.
        if token != nil {
            request.setValue("Token " + token!, forHTTPHeaderField: "Authorization")
        }
        
        // Perform request.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) {
            
            (data, response, error) in
            
            // Handle errors.
            if (error != nil) {
                
                fatalError("\(error)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                var jsonResponse : Any?
                
                do {
                    jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                } catch {
                    jsonResponse = nil
                }
                
                completionHandler(httpResponse, jsonResponse)
            }
        }
        task.resume()

    }
    
}

enum URLResponse {
    case Success
    case WrongCredentials
    case Error
}






class UserDefaultsAuthentication {
    
    // Save user info the database and store in defaults.
    class func saveUserInfo (email: String, cellPhone: String, password: String, firstName: String, lastName: String, birthday: Date, gender: Gender) {
        
        // Save all of the info to user defaults.
        let defaults = UserDefaults()
        defaults.set(email, forKey: "email")
        defaults.set(cellPhone, forKey: "cellPhone")
        defaults.set(password, forKey: "password")
        defaults.set(firstName, forKey: "firstName")
        defaults.set(lastName, forKey: "lastName")
        defaults.set(birthday, forKey: "birthday")
        defaults.set(gender.rawValue, forKey: "gender")
        
    }
    
    // Checks if user exists and logs them in.
    class func loginUserWithInfo (email: String, password: String) -> SessionStatus {
        
        // See if the user exists.
        let defaults = UserDefaults()
        let defaultsEmail = defaults.value(forKey: "email") as? String
        let defaultsPassword = defaults.value(forKey: "password") as? String
        if (defaultsEmail != nil && defaultsPassword != nil) && (defaultsEmail! == email && defaultsPassword! == password) {
            
            // Log the user in.
            defaults.set(SessionStatus.loggedIn.rawValue, forKey: "sessionStatus")
            return SessionStatus.loggedIn
            
        } else {
            // Return the logged out status.
            return SessionStatus.loggedOut
        }
    }
    
    // Logs the user out.
    class func logOutUser () -> SessionStatus {
        
        // Set the defaults to logged out and return the status.
        let defaults = UserDefaults()
        defaults.set(SessionStatus.loggedOut.rawValue, forKey: "sessionStatus")
        
        return SessionStatus.loggedOut
    }
    
    // Checks if the user is logged in.
    class func userIsLoggedIn () -> Bool {
        
        // Check the userDefaults to see if the user is logged in.
        let defaults = UserDefaults()
        let optionalSessionStatus = defaults.value(forKey: "sessionStatus") as? Int
        
        // If user status is not nil and logged in then return true, otherwise false.
        if optionalSessionStatus != nil {
            
            let sessionStatus: SessionStatus = SessionStatus.getStatusFromRawValue(rawValue: optionalSessionStatus!)
            
            if sessionStatus == SessionStatus.loggedOut {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    // Checks if the user already exists.
    class func userExists (email: String) -> Bool {
        
        /* Check the userDefaults to see if the user email or cellphone already exist.
        let defaults = UserDefaults()
        let defaultsEmail = defaults.value(forKey: "email") as? String*/
        
        return false
    }
    
    class func deleteUserAccount (email: String, password: String) -> Bool {
        
        let defaults = UserDefaults()
        let defaultsEmail = defaults.value(forKey: "email") as? String
        let defaultsPassword = defaults.value(forKey: "password") as? String
        
        if (defaultsEmail != nil && defaultsPassword != nil) && (defaultsEmail! == email && defaultsPassword! == password) {
            
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "cellPhone")
            defaults.removeObject(forKey: "password")
            defaults.removeObject(forKey: "firstName")
            defaults.removeObject(forKey: "lastName")
            defaults.removeObject(forKey: "birthday")
            defaults.removeObject(forKey: "gender")
            defaults.removeObject(forKey: "sessionStatus")
            
            return true
        } else {
            return false
        }
    }
    
    class func deleteCurrentUserAccount () {
        
        let defaults = UserDefaults()
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "cellPhone")
        defaults.removeObject(forKey: "password")
        defaults.removeObject(forKey: "firstName")
        defaults.removeObject(forKey: "lastName")
        defaults.removeObject(forKey: "birthday")
        defaults.removeObject(forKey: "gender")
        defaults.removeObject(forKey: "sessionStatus")
        UserDefaultsAuthentication.deleteProfPic()
    }
    
    class func deleteProfPic () {
        
        // Save image to profile_pic.png
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("profile_pic.png")
        try? FileManager.default.removeItem(at: url)
    }
}

enum Gender: Int {
    case male = 0, female
    
    static func getGenderFromRawValue(rawValue: Int) -> Gender {
        
        if rawValue == Gender.male.rawValue {
            return Gender.male
        } else {
            return Gender.female
        }
    }
}

enum SessionStatus: Int {
    case loggedIn = 0, loggedOut
    
    static func getStatusFromRawValue(rawValue: Int) -> SessionStatus {
        
        if rawValue == SessionStatus.loggedIn.rawValue {
            return SessionStatus.loggedIn
        } else {
            return SessionStatus.loggedOut
        }
    }
}

class userInfo {
    var email : String
    var cellPhone : String
    var password : String
    var firstName : String
    var lastName : String
    var birthday : Date
    var gender : Gender
    
    init (email: String, cellPhone: String, password: String, firstName: String, lastName: String, birthday: Date, gender: Gender) {
        self.email = email
        self.cellPhone = cellPhone
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.gender = gender
    }
}


class CoreDataAuthentication {
    
    static var managedContext : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    
    // Save user info the database and store in defaults.
    class func saveUserInfo (email: String, password: String, firstName: String, lastName: String, profileImage : UIImage?) {
        
        // Save user profile information.
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserCore", into: managedContext) as! UserCore
        user.configure(firstName: firstName, lastName: lastName, email: email, password: password)
        
        // Save user and handle errors.
        do {
            try managedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        // Save the users image in the following format: "userObjectID_profile_pic.png"
        if profileImage != nil {
            let png = UIImagePNGRepresentation(profileImage!)
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = path.appendingPathComponent("\(user.id)_profile_pic.png")
            
            // Save image and handle errors.
            do {
                try png?.write(to: url)
            } catch {
                fatalError("Failure to save image: \(error)")
            }
        }
    }
    
    // Checks if user exists and logs them in.
    class func loginUserWithInfo (email: String, password: String) -> SessionStatus {
        
        // See if the user email and password exist.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.predicate = NSPredicate(format: "email == '" + email + "' && password == '" + password + "'")
        request.fetchLimit = 1
        let result : [UserCore]
        
        do {
            result = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Failure to fetch user: \(error)")
        }
        
        // Log in the user.
        if result != [] {
            UserDefaults().set(Int(result.first!.id), forKey: "currentUserID")
            return SessionStatus.loggedIn
        } else {
            return SessionStatus.loggedOut
        }
    }
    
    // Logs the user out.
    class func logOutCurrentUser () {
        
        // Set the defaults to logged out and return the status.
        UserDefaults().removeObject(forKey: "currentUserID")
    }
    
    // Checks if the user is logged in.
    class func getLoggedInUser () -> Int? {
        
        // Check the userDefaults to see tif the user is logged in.
        let id = UserDefaults().object(forKey: "currentUserID") as? Int
        
        return id
    }
    
    // Checks if the user already exists.
    class func userExists (email: String) -> Bool {
        
        // Get the user.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.predicate = NSPredicate(format: "email == '" + email + "'")
        request.fetchLimit = 1
        let result : [UserCore]
        
        do {
            result = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Error fetching user: \(error.localizedDescription)")
        }
        
        // If result is empty exists then return false and vice versa.
        return result != []
        
    }
    
    class func deleteUserAccount (email: String, password: String) {
        
        // Fetch the user.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.predicate = NSPredicate(format: "email == '" + email + "' && password == '" + password + "'")
        request.fetchLimit = 1
        let result : [UserCore]
        
        do {
            result = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Error fetching user: \(error)")
        }
        
        if result == [] {
            // User doesn't exist already.
            fatalError("User doesn't exist already: \(email)")
        } else {
            // Delete the user.
            managedContext.delete(result.first!)
            
            // Delete the user's profile picture.
            deleteProfPic(objectID: Int(result.first!.id))
            
            // Save user and handle errors.
            do {
                try managedContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    class func deleteCurrentUserAccount () {
        
        // Get user id.
        let userID = UserDefaults().object(forKey: "currentUserID") as? Int
        
        if userID == nil {
            fatalError("There is no current user")
        } else {
            
            // Delete user's drives first.
            
            // Delete all drives.
            let driveRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveCore")
            driveRequest.predicate = NSPredicate(format: "driverID == '\(Int16(userID!))'")
            
            let driveResult : [DriveCore]
            
            do {
                driveResult = try managedContext.fetch(driveRequest) as! [DriveCore]
            } catch {
                fatalError("Error fetching user: \(error)")
            }
            
            // Delete every drive.
            for driveCore in driveResult {
                managedContext.delete(driveCore)
            }
            
            // Fetch user object and delete it.
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
            request.predicate = NSPredicate(format: "id == '" + String(userID!) + "'")
            request.fetchLimit = 1
            
            let result : [UserCore]
            
            do {
                result = try managedContext.fetch(request) as! [UserCore]
            } catch {
                fatalError("Error fetching user: \(error)")
            }
            
            if result == [] {
                // User doesn't exist already.
                fatalError("User doesn't exist already: \(userID)")
            } else {
                
                // Delete the user's profile picture.
                deleteProfPic(objectID: Int(result.first!.id))
                
                // Delete the user.
                managedContext.delete(result.first!)
                
                // Log out the user.
                CoreDataAuthentication.logOutCurrentUser()
                
                // Save user and handle errors.
                do {
                    try managedContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
    }
    
    class func deleteProfPic (objectID: Int) {
        
        // Delete  objectID_profile_pic.png
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("\(objectID)_profile_pic.png")
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            return
        }
    }
    
    class func deleteAllUsers () {
        
        // Fetch all user objects.
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        
        let userResult : [UserCore]
        
        do {
            userResult = try managedContext.fetch(userRequest) as! [UserCore]
        } catch {
            fatalError("Error fetching user: \(error)")
        }

        // Delete every user.
        for user in userResult {
            managedContext.delete(user)
        }
        
        // Delete all drives.
        let driveRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DriveCore")
        
        let driveResult : [DriveCore]
        
        do {
            driveResult = try managedContext.fetch(driveRequest) as! [DriveCore]
        } catch {
            fatalError("Error fetching user: \(error)")
        }
        
        // Delete every user.
        for driveCore in driveResult {
            managedContext.delete(driveCore)
        }

        
        // Save user and handle errors.
        do {
            try managedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
