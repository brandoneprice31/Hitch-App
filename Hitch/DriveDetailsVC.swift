//
//  DriveDetailsVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/9/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import Mapbox

class DriveDetailsVC: UIViewController, MGLMapViewDelegate {
    
    var drive : Drive!
    
    @IBOutlet var box2: UILabel!
    @IBOutlet var startLocationButton: UIButton!
    @IBOutlet var endLocationButton: UIButton!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var weekDaysView: WeekDaysView!
    @IBOutlet var specificDateLabel: UILabel!
    @IBOutlet var createDriveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configure box.
        box2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        
        // Configure location and time labels.
        startLocationButton.setTitle(drive.start.title, for: .normal)
        endLocationButton.setTitle(drive.end.title, for: .normal)
        startLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        endLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        startTimeLabel.text = drive.startDateTime.time()
        endTimeLabel.text = drive.endDateTime.time()
        
        // Configure mapview.
        Mapping.DrawDriveOnMapView(mapView: mapView, drive: drive)
        
        // Configure Occurrence stuff.
        if drive.repeatWeekDays != [] {
            weekDaysView.alpha = 1.0
            specificDateLabel.alpha = 0.0
            let disabledDays = WeekDaysView.getDisabledDays(notDisabledDays: drive.repeatWeekDays)
            weekDaysView.configure(selectedDays: drive.repeatWeekDays, disabledDays: disabledDays, touchesAllowed: false)
        } else {
            weekDaysView.alpha = 0.0
            specificDateLabel.alpha = 1.0
            specificDateLabel.text = drive.startDateTime.fullDate()
        }
        
        // Configure createDriveButton.
        createDriveButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func timeButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = lightGreyColor
        sender.alpha = 0.5
    }
    
    @IBAction func timeButtonDragOutside(_ sender: UIButton) {
        sender.backgroundColor = .clear
    }
    
    // Change time button clicked.
    @IBAction func changedTimeButtonClicked(_ sender: UIButton) {
        
        // Make button clear again.
        sender.backgroundColor = .clear
        
        // Instantiate DCTimeVC.
        editField(field: "DCTimeVC")
    }
    
    @IBAction func occurrenceButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = lightGreyColor
        sender.alpha = 0.5
    }
    
    @IBAction func occurrenceButtonDragOutside(_ sender: UIButton) {
        sender.backgroundColor = .clear
    }

    @IBAction func occurrenceButtonClicked(_ sender: UIButton) {
        // Make button clear again.
        sender.backgroundColor = .clear
        
        // Instantiate DCTimeVC.
        editField(field: "DCOccurrenceVC")
    }
    
    
    @IBAction func startLocationButtonClicked(_ sender: Any) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        nextVC.isHiking = false
        nextVC.isDrivingDrive = self.drive
        nextVC.startLocation = self.drive.start
        nextVC.endLocation = self.drive.end
        nextVC.locationType = "Start"
        
        let transition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    @IBAction func endLocationButtonClicked(_ sender: Any) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        nextVC.isHiking = false
        nextVC.isDrivingDrive = self.drive
        nextVC.startLocation = self.drive.start
        nextVC.endLocation = self.drive.end
        nextVC.locationType = "End"
        
        let transition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    func editField (field: String) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveCreateVC") as! DriveCreateVC
        nextVC.defaultVC = field
        nextVC.endLocation = drive.end
        nextVC.startLocation = drive.start
        nextVC.repeatedWeekdays = drive.repeatWeekDays
        nextVC.endDate = drive.endDateTime.date
        nextVC.endDateTime = drive.endDateTime
        let transition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    @IBAction func createDriveButtonClicked(_ sender: Any) {
        
        // Save the drive.
        self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Saving drive...")
        API.saveUsersDrive(token: (User.getCurrentUser()?.token)!, drive: self.drive, completionHandler: {
            (response) in
            DispatchQueue.main.sync(){
                self.unPauseViewAndRemoveAnimation(view: self.view)
                
                if response == URLResponse.Error {
                    self.presentNormalAlertView(title: "Error", message: "Check your internet connection.")
                } else {
                    
                    // Get main VC.
                    let mainVC = self.navigationController?.viewControllers.first as! MainVC
                    mainVC.unsortedDrives = mainVC.unsortedDrives + [self.drive]
                    mainVC.changedUnsorted = true
                    print(self.navigationController!.viewControllers.count)
                    
                    // Transition.
                    let transition = Design.moveDownTransition()
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    _ = self.navigationController?.popViewController(animated: false)
                }
            }
        })
    }
    
    @IBAction func exitButtonClicked(_ sender: Any) {
        
        let transition = Design.moveDownTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popViewController(animated: false)
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
