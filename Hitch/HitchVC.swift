//
//  HitchVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/27/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

class HitchVC : UIViewController, UITextFieldDelegate {
    
    var activeField : UITextField!
    var metaScrollView : UIScrollView!
    
    // Keyboard will show.
    func keyboardWillShow(notification:NSNotification) {
        
        // Get keyboard info.
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardValues:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardFrame : CGRect = keyboardValues.cgRectValue
        
        scroll(tf: self.activeField, kb: keyboardFrame)
    }
    
    // Highlight a given textfield and move up if necessary.
    func scroll (tf: UITextField, kb : CGRect) {
        
        // Scroll the view by giving it a bigger size.
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kb.size.height, 0.0)
        self.metaScrollView.contentInset = contentInsets
        
        // If the keyboard covers the textfield.
        if kb.intersects(tf.frame) {
            
            // Scroll the view.
            self.metaScrollView.setContentOffset(CGPoint(x:0.0, y: abs(kb.minY-tf.frame.maxY)), animated: true)
        }
    }
    
    // Dehighlight a textfield and move down if necessary.
    func deHighlightTextField (tf: UITextField) {
        
        // Scroll the view.
        self.metaScrollView.setContentOffset(CGPoint(x:0.0, y: 0.0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        deHighlightTextField(tf: textField)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.activeField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}
