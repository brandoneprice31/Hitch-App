//
//  WeekDaysView.swift
//  Hitch
//
//  Created by Brandon Price on 2/6/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class WeekDaysView: UIView {

    // Selected days.
    var selectedDays = [Int]()
    var disabledDays = [Int]()
    
    // Buttons
    var mondayButton = UIButton(type: UIButtonType.system)
    var tuesdayButton = UIButton(type: UIButtonType.system)
    var wednesdayButton = UIButton(type: UIButtonType.system)
    var thursdayButton = UIButton(type: UIButtonType.system)
    var fridayButton = UIButton(type: UIButtonType.system)
    var saturdayButton = UIButton(type: UIButtonType.system)
    var sundayButton = UIButton(type: UIButtonType.system)
    var buttonList = [UIButton]()
    
    
    /* Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

    }*/
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Configure
    func configure (selectedDays : [Int], disabledDays : [Int], touchesAllowed : Bool) {
        
        // Establish Button sizes.
        let buttonWidth = bounds.width / 7.0 + 1
        let buttonHeight = bounds.height
        let minX = bounds.minX
        let minY = bounds.minY
        buttonList = [mondayButton,tuesdayButton,wednesdayButton,thursdayButton,fridayButton,saturdayButton,sundayButton]
        
        // Establish selected and disabled.
        self.selectedDays = selectedDays
        self.disabledDays = disabledDays
        
        // Configure buttons.
        for button_iter in 0...buttonList.count-1 {
            
            // Frame and sizing.
            let button = buttonList[button_iter]
            button.tag = button_iter
            button.frame = CGRect(x: minX + (buttonWidth - 1) * CGFloat(button_iter), y: minY, width: buttonWidth, height: buttonHeight)
            
            // Color and selectors for different types.
            self.backgroundColor = .clear
            if self.selectedDays.contains(button_iter + 1) {
                button.backgroundColor = navyColor
                
                if touchesAllowed {
                    button.addTarget(self, action: #selector(WeekDaysView.buttonSelected(sender:)), for: UIControlEvents.touchUpInside)
                }

            } else if self.disabledDays.contains(button_iter + 1) {
                button.backgroundColor = .clear
                
            } else {
                button.backgroundColor = .white
                
                if touchesAllowed {
                    button.addTarget(self, action: #selector(WeekDaysView.buttonSelected(sender:)), for: UIControlEvents.touchUpInside)
                }
            }
            
            // Enable and disable buttons.
            if touchesAllowed {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
            
            // Border.
            button.layer.borderColor = navyColor.cgColor
            button.layer.borderWidth = 1.0
            
            // Text
            button.setTitle(DateTime.shortestWeekDays?[button_iter], for: .normal)
            button.setTitleColor(lightGreyColor, for: .normal)
            button.contentHorizontalAlignment = .center
            
            self.addSubview(button)
        }

    }
    
    // Button clicked.
    func buttonSelected (sender: UIButton) {
        
        if selectedDays.contains(sender.tag) {
            // Remove the selected number and change color.
            selectedDays.remove(at: selectedDays.index(of: sender.tag)!)
            sender.backgroundColor = .white
        } else {
            // Add the selected number and change color.
            selectedDays.append(sender.tag)
            sender.backgroundColor = navyColor
        }
    }
    
    class func getDisabledDays (notDisabledDays : [Int]) -> [Int] {
        
        let disabledDays = Array(1...7).filter({x -> Bool in !notDisabledDays.contains(x)})
        return disabledDays
    }
    
    func getSelectedWeekDays () -> [Int] {
        
        var actualSelectedWeekDays = [Int]()
        
        for index in selectedDays {
            actualSelectedWeekDays.append(index + 1)
        }
        
        return actualSelectedWeekDays
    }

}
