//
//  KeypadInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/17/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class KeypadInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblValue: WKInterfaceLabel!
    var pumpController : PumpInterfaceController!
    var dict : [String:Any] = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Duration")
        
        dict = context as! [String:Any]
        pumpController = dict["Controller"] as! PumpInterfaceController
        let timer = dict["Timer"] as! String
        if timer == "timerValueLeft" {
            lblValue.setText(pumpController.getDisplayAmount(value: pumpController.timerValueLeft) + " min")
        }
        else {
            lblValue.setText(pumpController.getDisplayAmount(value: pumpController.timerValueRight) + " min")
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
            currentValue = pumpController.getDisplayAmount(value: pumpController.timerValueLeft)
            if currentValue == "0" {
                currentValue = ""
            }
            currentValue += newValue
            let value = Int(currentValue)
            if value! < 60 {
                pumpController.timerValueLeft = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            else {
                pumpController.timerValueLeft = Int(60)
                lblValue.setText("\(60)" + " min")
            }
            pumpController.elapsedTimeLeft = 0.0
        }
        else {
            currentValue = pumpController.getDisplayAmount(value: pumpController.timerValueRight)
            if currentValue == "0" {
                currentValue = ""
            }
            currentValue += newValue
            let value = Int(currentValue)
            if value! < 60 {
                pumpController.timerValueRight = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
            else {
                pumpController.timerValueRight = Int(60)
                lblValue.setText("\(60)" + " min")
            }
            pumpController.elapsedTimeRight = 0.0
        }
        
    }
    
    @IBAction func cancelClicked() {
        if (dict["Timer"] as! String) == "timerValueLeft" {
            var currentValue = pumpController.getDisplayAmount(value: pumpController.timerValueLeft)
            currentValue = String(currentValue.dropLast())
            if currentValue == "" {
                pumpController.timerValueLeft = 0
                lblValue.setText("\(0)" + " min")
            }else{
                pumpController.timerValueLeft = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
        }
        else{
            var currentValue = pumpController.getDisplayAmount(value: pumpController.timerValueRight)
            currentValue = String(currentValue.dropLast())
            if currentValue == "" {
                pumpController.timerValueRight = 0
                lblValue.setText("\(0)" + " min")
            }else{
                pumpController.timerValueRight = Int(currentValue)!
                lblValue.setText(currentValue + " min")
            }
        }
    }
    
}
