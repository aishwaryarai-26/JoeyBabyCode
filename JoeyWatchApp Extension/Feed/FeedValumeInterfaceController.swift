//
//  FeedValumeInterfaceController.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/18/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class FeedValumeInterfaceController: WKInterfaceController {
    
    var session : WCSession!
    @IBOutlet var lblKeypadNumber: WKInterfaceLabel!
    @IBOutlet var btnDot: WKInterfaceButton!
    
    var newFeedController : New_FeedInterfaceController!
    
    var contextData : [String: Any]? = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Volume")
        
        contextData = context as? [String:Any]
        var volText = ""
        
        if (contextData!["type"] as! String) == "FeedInterface"{
            newFeedController = contextData!["Controller"] as! New_FeedInterfaceController
            volText = String(newFeedController.feedVolume)
            lblKeypadNumber.setText("\(volText) ml")
            
            self.btnDot.setTitle("")
            self.btnDot.setEnabled(false)
            
        }
        else if (contextData!["type"] as! String) == "SolidInterface"{
            newFeedController = contextData!["Controller"] as! New_FeedInterfaceController
            volText = String(newFeedController.volume)
            lblKeypadNumber.setText("\(volText)")
            
            if (newFeedController.unit == "gm") {
                self.btnDot.setTitle("")
                self.btnDot.setEnabled(false)
            }
            
        }
        
    }

    override func willActivate() {
        super.willActivate()
    }

    @IBAction func oneClicked() {
        appendValue(value: 1)
    }
    @IBAction func twoClicked() {
        appendValue(value: 2)
    }
    @IBAction func threeClicked() {
        appendValue(value: 3)
    }
    @IBAction func fourClicked() {
        appendValue(value: 4)
    }
    @IBAction func fiveClicked() {
        appendValue(value: 5)
    }
    @IBAction func sixClicked() {
        appendValue(value: 6)
    }
    @IBAction func sevenClicked() {
        appendValue(value: 7)
    }
    @IBAction func eightClicked() {
        appendValue(value: 8)
    }
    @IBAction func nineClicked() {
        appendValue(value: 9)
    }
    @IBAction func zeroClicked() {
        appendValue(value: 0)
    }
    
    @IBAction func cancelClicked() {
        if (contextData!["type"] as! String) == "FeedInterface" {
            var currentValue = newFeedController.getDisplayAmount(value: Int(newFeedController.feedVolume))
            currentValue = String(currentValue.dropLast())
            if currentValue == "" {
                newFeedController.feedVolume = 0
                lblKeypadNumber.setText("\(0)" + " ml")
            }else{
                newFeedController.feedVolume = Int(currentValue)!
                lblKeypadNumber.setText(currentValue + " ml")
            }
            newFeedController.valueChanged_FBWJ = true
        }
        else if (contextData!["type"] as! String) == "SolidInterface"{
            
            var currentValue = "\(newFeedController.volume)"
            currentValue = String(currentValue.dropLast())
            
            if currentValue == "" {
                newFeedController.volume = "0"
                lblKeypadNumber.setText("0")
            }else{
                lblKeypadNumber.setText(currentValue)
                newFeedController.volume = currentValue
            }
            newFeedController.valueChanged_SolidsVolume = true
            
//            var currentValue = Constants.getDisplayAmount(value: Int(feedSolidController.volume))
//            currentValue = String(currentValue.dropLast())
//            if currentValue == "" {
//                feedSolidController.volume = 0
//                lblKeypadNumber.setText("\(0)")
//            }else{
//                feedSolidController.volume = Float(Int(currentValue)!)
//                lblKeypadNumber.setText(currentValue)
//            }
        }
        
    }
    
    @IBAction func dotClicked() {
        
        let newValue = "."
        var currentValue = ""

        if (contextData!["type"] as! String) == "FeedInterface" {
            Alert.alertView(message: "Decimal value is not allowed !", controller: self)
        }else{
            
            currentValue = "\(newFeedController.volume)"
            if (currentValue.contains("." )) {
                return
            }
            if currentValue == "" {
                currentValue = "0"
            }
            currentValue += newValue
            let value = Float(currentValue)
            if value! < 200 {
                newFeedController.volume = "\(currentValue)"
                lblKeypadNumber.setText(currentValue)
            }
            else {
                newFeedController.volume = "200"
                lblKeypadNumber.setText("200")
            }
            newFeedController.valueChanged_SolidsVolume = true
        }
    }
    
    func appendValue(value: Int) {
        
        let newValue = "\(value)"
        var currentValue = ""

        if (contextData!["type"] as! String) == "FeedInterface" {
            currentValue = newFeedController.getDisplayAmount(value: Int(newFeedController.feedVolume))
            if currentValue == "0" {
                currentValue = ""
            }
            currentValue += newValue
            let value = Int(currentValue)
            if value! < 200 {
                newFeedController.feedVolume = value!
                lblKeypadNumber.setText("\(currentValue) ml")
            }
            else {
                newFeedController.feedVolume = 200
                lblKeypadNumber.setText("200 ml")
            }
            newFeedController.valueChanged_FBWJ = true
        }
        else if (contextData!["type"] as! String) == "SolidInterface"{
            
            currentValue = "\(newFeedController.volume)"
            if currentValue == "0" {
                currentValue = ""
            }

            if currentValue.contains("."){
                let seperatedValues = currentValue.split(separator: ".")
                let val = seperatedValues.last
                if (seperatedValues.count>1 && val?.count != 0) {
                    Alert.alertView(message: "Only one decimal value can be entered !", controller: self)
                    return
                }
            }

            currentValue += newValue
            let value = Float(currentValue)
            if value! < 200 {
                newFeedController.volume = "\(currentValue)"
                lblKeypadNumber.setText(currentValue)
            }
            else {
                newFeedController.volume = "200"
                lblKeypadNumber.setText("200")
            }
            newFeedController.valueChanged_SolidsVolume = true
        }
        
    }
}
