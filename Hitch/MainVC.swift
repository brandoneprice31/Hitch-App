//
//  MainVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/29/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Unsorted Drives.
    var unsortedDrives = [Drive]()
    var unsortedHitches =  [Hitch]()
    var changedUnsorted : Bool = false
    
    // For TableView Construction.
    var pendingDrives = [Drive]()
    var pendingHitches = [Hitch]()
    var drives = [Drive]()
    var hitches = [Hitch]()
    var cities = [String]()
    var allCells = [String]()
    
    // Number of days ahead.
    let daysAhead = 7
    
    @IBOutlet var instructionsView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Format ProfileImageButton.
        loadProfile()
        instructionsView.alpha = 1.0
        
        /* Print userinfo.
        let defaults = UserDefaults()
        let firstName = defaults.string(forKey: "firstName")
        let lastName = defaults.string(forKey: "lastName")
        let birthday = defaults.value(forKey: "birthday") as! Date
        let gender = Gender.getGenderFromRawValue(rawValue: defaults.value(forKey: "gender") as! Int)
        
        print(firstName)
        print(lastName)
        print(birthday)
        print(gender)*/
        
        /*
         * TABLEVIEW CONSTRUCTION
         */
        
        // CONSTRUCT DRIVES
        
        // Start with the user's upcoming drives.
        //unsortedDrives = Drive.getUsersDrivesDaysFromNow(userID: CoreDataAuthentication.getLoggedInUser()!, daysFromNow: daysAhead)
        
        self.pullDrivesAndHitches()
    }
    
    func pullDrivesAndHitches () {
        self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Loading drives and hitches...")
        API.getUsersDrives(token: User.getCurrentUser()!.token, completionHandler: {
            (response, driveList) in
            
            if response == URLResponse.Error {
                
                DispatchQueue.main.sync() {
                    self.unPauseViewAndRemoveAnimation(view: self.view)
                    self.presentNormalAlertView(title: "Error", message: "Are you connected to the internet?")
                }
                
            } else {
                API.getUsersHitches(token: User.getCurrentUser()!.token, completionHandler: {
                    (response, hitchList) in
                    
                    DispatchQueue.main.sync() {
                        self.unPauseViewAndRemoveAnimation(view: self.view)
                        
                        if response == URLResponse.Error {
                            self.presentNormalAlertView(title: "Error", message: "Are you connected to the internet?")
                        } else {
                            self.unsortedDrives = driveList!
                            self.unsortedHitches = hitchList!
                            self.loadAllCellFromUnsortedLists()
                        }
                    }
                })
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Reload profile image.
        loadProfile()
        
        if changedUnsorted {
            pullDrivesAndHitches()
            changedUnsorted = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadProfile () {
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2.0
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.borderWidth = 0
        profileImageButton.setImage(User.getCurrentUser()?.getProfileImage(), for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
    }
    
    func loadAllCellFromUnsortedLists () {
        
        allCells = [String]()
        drives = [Drive]()
        hitches = [Hitch]()
        cities = [String]()
        
        // Go through each drive and push it into drives.
        for drive in self.unsortedDrives {
            
            // Find the drives who have hitches that are pending.
            for hitch in drive.hitches {
                
                if !hitch.accepted {
                    // If it hasn't been accepted yet, then we need to add this drive to the pending array.
                    let driveCopy = drive.copy()
                    driveCopy.hitches = [hitch]
                    pendingDrives.append(driveCopy)
                }
            }
            
            // Append upcoming drives.
            let upComingDrivesFromDrive = drive.getDriveCopies(startDateTime: DateTime.currentDateTime, endDateTime: DateTime.currentDateTime.add(years: 0, months: 0, days: 10, hours: 0, minutes: 0))
            drives += upComingDrivesFromDrive
        }
        
        
        // CONSTRUCT HITCHES.
        for hitch in self.unsortedHitches {
            
            if !hitch.accepted {
                // Get all pending.
                pendingHitches.append(hitch)
            } else {
                // Get all upcoming hitches.
                hitches.append(hitch)
            }
        }
        
        // Sort these.
        var drivesAndHitches = [AnyObject]()
        drivesAndHitches = drivesAndHitches + drives
        drivesAndHitches = drivesAndHitches + hitches
        drivesAndHitches.sort(by:
            {(x,y) -> Bool in
                
                var xDate : Date
                var yDate : Date
                
                if x as? Drive != nil {
                    xDate = (x as! Drive).startDateTime.date
                } else {
                    xDate = (x as! Hitch).pickUpDateTime.date
                }
                
                if y as? Drive != nil {
                    yDate = (y as! Drive).startDateTime.date
                } else {
                    yDate = (y as! Hitch).pickUpDateTime.date
                }
                
                return xDate < yDate
        })
        
        // CONSTRUCT CITIES.
        cities = ["Boston","New-York-City"].map({x -> String in return (x + " city-image")})
        
        
        
        
        
        // CONSTRUCT ALL CELLS.
        
        if cities.count != 0 {
            
            // Make first thing header.
            allCells.append("CityCellHeader 45")
            
            for city in cities {
                
                allCells.append("CityCell \(city)")
                allCells.append("SeparatorWhite 8")
            }
        }
        
        // PENDING DRIVES AND HITCHES
        if pendingDrives.count != 0 || pendingHitches.count != 0  {
            
            allCells.append("PendingHeader 45")
            
            for driveIndex in Array(0..<pendingDrives.count) {
                
                allCells.append("HitchedDriveCell \(driveIndex) pending")
                allCells.append("SeparatorWhite 8")
            }
            
            for hitchIndex in Array(0..<pendingHitches.count) {
                
                allCells.append("HitchCell \(hitchIndex) pending")
                allCells.append("SeparatorWhite 8")
            }
        }
        
        // UPCOMING DRIVES AND HITCHES
        if drivesAndHitches.count != 0 {
            
            allCells.append("DriveCellHeader 45")
            var currentDateTime = DateTime.currentDateTime.add(years: 0, months: 0, days: -1, hours: 0, minutes: 0)

            
            // Go through each drive.
            for i in Array(0..<drivesAndHitches.count) {
                
                let driveOrHitch = drivesAndHitches[i]
                var drive : Drive? = nil
                var hitch : Hitch? = nil
                if driveOrHitch as? Drive != nil {
                    drive = driveOrHitch as? Drive
                } else {
                    hitch = driveOrHitch as? Hitch
                }
                
                if (drive != nil && drive!.startDateTime.isDaysAheadOf(dateTime2: currentDateTime)) || (hitch != nil && hitch!.pickUpDateTime.isDaysAheadOf(dateTime2: currentDateTime)) {
                    
                    // Append new daycell.
                    currentDateTime = drive == nil ? hitch!.pickUpDateTime : drive!.startDateTime
                    allCells.append("SeparatorWhite 8")
                    allCells.append("DayCell " + (currentDateTime.longWeekDay()) + " " + currentDateTime.abbreviatedDate())
                    
                    if drive != nil {
                        let index = drives.index(where: {(x) -> Bool in return x.startDateTime.date == drive!.startDateTime.date})
                        allCells.append("DriveCell \(index!) notPending")
                    } else {
                        let index = hitches.index(where: {(x) -> Bool in return x.pickUpDateTime.date == hitch!.pickUpDateTime.date})
                        allCells.append("HitchCell \(index!) notPending")
                    }
                    
                    allCells.append("SeparatorWhite 2")
                        
                } else {
                    // Append new drive cell.
                    allCells.append("DriveCell \(i) notPending")
                    allCells.append("SeparatorWhite 2")
                }
            }
        }
        if allCells.count > 0 {
            // We were able to load shit.
            allCells.removeLast()
        } else {
            // Not able to load anything.
        }
        
        allCells.append("SeparatorClear 180")
        
        self.tableView.beginUpdates()
        
        // Delete all rows.
        let allIndexPathsToDelete = tableView.indexPathsForRowsInSection(0)
        self.tableView.deleteRows(at: allIndexPathsToDelete, with: .automatic)
    
        var newRows = [IndexPath]()
        
        // Add in new rows.
        for row in 0..<allCells.count {
            newRows.append(IndexPath(row: row, section: 0))
        }
        
        self.tableView.insertRows(at: newRows, with: .top)
        
        self.tableView.endUpdates()

    }
    

    @IBAction func hikeButtonClicked(_ sender: UIButton) {
        
        // Get the location search vc.
        let locationSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        locationSearchVC.locationType = "Start"
        locationSearchVC.nextVC = "End"
        locationSearchVC.isHiking = true
        
        // Create custom transition style.
        let transition: CATransition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(locationSearchVC, animated: false)
    }
    
    @IBAction func driveButtonClicked(_ sender: UIButton) {
        
        // Get the location search vc.
        let locationSearchVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        locationSearchVC.locationType = "Start"
        locationSearchVC.nextVC = "End"
        locationSearchVC.isHiking = false
        
        // Create custom transition style.
        let transition: CATransition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(locationSearchVC, animated: false)
    }
    
    // Number of sections in table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCells.count
    }
    
    // Cell Height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cellComponents = allCells[indexPath.row].components(separatedBy: " ")
        let cellType = "MainVC" + cellComponents[0]
        
        if cellType == "MainVCDriveCellHeader" {
            // Drive Header.
            return 45.0
            
        } else if cellType == "MainVCDayCell" {
            // Day Cell.
            return 25.0
            
        } else if cellType == "MainVCHitchCell" {
            // Hitch Cell
            return 148.0
            
        } else if cellType == "MainVCDriveCell" {
            // Drive Cell.
            return 148.0
            
        } else if cellType == "MainVCHitchedDriveCell"{
            // Hitched Drive cell.
            return 224.0
            
        } else if cellType == "MainVCCityHeader" {
            // City Header.
            return 45.0
            
        } else if cellType == "MainVCCityCell" {
            // City Cell.
            return 150.0
            
        } else {
            // Separator Cell.
            return CGFloat(Float(cellComponents[1])!)
        }
    }
    
    // Cell for row index.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellComponents = allCells[indexPath.row].components(separatedBy: " ")
        let cellType = "MainVC" + cellComponents[0]
        
        if cellType == "MainVCDayCell" {
            // Day Cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCDayCell
            let weekDay = cellComponents[1]
            let date = cellComponents[2]
            cell.configure(weekDay: weekDay, date: date)
            return cell
            
        } else if cellType == "MainVCHitchCell" {
            // Hitch Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCHitchCell
            let hitchIndex = Int(cellComponents[1])
            cell.configure(hitch: self.unsortedHitches[hitchIndex!])
            return cell
            
        }  else if cellType == "MainVCHitchedDriveCell"{
            // Hitched Drive Cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCHitchedDriveCell
            let driveIndex = Int(cellComponents[1])
            let pending = cellComponents[2] == "pending"
            if pending {
                cell.configure(drive: self.pendingDrives[driveIndex!], hitch: self.pendingDrives[driveIndex!].hitches[0])
            } else {
                cell.configure(drive: self.drives[driveIndex!], hitch: self.drives[driveIndex!].hitches[0])
            }
           
            return cell
            
        } else if cellType == "MainVCDriveCell" {
            // Drive Cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCDriveCell
            let driveIndex = Int(cellComponents[1])
            let drive = drives[driveIndex!]
            
            var hitch : Hitch? = nil
            
            // See if we've been hitched.
            if drive.hitches.count != 0 {
                if drive.hitches[0].accepted {
                    hitch = drive.hitches[0]
                }
            }
            
            // Configure and return cell.
            cell.configure(drive: drives[driveIndex!], hitch: hitch)
            return cell
            
        } else if cellType == "MainVCCityCell" {
            // City Cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCCityCell
            cell.configure(cityImageName: cellComponents[1] + " " + cellComponents[2])
            return cell
            
        } else {
            // Separator Cell or Header cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType)
            return cell!
        }
    }
    
    // Did select row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellComponents = allCells[indexPath.row].components(separatedBy: " ")
        let cellType = cellComponents[0]
        
        if cellType == "HitchCell" {
            
            let hitchIndex = Int(cellComponents[1])!
            
            let pending = cellComponents[2] == "pending"
            
            if pending {
                let hitch = self.pendingHitches[hitchIndex]
                
                // Goto drive hitch info vc.
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveHitchInfoVC") as! DriveHitchInfoVC
                nextVC.drive = hitch.drive
                nextVC.hitch = hitch
                let transition = Design.slidePushFromRightTransition()
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
            
            
        } else if cellType == "HitchedDriveCell" {
            
            let driveIndex = Int(cellComponents[1])!
            let pending = cellComponents[2] == "pending"
            
            if pending {
                
                let drive = self.pendingDrives[driveIndex]
                
                // Goto drive hitch info vc.
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveHitchInfoVC") as! DriveHitchInfoVC
                nextVC.drive = drive
                let transition = Design.slidePushFromRightTransition()
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(nextVC, animated: false)
                
            }
        }
    }
    
    
    
    // Settings Button clicked.
    @IBAction func settingsButtonClicked(_ sender: Any) {
        
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
        
        let transition: CATransition = Design.slidePushFromRightTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(settingsVC!, animated: false)
    }

    // Goto Profile VC.
    @IBAction func profileButtonClicked(_ sender: Any) {
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.user = User.getCurrentUser()!
        profileVC.hitches = self.unsortedHitches
        profileVC.drives = self.unsortedDrives
        
        let transition: CATransition = Design.slidePushFromLeftTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(profileVC, animated: false)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
