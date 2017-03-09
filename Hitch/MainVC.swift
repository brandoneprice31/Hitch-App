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
    var drives = [Drive]()
    var hitches = [Drive]()
    var cities = [String]()
    var allCells = [String]()
    
    // Number of days ahead.
    let daysAhead = 7
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Format ProfileImageButton.
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2.0
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.borderWidth = 0
        profileImageButton.setImage(User.getCurrentUser()?.getProfileImage(), for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        
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
        
        if changedUnsorted {
            loadAllCellFromUnsortedLists()
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
    
    func loadAllCellFromUnsortedLists () {
        
        allCells = [String]()
        drives = [Drive]()
        hitches = [Drive]()
        cities = [String]()
        
        // Go through each drive and push it into drives.
        for drive in self.unsortedDrives {
            
            // Print the drives you fetched for debugging.
            print("")
            print("\(drive.start.title) -> \(drive.end.title) | \(drive.startDateTime.time()) -> \(drive.endDateTime.time()) | repeating: \(drive.getLongRepeatedWeekDays()) starting \(drive.startDateTime.abbreviatedDate())")
            print("")
            
            // Append upcoming drives.
            //let upComingDrivesFromDrive = drive.getDrivesDaysFromNow(startDateTime: DateTime.currentDateTime, nDays: daysAhead)
            let upComingDrivesFromDrive = drive.getDriveCopies(startDateTime: DateTime.currentDateTime, endDateTime: DateTime.currentDateTime.add(years: 0, months: 0, days: 10, hours: 0, minutes: 0))
            drives += upComingDrivesFromDrive
        }
        
        // Sort drives.
        drives.sort(by: {(x: Drive, y: Drive) -> Bool in return (x.startDateTime.date < y.startDateTime.date)})
        
        
        /* CONSTRUCT HITCHES.
        for hitch in self.unsortedHitches {
            self.hitches.append(hitch.getDrive()!)
        }*/
        
        
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
        
        if unsortedHitches.count != 0 {
            
            allCells.append("PendingHeader 45")
            
            for hitchIndex in Array(0..<self.unsortedHitches.count) {
                
                //let hitch = self.hitches[hitchIndex]
                
                allCells.append("HitchCell \(hitchIndex)")
                allCells.append("SeparatorWhite 8")
            }
        }
        
        if drives.count != 0 {
            
            // Make first thing header and day cell.
            allCells.removeLast()
            allCells.append("DriveCellHeader 45")
            allCells.append("DayCell " + (drives.first?.startDateTime.longWeekDay())! + " " + drives.first!.startDateTime.abbreviatedDate())
            
            var currentDateTime = drives.first!.startDateTime
            
            // Go through each drive.
            for driveIndex in Array(0..<drives.count) {
                
                let drive = drives[driveIndex]
                
                if drive.startDateTime.isDaysAheadOf(dateTime2: currentDateTime) {
                    // Append new daycell.
                    currentDateTime = drive.startDateTime
                    allCells.append("SeparatorWhite 8")
                    allCells.append("DayCell " + (drive.startDateTime.longWeekDay()) + " " + drive.startDateTime.abbreviatedDate())
                    allCells.append("DriveCell \(driveIndex)")
                    allCells.append("SeparatorWhite 2")
                    
                } else {
                    // Append new drive cell.
                    allCells.append("DriveCell \(driveIndex)")
                    allCells.append("SeparatorWhite 2")
                }
            }
            
            // Append a spacer at the bottom.
            allCells.append("SeparatorWhite 8")
        }
        
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
            
        } else if cellType == "MainVCDriveCell" {
            // Drive Cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType) as! MainVCDriveCell
            let driveIndex = Int(cellComponents[1])
            cell.configure(drive: drives[driveIndex!])
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
    
    // Settings Button clicked.
    @IBAction func settingsButtonClicked(_ sender: Any) {
        
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
        
        let transition: CATransition = Design.slidePushFromRightTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(settingsVC!, animated: false)
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
