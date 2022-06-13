//
//  FeedNursingTimerInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 6/7/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class FeedNursingTimerInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblValue: WKInterfaceLabel!
    var newFeedController : New_FeedInterfaceController!
    var dict : [String:Any] = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Duration")
        
        dict = context as! [String:Any]
        newFeedController = dict["Controller"] as! New_FeedInterfaceController
        let timer = dict["Timer"] as! String
        if timer == "timerValueLeft" {
            lblValue.setText(newFeedController.getDisplayAmount(value: newFeedController.timerValueLeft) + " min")
        }
        else {
            lblValue.setText(newFeedController.getDisplayAmount(value: newFeedController.timerValueRight) + " min")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func oneTapped() {
        appendValue(value: 1)
    }
    
    @IBAction func twoTapped() {
        appendValue(value: 2)
    }
    
    @IBAction func threeTapped() {
        appendValue(value: 3)
    }
    
    @IBAction func fourTapped() {
        appendValue(value: 4)
    }
    
    @IBAction func fiveTapped() {
        appendValue(value: 5)
    }
    
    @IBAction func sixTapped() {
        appendValue(value: 6)
    }
    
    @IBAction func sevenTapped() {
        appendValue(value: 7)
    }
    
    @IBAction func eightTapped() {
        appendValue(value: 8)
    }
    
    @IBAction func nineTapped() {
        appendValue(value: 9)
    }
    
    @IBAction func zeroTapped() {
        appendValue(value: 0)
    }
    
    func getDisplayAmount(value: Double, round: Bool = true) -> String {
        // Truncate decimal if whole number
        return  "\(value)"
    }
    
    func appendValue(value: Int) {
        let newValue = "\(value)"
        var currentValue = ""
        if (dict["Timer"] as! String) == "timerValueLeft" {
            currentValue = newFeedController.getDisplayAmount(value: newFeedController.timerValueLeft)
            if currentValue == "0" {
                currentValue = ""
            }
            currentValue += newValue
            let value = Int(currentValue)
            if value! < 60 {
                newFeedController.timerValueLeft = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            else {
                newFeedController.timerValueLeft = Int(60)
                lblValue.setText("\(60)" + " min")
            }
            newFeedController.elapsedTimeLeft = 0.0
            newFeedController.valueChanged_NursingTimerLeft = true;
        }
        else {
            currentValue = newFeedController.getDisplayAmount(value: newFeedController.timerValueRight)
            if currentValue == "0" {
                currentValue = ""
            }
            currentValue += newValue
            let value = Int(currentValue)
            if value! < 60 {
                newFeedController.timerValueRight = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            else {
                newFeedController.timerValueRight = Int(60)
                lblValue.setText("\(60)" + " min")
            }
            newFeedController.elapsedTimeRight = 0.0
            newFeedController.valueChanged_NursingTimerRight = true;
        }
        
    }
    
    @IBAction func cancelClicked() {
        if (dict["Timer"] as! String) == "timerValueLeft" {
            var currentValue = newFeedController.getDisplayAmount(value: newFeedController.timerValueLeft)
            currentValue = String(currentValue.dropLast())
            if currentValue == "" {
                newFeedController.timerValueLeft = 0
                lblValue.setText("\(0)" + " min")
            }else{
                newFeedController.timerValueLeft = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            newFeedController.valueChanged_NursingTimerLeft = true;
        }
        else{
            var currentValue = newFeedController.getDisplayAmount(value: newFeedController.timerValueRight)
            currentValue = String(currentValue.dropLast())
            if currentValue == "" {
                newFeedController.timerValueRight = 0
                lblValue.setText("\(0)" + " min")
            }else{
                newFeedController.timerValueRight = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            newFeedController.valueChanged_NursingTimerRight = true;
        }
    }
    
}
