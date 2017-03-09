//
//  User.swift
//  Hitch
//
//  Created by Brandon Price on 2/13/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class User {
    
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var id : Int = 0
    var token : String = ""
    var profileImage : UIImage? = nil
    
    init () {
        
    }
    
    init (id: Int, firstName: String, lastName: String, email: String, token: String, profileImage : UIImage?) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
        self.token = token
        self.profileImage = profileImage
    }
    
    // Cache's user information.
    class func loginUser (user: User) {
        
        // Set user to app delegate for easy access.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentUser = user
        
        // Save user info.
        let defaults = appDelegate.userDefaults
        defaults.set(user.firstName, forKey: "first_name")
        defaults.set(user.lastName, forKey: "last_name")
        defaults.set(user.email, forKey: "email")
        defaults.set(user.token, forKey: "token")
        defaults.set(user.id, forKey: "id")
        
        // Save image.
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("profile_pic.png")
        
        if user.profileImage != nil {
            let png = UIImagePNGRepresentation(user.profileImage!)
            do {
                try png?.write(to: url)
            } catch {
                fatalError("\(error)")
            }
        }
        
        defaults.synchronize()
    }
    
    // Get the current user.  nil if nobody is logged in.
    class func getCurrentUser () -> User? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.currentUser
    }
    
    // Log out current user.
    class func logOutCurrentUser () {
        
        let defaults = (UIApplication.shared.delegate as! AppDelegate).userDefaults
        
        // Remove easy access.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentUser = nil
        
        // Remove cached info.
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "last_name")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "id")
        
        // Remove image.
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("profile_pic.png")
        do {
            try FileManager.default.removeItem(atPath: url.path)
        } catch {
            print("no profile")
        }
        
        defaults.synchronize()
        
    }
    
    // Check if user is logged in.
    class func downloadUserFromCache () -> User? {
        
        let defaults = (UIApplication.shared.delegate as! AppDelegate).userDefaults
        
        if defaults.object(forKey: "token") == nil {
            return nil
        }
        
        // Get user information.
        let id = defaults.value(forKey: "id") as! Int
        let firstName = defaults.value(forKey: "first_name") as! String
        let lastName = defaults.value(forKey: "last_name") as! String
        let email = defaults.value(forKey: "email") as! String
        let token = defaults.value(forKey: "token") as! String
        
        // Get user profile image.
        var image : UIImage? = nil
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("profile_pic.png")
        if FileManager.default.fileExists(atPath: url.path) {
            image = UIImage(contentsOfFile: url.path)
        }
        
        let user = User(id:  id, firstName: firstName, lastName: lastName, email: email, token: token, profileImage: image)
        
        return user
    }

    func getProfileImage () -> UIImage {
        
        if profileImage == nil {
            return UIImage(named: "default-profile")!
        }
        return profileImage!
    }
    
    class func loadFromJSON (json : [String : Any]) -> User {
        
        // Parse JSON
        let first_name = json["first_name"] as! String
        let last_name = json["last_name"] as! String
        var id = 0
        var email = ""
        var token = ""
        var profileImage = UIImage(named: "default-profile")
        
        if json.index(forKey: "id") != nil {
            id = json["id"] as! Int
        }
        
        if json.index(forKey: "email") != nil {
            email = json["email"] as! String
        }
        
        if json.index(forKey: "token") != nil {
            token = json["token"] as! String
        }
        
        if json.index(forKey: "profile_image") != nil {
            let profile_image_data = json["profile_image"] as! String
            profileImage = UIImage(data: Data(base64Encoded: profile_image_data)!)
        }
        
        // Build and return user object.
        return User(id: id, firstName: first_name, lastName: last_name, email: email, token: token, profileImage: profileImage)
    }

    
    // CORE DATA METHODS
    
    /*
    class func loadFromCoreData (userCore : UserCore) -> User {
        
        return User(id: Int(userCore.id), firstName: userCore.firstName!, lastName: userCore.lastName!, email: userCore.email!, password: userCore.password!)
    }
    
    class func getCurrentUser () -> User {
        
        // Get loggedin userID.
        let userID = CoreDataAuthentication.getLoggedInUser()
        
        // Get managedContext so we can load the user's name and whatnot.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.newBackgroundContext()
        
        // Fetch the user.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == '\(Int16(userID!))'")
        
        let results : [UserCore]
        do {
            results = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Could not fetch user info: \(error)")
        }
        
        if results == [] {
            fatalError("There is no user information for: \(userID)")
        }
        
        let userCore: UserCore = results.first!
        
        return User.loadFromCoreData(userCore: userCore)
    }*/
}

// Class for storing user's information.
extension UserCore {
    
    /*
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var password: String
    @NSManaged var id: Int16*/
    
    // Configuration method called for setting properties.
    func configure (firstName: String, lastName: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        
        // Get the largest id already in the data base.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCore")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let result : [UserCore]
        
        do {
            result = try managedContext.fetch(request) as! [UserCore]
        } catch {
            fatalError("Could not fetch user: \(error)")
        }
        
        if result == [] {
            // If there are no current ID's then set to 1.
            self.id = 1
        } else {
            let largest_id = result.first!.id
            
            // Set id to 1 plus largest.
            self.id = largest_id + 1
        }
    }
}
