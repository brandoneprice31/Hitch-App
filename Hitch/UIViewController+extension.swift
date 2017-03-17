//
//  UIViewControllerExtension.swift
//  Hitch
//
//  Created by Brandon Price on 1/31/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // Function that simply presents an alert view with default action.
    func presentNormalAlertView(title: String, message: String) {
        
        // Create alertview with title and message, and present that bad boy.
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // Function that presents an alertview with okay and cancel actions.
    func presentOkayCancelAlertView(title: String, message: String, okayHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        
        // Create alertview with title and message, and present that bad boy.
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: okayHandler)
        alertView.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: cancelHandler)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func pauseEverythingWithoutSpinner () {
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func unPauseEverythingWithoutSpinner () {
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // Pause view and add animation / spinner
    func pauseViewWithAnimation (view: UIView, animationName: String, text: String) {
        
        // Disable the view.
        view.isUserInteractionEnabled = false
        
        // Add Dim view.
        let dimViewColor = UIColor(white: 0.0, alpha: 0.0)
        let dimView = UIView(frame: self.view.frame)
        dimView.backgroundColor = dimViewColor
        dimView.restorationIdentifier = "dimView"
        
        // Add miniview.
        let miniView = UIView()
        miniView.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 125)
        miniView.center = dimView.center
        miniView.layer.cornerRadius = 10.0
        miniView.backgroundColor = UIColor.clear
        dimView.addSubview(miniView)
        
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.frame.size = CGSize(width: 84.0, height: 21.0)
        label.frame.origin.y = miniView.bounds.height - 8.0 - label.frame.height
        label.frame.origin.x = 8.0
        label.alpha = 0.0
        miniView.addSubview(label)
        
        if animationName != "spinner" {
            
            // Add Animation.
            let animation = UIImageView()
            var animationImages = [UIImage]()
            for i in Array(1...10) {
                animationImages.append(UIImage(named: "\(animationName) \(i)")!)
            }
            animationImages = animationImages + animationImages.reversed()
            animation.animationImages = animationImages
            animation.startAnimating()
            
            animation.frame.size = CGSize(width: 84.0, height: 84.0)
            animation.frame.origin.x = 8.0
            animation.frame.origin.y = 8.0
            miniView.addSubview(animation)
            
        } else {
            
            // Add spinner.
            let animation = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            
            animation.frame.size = CGSize(width: 84.0, height: 84.0)
            animation.frame.origin.x = 8.0
            animation.frame.origin.y = 8.0
            animation.startAnimating()
            miniView.addSubview(animation)
        }
        
        
        self.view.addSubview(dimView)
        
        dimView.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {

            dimView.alpha = 1.0
        })
    }
    
    
    func unPauseViewAndRemoveAnimation (view: UIView) {
        
        // Enable interaction
        view.isUserInteractionEnabled = true
        
        var dimView : UIView? = nil
        
        // Find the mini view.
        for subView in self.view.subviews {
            if subView.restorationIdentifier == "dimView" {
                dimView = subView
                break
            }
        }
        
        if dimView != nil {
            
            // Remove miniview.
            UIView.animate(withDuration: 0.25, animations: {
                dimView!.alpha = 0.0
            })
            
            dimView!.removeFromSuperview()
        }
    }
}
