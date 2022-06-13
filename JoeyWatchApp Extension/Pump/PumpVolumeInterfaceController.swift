//
//  PumpVolumeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/31/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class PumpVolumeInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblValue: WKInterfaceLabel!
    var pumpController : PumpInterfaceController!
    var dict : [String:Any] = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Volume")
        
        dict = context as! [String:Any]
        pumpController = dict["Controller"] as! PumpInterfaceController
        let volume = dict["Volume"] as! String
        if volume == "volumeValueLeft" {
            lblValue.setText("\(pumpController.volumeValueLeft)" + " ml")
        }else {
            lblValue.setText("\(pumpController.volumeValueRight)" + " ml")
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
    
    @IBAction func dotTapped() {
        let newValue = "."
        var currentValue = ""
        if (dict["Volume"] as! String) == "volumeValueLeft" {
            currentValue = "\(pumpController.volumeValueLeft)"
            if (currentValue.contains("." )) {
                return
            }
            if currentValue == "" {
                currentValue = "0"
            }
            currentValue += newValue
            let value = Float(currentValue)
            if value! < 200 {
                pumpController.volumeValueLeft = "\(currentValue)"
                lblValue.setText(currentValue + " ml")
            }
            else {
                pumpController.volumeValueLeft = "200"
                lblValue.setText("200" + " ml")
            }
        }
        else {
            currentValue = "\(pumpController.volumeValueRight)"
            if (currentValue.contains("." )) {
                return
            }
            if currentValue == "" {
                currentValue = "0"
            }
            currentValue += newValue
            let value = Float(currentValue)
            if value! < 200 {
                pumpController.volumeValueRight = "\(currentValue)"
                lblValue.setText(currentValue + " ml")
            }
            else {
                pumpController.volumeValueRight = "200"
                lblValue.setText("200" + " ml")
            }
        }
        
    }
    
    func getDisplayAmount(value: Double, round: Bool = true) -> String {
        // Truncate decimal if whole number
        return  "\(value)"
    }
    
    func appendValue(value: Int) {
        let newValue = "\(value)"
        var currentValue = ""
        if (dict["Volume"] as! String) == "volumeValueLeft" {
            currentValue = "\(pumpController.volumeValueLeft)"
            if currentValue == "0" {
                currentValue = ""
            }
            
            if currentValue.contains("."){
                let seperatedValues = currentValue.split(separator: ".")
                let val = seperatedValues.last
                if (seperatedValues.count>1 && val?.count != 0) {
                    Alert.alertView(message: "Only one decimal value can be entered!", controller: self)
                    return
                }
            }
            
            currentValue += newValue
            let value = Float(currentValue)
            if value! < 200 {
                pumpController.volumeValueLeft = "\(currentValue)"
                lblValue.setText(currentValue + " ml")
            }
            else {
                pumpController.volumeValueLeft = "200"
                lblValue.setText("200" + " ml")
            }
        }
        else {
            currentValue = "\(pumpController.volumeValueRight)"
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
                pumpController.volumeValueRight = "\(currentValue)"
                lblValue.setText(currentValue + " ml")
            }
            else {
                pumpController.volumeValueRight = "200"
                lblValue.setText("200" + " ml")
            }
        }
        
    }
    
    @IBAction func cancelClicked() {
        if (dict["Volume"] as! String) == "volumeValueLeft" {
            var currentValue = "\(pumpController.volumeValueLeft)"
            currentValue = String(currentValue.dropLast())
            
            if currentValue == "" {
                pumpController.volumeValueLeft = "0"
                lblValue.setText("\(0)" + " ml")
            }else{
                lblValue.setText(currentValue + " ml")
                pumpController.volumeValueLeft = "\(currentValue)"
            }
        }
        else{
            var currentValue = "\(pumpController.volumeValueRight)"
            currentValue = String(currentValue.dropLast())
            
            if currentValue == "" {
                pumpController.volumeValueRight = "0"
                lblValue.setText("\(0)" + " ml")
            }else{
                lblValue.setText(currentValue + " ml")
                pumpController.volumeValueRight = "\(currentValue)"
            }
        }
    }
    
}
