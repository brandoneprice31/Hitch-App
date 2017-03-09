//
//  HikeSearchReultsVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/1/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import MapboxDirections

class HikeSearchResultsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate {
    
    // Other.
    var monthDateTime = DateTime.currentDateTime.startOfMonth()
    @IBOutlet var monthLabel: UILabel!
    var startLocation : Place!
    var endLocation : Place!
    var mapView : MGLMapView!
    var drives = [Drive]()
    var hitch : Hitch? = nil
    @IBOutlet var tableView: UITableView!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    // For debuggin?
    var route : MKRoute!
    
    // Sections for formatting the tableview.
    
    // Required section with cell identifiers.
    var requiredSection = [String]()
    
    // Search results section. ID's format: "cell-id specific-info"
    var resultsSection = [String]()
    
    // All Cells.
    var allCells : [String] = []
    
    // For temporary storage.
    var tempCells : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /* Load the drives.
        self.pauseViewWithAnimation(view: tableView, animationName: "spinner", text: "Finding rides...")
        
        let user = (UIApplication.shared.delegate as! AppDelegate).currentUser
        
        let unsortedDrives = Drive.getDrivesForHitch(startCoordinate: self.startLocation.coordinate!, endCoordinate: self.endLocation.coordinate!, startDateTime: DateTime.currentDateTime, endDateTime: DateTime.currentDateTime.add(years: 0, months: 0, days: 7, hours: 0, minutes: 0), hitcherID: user!.id)
        
        Drive.completeHitchList(driveList: unsortedDrives, pickUpPlace: startLocation, dropOffPlace: endLocation, resultList: [], completionHandler: {
            
            (drives) -> Void in
            
            self.configureDrives(drives: drives)
        
        })*/
        
        // Spin the forward arrow.
        forwardButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        // Load the drives.
        self.performDriveSearch()
    }
    
    func performDriveSearch () {
        
        // Nullify drives.
        self.drives = [Drive]()
        
        // Load correct month.
        self.monthLabel.text = monthDateTime.longMonth() + " " + String(monthDateTime.year)
        
        // Perform search query.
        self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Finding rides...")
        API.driveSearch(token: (User.getCurrentUser()?.token)!, pickUpCoordinate: self.startLocation.coordinate, dropOffCoordinate: self.endLocation.coordinate, startDateTime: monthDateTime, endDateTime: monthDateTime.endOfMonth(), completionHandler: {
            
            (response, driveList) in
            
            DispatchQueue.main.sync(){
                self.unPauseViewAndRemoveAnimation(view: self.view)
                if response == URLResponse.Error {
                    self.presentNormalAlertView(title: "Error", message: "Check your internet connection...")
                } else {
                    self.configureDrives(drives: driveList!)
                }
            }
        })
    }
    
    func configureDrives (drives: [Drive]) {
        
        // Get all the drives from these unsorted ones.
        for drive in drives {
            
            //let nDays = monthDateTime.endOfMonth().day - monthDateTime.day
            //self.drives += drive.getDrivesDaysFromNow(startDateTime: monthDateTime, nDays: nDays)
            self.drives += drive.getDriveCopies(startDateTime: monthDateTime, endDateTime: monthDateTime.endOfMonth())
        }
        
        self.drives.sort(by: {(x,y) -> Bool in return x.startDateTime.date < y.startDateTime.date })
        
        /*
         *  Setup the sections.
         */
        
        // Required cells.
        requiredSection = ["SeparatorCellWhite 8"]
        self.resultsSection = [String]()
        
        if drives.count == 0 {
            // There are no drives.  Let's let the user know.
            
            
        } else {
            
            // We received some drives.
            
            // Set up the search result section.
            var currentDateTime : DateTime? = nil
            var driveCount: Int = 0
            
            // Iterate through each drive.
            for drive in self.drives {
                
                if currentDateTime == nil {
                    
                    // Set the first datetime and append DayCell and separator cell.
                    currentDateTime = drive.startDateTime
                    self.resultsSection.append("DayCell " + currentDateTime!.abbreviatedDate() + " " + currentDateTime!.longWeekDay())
                }
                
                if drive.startDateTime.isSameDayAs(dateTime2: currentDateTime!) {
                    
                    // Still on the same date, so only append result cell and separator.
                    self.resultsSection.append("HikeTBVCell " + String(driveCount))
                    self.resultsSection.append("SeparatorCellWhite 1")
                    
                } else if drive.startDateTime.isDaysAheadOf(dateTime2: currentDateTime!) {
                    
                    // Moving on to next date so let's remove the last separator cell and add a day cell, result cell, and a separator cell.
                    currentDateTime = drive.startDateTime
                    self.resultsSection.removeLast()
                    self.resultsSection.append("SeparatorCellWhite 8")
                    self.resultsSection.append("DayCell " + currentDateTime!.abbreviatedDate() + " " + currentDateTime!.longWeekDay())
                    self.resultsSection.append("HikeTBVCell " + String(driveCount))
                    self.resultsSection.append("SeparatorCellWhite 1")
                }
                
                driveCount += 1
            }
        }
        
        // Concatenate sections.
        tempCells = requiredSection + resultsSection
        allCells = tempCells
        
        // Load cells
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

    @IBAction func backMonthButtonClicked(_ sender: Any) {
        
        let nextMonth = monthDateTime.add(years: 0, months: -1, days: 0, hours: 0, minutes: 0)
        
        if nextMonth.year < DateTime.currentDateTime.year ||  (nextMonth.year == DateTime.currentDateTime.year && nextMonth.month < DateTime.currentDateTime.month) {
            // Past month warn the user.
            self.presentNormalAlertView(title: "Invalid month", message: "This month is in the past.")
            
        } else {
            
            self.monthDateTime = nextMonth
            
            self.performDriveSearch()
        }
    }
    
    @IBAction func forwardMonthButtonClicked(_ sender: Any) {
        
        let nextMonth = monthDateTime.add(years: 0, months: 1, days: 0, hours: 0, minutes: 0)
        self.monthDateTime = nextMonth
        
        // Perform search query.
        self.performDriveSearch()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCells.count
    }
    
    // Row height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if allCells[indexPath.row] == "InstructionsCell1" {
            
            // Instructions at top.
            return 16.0

        } else if allCells[indexPath.row] == "MapCell" {
            
            // MapView.
            return 275.0
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "DayCell" {
            
            return 25.0
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "HikeTBVCell" {
            
            return 60.0
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "ExpandedHikeCellSchedule" {
            
            return 150.0
        
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "ExpandedHikeCellButton" {
            
            return 90.0
            
        } else if allCells[indexPath.row] == "SeparatorCellOrange"{
            
            return 8.0
            
        } else if allCells[indexPath.row] == "SeparatorCellNavy" {
            
            return 1.0
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "SeparatorCellWhite" {
            
            let height = Double(allCells[indexPath.row].components(separatedBy: " ")[1])
            return CGFloat(height!)
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "HikeSearchResultsPriceCell" {
            
            return 120.0
            
        } else {
        
            return 0.0
        }
    }
    
    // Cell for index path.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allCells[indexPath.row] == "InstructionsCell1" {
            // Instructions at top.
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionsCell1")
            
            return cell!
            
        } else if allCells[indexPath.row] == "MapCell"{
            // MapView.
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell")
            
            // Get the mapview.
            for view in (cell?.contentView.subviews)! {
                let cellMapView = view as? MGLMapView
                if cellMapView != nil {
                    self.mapView = cellMapView!
                    self.mapView.delegate = self
                }
            }
            
            return cell!
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "DayCell" {
            
            // Get dateString and weekday.
            let dateString = allCells[indexPath.row].components(separatedBy: " ")[1]
            let weekDay = allCells[indexPath.row].components(separatedBy: " ")[2]
            
            // Day cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! DayTBVCell
            cell.configureCell(weekDay: weekDay, date: dateString)
            
            return cell
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "HikeTBVCell" {
            
            // Search result.
            let cell = tableView.dequeueReusableCell(withIdentifier: "HikeTBVCell") as! HikeTBVCell
            
            let index = Int(allCells[indexPath.row].components(separatedBy: " ")[1])
            let drive = drives[index!]
            
            // Configure the cell.
            cell.configureCell(drive: drive)
            
            // Return the cell.
            return cell
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "ExpandedHikeCellSchedule" {
            // Expanded result schedule.
            
            // Configure cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedHikeCellSchedule") as! ExpandedHikeCellSchedule
            let index = Int(allCells[indexPath.row].components(separatedBy: " ")[1])
            let drive = drives[index!]
            cell.configure(drive: drive, hitch: self.hitch!)
            return cell
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "ExpandedHikeCellButton" {
            // Expanded result button.
            
            // Configure cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedHikeCellButton") as! ExpandedHikeCellButton
            let index = Int(allCells[indexPath.row].components(separatedBy: " ")[1])
            let drive = drives[index!]
            cell.configure(drive: drive, yesButtonMethod: #selector(hitchButtonClicked), vc: self)

            return cell
            
        } else if allCells[indexPath.row].components(separatedBy: " ")[0] == "HikeSearchResultsPriceCell" {
            
            // Configure cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "HikeSearchResultsPriceCell") as! HikeSearchResultsPriceCell
            let index = Int(allCells[indexPath.row].components(separatedBy: " ")[1])
            let drive = drives[index!]
            cell.configure(basePrice: 1.00, extraTravelPrice: 0.31)
            
            return cell
            
        } else {
            
            let cellID = allCells[indexPath.row].components(separatedBy: " ")[0]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            
            return cell!
        }
    }
    
    // Did select row at index path for table view.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure its a hike tbv cell.
        if allCells == tempCells && allCells[indexPath.row].components(separatedBy: " ")[0] == "HikeTBVCell" {
            
            let index = Int(allCells[indexPath.row].components(separatedBy: " ")[1])
            let drive = drives[index!]
            
            // Pause everything and complete the hitch / drive.
            self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Calculating pickup and drop off route...")
            Drive.completeHitch(hitchHiker: User.getCurrentUser()!, drive: drive, pickUpPlace: self.startLocation, dropOffPlace: self.endLocation, completionHandler: {
                
                (hitch) in
                
                self.unPauseViewAndRemoveAnimation(view: self.view)
                
                // Hide the forward and backward buttons.
                self.forwardButton.alpha = 0.0
                self.backButton.alpha = 0.0
                
                // Build hitch.
                self.hitch = hitch
                    
                // Begin updates.
                tableView.beginUpdates()
                    
                // Delete all rows.
                let allIndexPathsToDelete = tableView.indexPathsForRowsInSection(0)
                self.tableView.deleteRows(at: allIndexPathsToDelete, with: .left)
                    
                // Construct new allCells.
                let indexString = String(index!)
                self.allCells = ["SeparatorCellWhite 8","MapCell","SeparatorCellWhite 8","HikeSearchResultsPriceCell \(indexString)","SeparatorCellWhite 8","DayCell " + drive.startDateTime.abbreviatedDate() + " " + drive.startDateTime.longWeekDay(),"HikeTBVCell " + indexString,"SeparatorCellWhite 8","ExpandedHikeCellSchedule " + indexString,"SeparatorCellWhite 8", "ExpandedHikeCellButton " + indexString, "SeparatorCellWhite 8"]
                    
                var newRows = [IndexPath]()
                    
                // Add in new rows.
                for row in 0..<self.allCells.count {
                    newRows.append(IndexPath(row: row, section: 0))
                }
                    
                self.tableView.insertRows(at: newRows, with: .right)
                    
                // End updates.
                tableView.endUpdates()
                    
                // Update the map route.
                Mapping.DrawDriveOnMapView(mapView: self.mapView, drive: drive, hitch: hitch)
            })
        }
    }
    
    // Deselect the row and re configure cell.
    func deSelectCell () {
        
        self.forwardButton.alpha = 1.0
        self.backButton.alpha = 1.0
        
        // Remove map route.
        mapView.removeAnnotations(mapView.annotations!)
        
        self.tableView.beginUpdates()
        
        // Delete all rows.
        let allIndexPathsToDelete = tableView.indexPathsForRowsInSection(0)
        self.tableView.deleteRows(at: allIndexPathsToDelete, with: .right)
        
        // Update allCells.
        allCells = tempCells
        var newRows = [IndexPath]()
        
        // Add in new rows.
        for row in 0..<allCells.count {
            newRows.append(IndexPath(row: row, section: 0))
        }
        
        self.tableView.insertRows(at: newRows, with: .left)
        
        self.tableView.endUpdates()
    }
    
    // Hitch Button Clicked.
    func hitchButtonClicked () {
        
        self.presentOkayCancelAlertView(title: "Hitch this ride?", message: "Hitching this ride will notify the driver.  If the driver accepts, you will be charged $1.00 for this drive.", okayHandler: {
            
            (alert) -> Void in
            
            self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Hitching onto ride...")
            
            // Add repeated week days to hitch.
            let buttonCell = self.tableView.cellForRow(at: IndexPath(row: 10, section: 0)) as! ExpandedHikeCellButton
            let repeatedWeekDays = buttonCell.weekDaysView.getSelectedWeekDays()
            self.hitch?.repeatedWeekDays = repeatedWeekDays
            
            // Add hitch to drive.
            API.HitchOnToDrive(hitch: self.hitch!, completionHandler: {
                (response) in
                DispatchQueue.main.sync() {
                    // Handle response.
                    self.unPauseViewAndRemoveAnimation(view: self.view)
                    
                    if response == URLResponse.Error {
                        self.presentNormalAlertView(title: "Error", message: "Check your internet connection.")
                    } else {
                        self.gotoMainVC()
                    }
                }
            
            })
        
        }, cancelHandler: nil)
    }
    
    // Goto MainVC
    func gotoMainVC () {
        
        let mainVC = self.navigationController?.viewControllers.first as! MainVC
        mainVC.unsortedHitches.append(self.hitch!)
        mainVC.changedUnsorted = true
        let transition = Design.moveDownTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
    
    // Back button clicked.
    @IBAction func backButtonClicked(_ sender: Any) {
        
        if allCells == tempCells {
            // Simply pop the current vc.
            let transition: CATransition = Design.moveDownTransition()
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popViewController(animated: false)
        } else {
            // Deselect the cell.
            deSelectCell()
        }
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
