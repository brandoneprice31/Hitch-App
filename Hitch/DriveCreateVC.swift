//
//  DriveCreateVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/8/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

class DriveCreateVC: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var box1: UILabel!
    @IBOutlet var box2: UILabel!
    @IBOutlet var box3: UILabel!
    @IBOutlet var box4: UILabel!
    
    var vcIndex = 0
    var startLocation : Place!
    var endLocation : Place!
    var route : MKRoute!
    var repeatedWeekdays = [Int]()
    var endDate = Date()
    var endDateTime = DateTime()
    var price = Double()
    var defaultVC = ""
    
    var directions : MKDirections!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configure buttons.
        nextButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        
        
        // Add vc's and update container view.
        if defaultVC == "" {
            
            // Configure child view controllers.
            let DCOccurrenceVC = self.storyboard?.instantiateViewController(withIdentifier: "DCOccurrenceVC") as! DCOccurrenceVC
            DCOccurrenceVC.view.frame = containerView.frame
            
            let DCTimeVC = self.storyboard?.instantiateViewController(withIdentifier: "DCTimeVC") as! DCTimeVC
            DCTimeVC.view.bounds = containerView.bounds
            
            self.addChildViewController(DCOccurrenceVC)
            self.addChildViewController(DCTimeVC)
            
        } else if defaultVC == "DCOccurrenceVC" {
            
            // Configure child view controllers.
            let DCOccurrenceVC = self.storyboard?.instantiateViewController(withIdentifier: "DCOccurrenceVC") as! DCOccurrenceVC
            DCOccurrenceVC.view.frame = containerView.frame
            
            self.addChildViewController(DCOccurrenceVC)
            
        } else {
            
            // Configure child view controllers.
            let DCTimeVC = self.storyboard?.instantiateViewController(withIdentifier: "DCTimeVC") as! DCTimeVC
            DCTimeVC.view.frame = containerView.frame
            
            self.addChildViewController(DCTimeVC)
        }
        
        self.containerView.addSubview(self.childViewControllers[vcIndex].view)
        
        // Configure Boxes.
        box4.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        configureBoxes()
    }
    
    // Colors boxes.
    func configureBoxes () {
        
        var boxList : [UILabel]
        
        if defaultVC == "" && vcIndex == 0 {
            boxList = [box3,box4]
        } else {
            boxList = [box4]
        }
        
        for box in [box1,box2,box3,box4] {
            
            if boxList.contains(box!) {
                // Unselected Boxes
                box?.backgroundColor = navyColor
                box?.layer.borderColor = orangeColor.cgColor
                box?.layer.borderWidth = 1.0
            } else {
                // Selected Boxes
                box?.backgroundColor = orangeColor
                box?.layer.borderColor = orangeColor.cgColor
                box?.layer.borderWidth = 1.0
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        
        if defaultVC == "" && vcIndex == 0 {
            // Perform transition back one navigation.
            let transition: CATransition = Design.moveDownTransition()
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popViewController(animated: false)
        } else if defaultVC == "" {
            
            // Perform transition to child.
            let oldVC = self.childViewControllers[vcIndex]
            let newVC = self.childViewControllers[vcIndex-1]
            
            let transition = Design.slidePushFromLeftTransition()
            containerView.layer.add(transition, forKey: nil)
            
            // Transition to next in line.
            self.transition(from: oldVC, to: newVC, duration: 0.3, options: .allowAnimatedContent, animations: {
                
                self.containerView.addSubview(newVC.view)
                
            }, completion: nil)
            
            vcIndex -= 1
            
            configureBoxes()
            
        } else {
            // Go back to details.
            let transition = Design.moveDownTransition()
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        
        if defaultVC == "" {
            
            if vcIndex == 0 {
                
                // Occurrence VC
                let vc = self.childViewControllers[vcIndex] as! DCOccurrenceVC
                
                if vc.segmentControl.selectedSegmentIndex == 0 {
                    // Yes
                    if vc.weekDaysView.selectedDays == [] {
                        // Yell at user for not selecting any days.
                        presentNormalAlertView(title: "Select days", message: "You did not select any recurring days.")
                    } else {
                        // Save Data and transition to next.
                        repeatedWeekdays = vc.weekDaysView.getSelectedWeekDays()
                        endDate = DateTime.currentDateTime.nextOccurrenceOf(weekDay: repeatedWeekdays.min()!).date
                        transitionToNextChild()
                    }
                    
                } else {
                    // No
                    if vc.getSelectedDate().isDaysBehindOf(dateTime2: DateTime(date: Date())) {
                        // Yell at user for selecting past date.
                        presentNormalAlertView(title: "Past date", message: "You selected a past date.")
                    } else {
                        // Save Data and transition to next.
                        repeatedWeekdays = []
                        endDate = vc.getSelectedDate().date
                        transitionToNextChild()
                    }
                }
                
            } else {
                
                // Time VC
                let vc = self.childViewControllers[vcIndex] as! DCTimeVC
                
                // Calculate the endDateTime.
                let (minute, hour) = vc.getTime()
                let dateWithoutTime = DateTime(date: endDate)
                endDateTime = DateTime(month: dateWithoutTime.month, day: dateWithoutTime.day, year: dateWithoutTime.year, hour: hour, minute: minute)
                
                if endDateTime.date <= Date() {
                    // Yell at the user for picking a date time in the past.
                    presentNormalAlertView(title: "Past day and time", message: "This day and time has already passed.")
                } else {
                    
                    createRouteAndGotoDetailsVC()
                }
                
            }
            
        
        } else {
            
            if defaultVC == "DCTimeVC" {
                
                // Time VC
                let vc = self.childViewControllers[vcIndex] as! DCTimeVC
                
                // Calculate the endDateTime.
                let (minute, hour) = vc.getTime()
                let dateWithoutTime = DateTime(date: endDate)
                endDateTime = DateTime(month: dateWithoutTime.month, day: dateWithoutTime.day, year: dateWithoutTime.year, hour: hour, minute: minute)
                
                if endDateTime.date <= Date() {
                    // Yell at the user for picking a date time in the past.
                    presentNormalAlertView(title: "Past day and time", message: "This day and time has already passed.")
                } else {
                    
                    createRouteAndGotoDetailsVC()
                }
                
            } else if defaultVC == "DCOccurrenceVC" {
                // Occurrence VC.
                let vc = self.childViewControllers[vcIndex] as! DCOccurrenceVC
                
                // Get the occurrence and date.
                if vc.segmentControl.selectedSegmentIndex == 0 {
                    // Yes
                    if vc.weekDaysView.selectedDays == [] {
                        // Yell at user for not selecting any days.
                        presentNormalAlertView(title: "Select days", message: "You did not select any recurring days.")
                    } else {
                        // Save Data and transition to next.
                        repeatedWeekdays = vc.weekDaysView.getSelectedWeekDays()
                        endDate = DateTime.currentDateTime.nextOccurrenceOf(weekDay: repeatedWeekdays.min()!).date
                        createRouteAndGotoDetailsVC()
                    }
                    
                } else {
                    // No
                    if vc.getSelectedDate().isDaysBehindOf(dateTime2: DateTime(date: Date())) {
                        // Yell at user for selecting past date.
                        presentNormalAlertView(title: "Past date", message: "You selected a past date.")
                    } else {
                        // Save Data and transition to next.
                        repeatedWeekdays = []
                        endDate = vc.getSelectedDate().date
                        createRouteAndGotoDetailsVC()
                    }
                }

            }
        }
    }
    
    // Create route.
    func createRouteAndGotoDetailsVC () {
        // Create directions request.
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation.coordinate!))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endLocation.coordinate!))
        request.arrivalDate = endDateTime.date
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        // Perform directions request.
        directions = MKDirections(request: request)
        
        self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Finding rides to hitch...")
        
        directions.calculate(completionHandler: ({
            
            (response, error) in
            
            self.unPauseViewAndRemoveAnimation(view: self.view)
            
            if error != nil {
                // Handle the error.
                print(error.debugDescription)
                return
            }
            
            if let routeResponse = response?.routes {
                // Handle the response.
                self.route = routeResponse.first
                let startDateTime = self.endDateTime.subtractTimeInterval(timeInteral: self.route.expectedTravelTime)
                
                // Get current user.
                let user = (UIApplication.shared.delegate as! AppDelegate).currentUser
                
                let drive = Drive(driverFirstName: user!.firstName, driverLastName: user!.lastName, driverID: user!.id, start: self.startLocation, end: self.endLocation, startDateTime: startDateTime, endDateTime: self.endDateTime, repeatWeekDays: self.repeatedWeekdays, polyLine: nil, orRoute: self.route)
                
                // Transition to next vc after sending the data.
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveDetailsVC") as! DriveDetailsVC
                nextVC.drive = drive
                let transition = Design.moveUpTransition()
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(nextVC, animated: false)
                
                // Pop all vc's except the main and driveDetailsVC.
                for vc in (self.navigationController?.viewControllers)! {
                    
                    let mainVC = vc as? MainVC
                    let driveDetailsVC = vc as? DriveDetailsVC
                    
                    if mainVC == nil && driveDetailsVC == nil {
                        // Pop it.
                        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.index(of: vc))!)
                    }
                }
            }
        }))
    }
    
    func transitionToNextChild () {
        
        // Perform transition to child.
        let oldVC = self.childViewControllers[vcIndex]
        let newVC = self.childViewControllers[vcIndex+1]
        
        let transition = Design.slidePushFromRightTransition()
        containerView.layer.add(transition, forKey: nil)
        
        // Transition to next in line.
        self.transition(from: oldVC, to: newVC, duration: 0.3, options: .allowAnimatedContent, animations: {
            
            self.containerView.addSubview(newVC.view)
            
        }, completion: nil)
            
        vcIndex += 1
            
        configureBoxes()
        
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
