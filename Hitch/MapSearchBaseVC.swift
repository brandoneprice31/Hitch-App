//
//  MapSearchBase.swift
//  Hitch
//
//  Created by Brandon Price on 1/17/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapSearchBaseVC : UIViewController {
    
    // Properties.
    let mainSB : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var annotations : [MKAnnotation?] = [nil, nil]
    var start : MKMapItem? = nil
    var end : MKMapItem? = nil
    var directions : MKDirections!
    var currentMKRoute : MKRoute? = nil
    let locMan: CLLocationManager = AppDelegate().locMan
    let requestAlternateRoutes = false
    weak var mapView : MKMapView!
    
    
    /*
     * Viewcontroller methods
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we have the users location.
        if locMan.location != nil {
            
            // Get users current region.
            let currentRegion : MKCoordinateRegion = MKCoordinateRegion(center: (locMan.location!).coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0))
            
            // Set the mapview.
            self.mapView.setRegion(currentRegion, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     * Map view / location methods.
     */
    
    
    // Puts a pin down at a specified coordinate.
    func putPinAtLocation (location : MKMapItem, isStart: Bool) {
        
        let annotation : CustomAnnotation
        
        // Get title and annotation.
        if isStart {
            self.start = location
            annotation = CustomAnnotation(location: location, locationType: LocationType.start)
        } else {
            self.end = location
            annotation = CustomAnnotation(location: location, locationType: LocationType.end)
        }
        
        // Let's put a pin down baby.
        self.mapView.addAnnotation(annotation)
        
        // Sort the annotation.
        if isStart {
            
            // If the current one exists then remove her.
            if self.annotations[0] != nil {
                self.mapView.removeAnnotation(self.annotations[0]!)
            }
            
            // Put the new one in its slot.
            self.annotations[0] = annotation
            
        } else {
            
            // If the current one exists then remove her.
            if self.annotations[1] != nil {
                self.mapView.removeAnnotation(self.annotations[1]!)
            }
            
            // Put the new one in its slot.
            self.annotations[1] = annotation
        }
        
        // Update the map to show the annotations.
        self.mapView.showAnnotations(self.mapView.annotations, animated: false)
        
        let center : CLLocationCoordinate2D
        let span : MKCoordinateSpan
        
        // If there's only one annotation then that is the new center.
        if (annotations[0] == nil && annotations[1] != nil) || (annotations[1] == nil && annotations[0] != nil) {
            
            // Get the non-empty annotation.
            let annotation1 : MKAnnotation
            
            if annotations[0] != nil {
                annotation1 = annotations[0]!
            } else {
                annotation1 = annotations[1]!
            }
            
            center = CLLocationCoordinate2D(latitude: annotation1.coordinate.latitude, longitude: annotation1.coordinate.longitude)
            span = MKCoordinateSpanMake(3.0, 3.0)
            
            // Otherwise the center is halfway between both of them.
        } else {
            
            let annotation1 : MKAnnotation = annotations[0]!
            let annotation2 : MKAnnotation = annotations[1]!
            let coord1 : CLLocationCoordinate2D  = annotation1.coordinate
            let coord2 : CLLocationCoordinate2D = annotation2.coordinate
            
            center = CLLocationCoordinate2D(latitude: (coord1.latitude + coord2.latitude) / 2.0, longitude: (coord1.longitude + coord2.longitude) / 2.0)
            
            let deltaLat : Double = 2.5 * abs(coord1.latitude - coord2.latitude)
            let deltaLong : Double = 2.5 * abs(coord1.longitude - coord2.longitude)
            let delta : CLLocationDegrees = CLLocationDegrees(max(deltaLat, deltaLong))
            span = MKCoordinateSpanMake(delta, delta)
            
            // Remove the current overlay
            if self.currentMKRoute != nil {
                self.mapView.remove((self.currentMKRoute?.polyline)!)
            }
            
            // Create the new route.
            self.createMKRoute()
        }
        
        // Set the region.
        let region = MKCoordinateRegion(center: center, span: span)
        
        // Present the region on the map.
        self.mapView.setRegion(region, animated: true)
    }
    
    // Function for creating an MKRoute.
    func createMKRoute () {
        
        // If we aren't currently doing some math / is nil.
        if directions == nil || !directions.isCalculating {
            
            // Create a new request.
            let directionRequest = MKDirectionsRequest()
            
            // Get start and end.
            directionRequest.source = self.start
            directionRequest.destination = self.end
            
            // Set the transportation type.
            directionRequest.transportType = MKDirectionsTransportType.automobile
            directionRequest.requestsAlternateRoutes = self.requestAlternateRoutes
            
            // Set the directionsRequest to the directions object.
            directions = MKDirections(request: directionRequest)
            
            // Call ye old spinner.
            self.pauseForSpinner()
            
            // Calculate directions.
            self.directions.calculate(completionHandler: { (response: MKDirectionsResponse?, error: Error?) -> Void in
                
                if error != nil {
                    // Handle the error.
                    print(error.debugDescription)
                    
                } else {
                    // Get shit done.
                    if response != nil {
                        
                        let routes = (response!).routes as [MKRoute]
                        
                        // If we have some routes.
                        if routes.count > 0 {
                            
                            // Get the best route.
                            let bestRoute : MKRoute = routes[0] as MKRoute
                            self.currentMKRoute = bestRoute
                            
                            // Draw the route.
                            self.mapView.add(bestRoute.polyline, level: MKOverlayLevel.aboveRoads)
                        }
                    }
                }
                
                // Remove ye old spinner.
                self.unPause()
            })
        }
    }
    
    // Map view method that loads directions.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polylineOverlay = overlay as? MKPolyline {
            let render = MKPolylineRenderer(polyline: polylineOverlay)
            render.strokeColor = UIColor.blue
            return render
        }
        return MKOverlayRenderer()
    }
    
    // AnnotationView for annotation.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation : CustomAnnotation = annotation as? CustomAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                if annotation.locationType == LocationType.start {
                    view.pinTintColor = UIColor.green
                } else {
                    view.pinTintColor = UIColor.red
                }
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    
    /*
     * Text Field methods.
     */
    
    @IBAction func searchBoxEditingDidBegin(_ sender: UITextField) {
        
        // Get search view controller.
        let searchVC : SearchVC = mainSB.instantiateViewController(withIdentifier: "searchVC") as! SearchVC
        searchVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        searchVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        // Set search field text depending on which search field was clicked.
        switch sender.restorationIdentifier! {
        case "start":
            searchVC.parentTextField = self.fromSearchField
        default:
            searchVC.parentTextField = self.toSearchField
        }
        searchVC.delegate = self
        
        // Present view controller.
        self.present(searchVC, animated: true, completion: nil)
    }
    
    
    /*
     * Button methods.
     */
    
    @IBAction func findRoutesButtonClicked(_ sender: Any) {
        
        // If search fields are empty.
        if fromSearchField.text == "" || toSearchField.text == "" {
            
            // ALERT THAT THERE IS NO FROM OR TO PLACES ENTERED
        } else {
            
            // Get route results nav vc.
            let nav : UINavigationController = mainSB.instantiateViewController(withIdentifier: "ridingResultsNav") as! UINavigationController
            nav.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            // Build next VC.
            let vc : RidingResultsVC = nav.visibleViewController as! RidingResultsVC
            
            // Create address route object.
            vc.ride = Ride(start: self.start, end: self.end, drive: nil)
            
            // Present that bad boy.
            self.present(nav, animated: true, completion: nil)
            
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
