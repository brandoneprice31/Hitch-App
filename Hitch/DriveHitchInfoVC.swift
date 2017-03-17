//
//  DriveHitchInfoVC.swift
//  Hitch
//
//  Created by Brandon Price on 3/16/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class DriveHitchInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var drive : Drive!
    var hitch : Hitch? = nil
    var allCells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // Configure table view.
    func configureTableView () {
        
        allCells = [String]()
        allCells.append("SeparatorCell 8")
        allCells.append("MapCell")
        allCells.append("SeparatorCell 8")
        
        if hitch == nil {
            
            // Configure drive.
            allCells.append("TitleCell Drive_Information")
            allCells.append("OccurrenceCell")
            allCells.append("NormalInformationCell")

        } else {
            
            // Configure hitch.
            allCells.append("TitleCell Hitch_Information")
            allCells.append("OccurrenceCell")
            
            if hitch!.accepted {
                // Configure hitched drive cell.
                allCells.append("HitchedDriveInformationCell N/A")
                
            } else {
                // Configure hitch.
                allCells.append("NormalInformationCell")
            }
            
            allCells.append("TitleCell Pricing")
            allCells.append("PriceCell")
            
        }
        
        allCells.append("SeparatorCell 8")
        
        if hitch == nil && drive.hitches.count > 0 {
            // Configure drive.
            allCells.append("TitleCell Hitchhikers")
            
            for hitchIndex in Array(0..<drive.hitches.count) {
                allCells.append("HitchhikerCell \(hitchIndex)")
                
                if !drive.hitches[hitchIndex].accepted {
                    allCells.append("MapCell \(hitchIndex)")
                    allCells.append("OccurrenceCell \(hitchIndex)")
                    allCells.append("HitchedDriveInformationCell \(hitchIndex)")
                    allCells.append("AcceptDeclineCell \(hitchIndex)")
                }
                allCells.append("SeparatorCell 8")
            }
            
        }
        
        allCells.append("SeparatorCell 25.0")
    }
    
    
    // Number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCells.count
    }
    
    // Height for row.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cellComponents = allCells[indexPath.row].components(separatedBy: " ")
        let cellType = cellComponents[0]
        
        if cellType == "MapCell" {
            
            if cellComponents.count > 1 {
                return 180.0
            }
            
            return 260.0
            
        } else if cellType == "OccurrenceCell" {
            return 55.0
            
        } else if cellType == "NormalInformationCell" {
            return 75.0
            
        } else if cellType == "HitchedDriveInformationCell" {
            return 150.0
            
        } else if cellType == "PriceCell" {
            return 120.0
            
        } else if cellType == "HitchhikerCell" {
            return 94.0
            
        } else if cellType == "TitleCell" {
            return 40.0
            
        } else if cellType == "AcceptDeclineCell" {
            return 60.0
            
        } else {
            
            // SeparatorCell
            let height = Float(cellComponents[1])!
            return CGFloat(height)
        }
    }
    
    // Cell for row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellComponents = allCells[indexPath.row].components(separatedBy: " ")
        let cellType = cellComponents[0]
        
        if cellType == "MapCell" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! DHI_MapCell
            
            if cellComponents.count > 1 {
                let index = Int(cellComponents[1])!
                let hitch = drive.hitches[index]
                cell.configure(drive: drive, hitch: hitch)
            } else {
                cell.configure(drive: drive, hitch: hitch)
            }
            
            return cell
            
        } else if cellType == "OccurrenceCell" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OccurrenceCell") as! DHI_OccurrenceCell
            cell.configure(repeatedWeekdays: drive.repeatedWeekDays, adHocDateTime: drive.startDateTime)
            
            return cell
            
        } else if cellType == "NormalInformationCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInformationCell") as! DHI_NormalInformationCell
            
            if hitch == nil {
                
                // Configure drive.
                cell.configure(startPlace: drive.start, startDateTime: drive.startDateTime, endPlace: drive.end, endDateTime: drive.endDateTime)
                
            } else {
                
                // Configure hitch.
                cell.configure(startPlace: hitch!.pickUpPlace, startDateTime: hitch!.pickUpDateTime, endPlace: hitch!.dropOffPlace, endDateTime: hitch!.dropOffDateTime)
            }
            
            return cell
            
        } else if cellType == "HitchedDriveInformationCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HitchedDriveInformationCell") as! DHI_HitchedDriveInformationCell
            
            if hitch == nil {
                // Configure drive.
                let index = Int(cellComponents[1])
                let hitch = drive.hitches[index!]
                cell.configure(startPlace: drive.start, startDateTime: hitch.adjustedStartDateTime, pickUpPlace: hitch.pickUpPlace, pickUpDateTime: hitch.pickUpDateTime, dropOffPlace: hitch.dropOffPlace, dropOffDateTime: hitch.dropOffDateTime, endPlace: drive.end, endDateTime: drive.endDateTime)
            
            } else {
                // Configure hitch.
                cell.configure(startPlace: drive.start, startDateTime: hitch!.adjustedStartDateTime, pickUpPlace: hitch!.pickUpPlace, pickUpDateTime: hitch!.pickUpDateTime, dropOffPlace: hitch!.dropOffPlace, dropOffDateTime: hitch!.dropOffDateTime, endPlace: drive.end, endDateTime: drive.endDateTime)
            }
            
            return cell
            
        } else if cellType == "PriceCell" {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceCell")!
            return cell
            
        } else if cellType == "HitchhikerCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HitchhikerCell") as! DHI_HitchhikerCell
            
            // Configure hitchhiker cell with the appropriate hitch.
            let hitchIndex = Int(cellComponents[1])!
            cell.configure(hitchHiker: drive.hitches[hitchIndex].hitchHiker)
            
            return cell
            
        } else if cellType == "TitleCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! DHI_TitleCell
            
            let title = cellComponents[1].replacingOccurrences(of: "_", with: " ")
            cell.configure(title: title)
            
            return cell
            
        } else if cellType == "AcceptDeclineCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptDeclineCell") as! DHI_AcceptDeclineCell
            
            let index = Int(cellComponents[1])!
            cell.configure(hitchIndex: index, vc: self)
            
            return cell
            
        } else {
            
            // SeparatorCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell")!
            return cell
        }
    }
    
    // Hitch accepted.
    func hitchAccepted (hitchIndex : Int) {
        
        // First warn the user.
        self.presentOkayCancelAlertView(title: "Are you sure?", message: "",
            okayHandler: {
                (alert) in
                
                // Perform API request to hitch on.
                self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Hitching onto drive...")
                API.acceptHitch(token: User.getCurrentUser()!.token, hitch: self.drive.hitches[hitchIndex], drive: self.drive, completionHandler: {
                    (response) in
                    
                    // Handle the response.
                    
                    DispatchQueue.main.sync () {
                        self.unPauseViewAndRemoveAnimation(view: self.view)
                        if response == URLResponse.Error {
                            // Error.
                            self.presentNormalAlertView(title: "Error", message: "Check your internet connection?")
                        } else {
                            // Success
                            self.gotoMainNav(changed: true)
                        }
                    }
                })
            }
            
            , cancelHandler: nil)
        
        
    }
    
    // Hitch declined.
    func hitchDeclined (hitchIndex : Int) {
        print(hitchIndex)
    }
    
    // Go to main nav.
    func gotoMainNav (changed: Bool) {
        
        if changed {
            let mainIndex = (self.navigationController?.viewControllers.index(of: self))! - 1
            let main = self.navigationController?.viewControllers[mainIndex] as! MainVC
            main.changedUnsorted = true
        }
        
        let transition = Design.slidePushFromLeftTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Back button clicked.
    @IBAction func backButtonClicked(_ sender: Any) {
        gotoMainNav(changed: false)
    }

}
