//
//  AppDelegate.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import CoreLocation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var currentUser : User? = nil
    var window: UIWindow?
    let locMan: CLLocationManager = CLLocationManager()
    let userDefaults = UserDefaults()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        /*
        // Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)*/
        
        // Location manager.
        locMan.delegate = self
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.distanceFilter = 1
        locMan.requestWhenInUseAuthorization()
        locMan.startUpdatingLocation()
        
        // Get the window.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController : UIViewController
        
        // Delete user for debugging purposes.
        //Authentication.deleteCurrentUserAccount()
        //self.deleteProfPic()
        
        // Delete all users for debugging purposes.
        //CoreDataAuthentication.deleteAllUsers()
        
        // Log the user out for debugging purposes.
        User.logOutCurrentUser()
        
        // Delete all cached data for debugging purposes.
        //UserDefaults().removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        // See if the user is logged in and then direct them to the correct nav.
        let currentUser = User.downloadUserFromCache()
        if currentUser != nil {
            User.loginUser(user: currentUser!)
            initialViewController = storyboard.instantiateViewController(withIdentifier: "MainNav")
        } else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "SignUpNav")
        }
        
        // Debugging purposes
        //initialViewController = storyboard.instantiateViewController(withIdentifier: "DriveCreateVC")
        
        /*
        // Get the initial view controller.
        let token = FBSDKAccessToken.current()
        
        if token != nil {
            // User is logged in, do work such as go to next view controller.
            
            // Get the correct vc.
            initialViewController = storyboard.instantiateViewController(withIdentifier: "mainContainer")
            
        } else {
            // Display the authenticate storyboard.
            
            // Get the correct storyboard / vc.
            initialViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
        }*/
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "HitchCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

