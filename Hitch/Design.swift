//
//  Design.swift
//  Hitch
//
//  Created by Brandon Price on 1/30/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

let orangeColor = UIColor(red:255.0/255.0, green:154.0/255.0, blue:50.0/255.0, alpha: 1.0)
let navyColor = UIColor(red: 25.0/255.0, green: 46.0/255.0, blue: 67.0/255.0, alpha: 1.0)
let lightGreyColor = UIColor(red: 232.0/255.0, green: 232.0/255.0, blue: 232.0/255.0, alpha: 1.0)

class Design {
    
    // Function that returns a move up transition usually for pushing views.
    class func moveUpTransition () -> CATransition {
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromTop
        
        return transition
    }
    
    // Function that returns a move down transition usually for popping views.
    class func moveDownTransition () -> CATransition {
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        
        return transition
    }
    
    class func slidePushFromRightTransition () -> CATransition {
        
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        return transition
    }
    
    class func slidePushFromLeftTransition () -> CATransition {
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        return transition
    }
    
}


func getPriceString (price : Double) -> String? {
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    let stringPrice = formatter.string(from: price as NSNumber)
    return stringPrice
}
