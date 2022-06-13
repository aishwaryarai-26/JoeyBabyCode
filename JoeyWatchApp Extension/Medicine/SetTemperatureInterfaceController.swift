//
//  SetTemperatureInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/23/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class SetTemperatureInterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet var lblTemperature1: WKInterfaceLabel!
    @IBOutlet var lblTemperature2: WKInterfaceLabel!
    @IBOutlet var lblUnit : WKInterfaceLabel!
    
    var tempActive1 : Bool = true
    var tempActive2 : Bool = false
    var unitActive  : Bool = false
    
    var temp1       : Int = 95
    var temp2       : Int = 0
    var unit        : String = "C"
    
    @IBOutlet var btnTemp1: WKInterfaceGroup!
    @IBOutlet var btnTemp2: WKInterfaceGroup!
    @IBOutlet var btnUnit: WKInterfaceGroup!
    
    var medicalIController : MedicineInterfaceController!
    var contextData : [String: Any]? = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Temperature")
        
        crownSequencer.delegate = self
        crownSequencer.focus()
        
        self.contextData = context as? [String:Any]
        self.medicalIController = self.contextData!["controller"] as! MedicineInterfaceController
        
        let tempVal = self.medicalIController.temperatureValue
        let tempUnit = self.medicalIController.temperatureValueUnit
        var defaultTemp1 = "36"
        var defaultTemp2 = "7"
        self.unit = "C"
        
        self.lblTemperature1.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblTemperature2.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblUnit.setTextColor((UIColor(hex: Constants.Colors.white)))
        
        if tempUnit.contains("F") {
            defaultTemp1 = "98"
            defaultTemp2 = "6"
            self.unit = "F"
        }
        
        if (tempVal.contains(".")) {
            let seperatedValues = tempVal.split(separator: ".")
            let val = seperatedValues.last
            if (seperatedValues.count>1 && val?.count != 0) {
                if let val = seperatedValues.first {
                    let valStrFirst = String(val)
                    self.temp1 = Int(valStrFirst)!
                }else {
                    self.temp1 = Int(defaultTemp1)!
                }
                if let val = seperatedValues.last {
                    let valStrLast = String(val)
                    self.temp2 = Int(valStrLast)!
                }else {
                    self.temp2 = Int(defaultTemp2)!
                }
                
            }else {
                if let val = seperatedValues.first {
                    let valStrFirst = String(val)
                    self.temp1 = Int(valStrFirst)!
                }else {
                    self.temp1 = Int(defaultTemp1)!
                }
                self.temp2 = 0
            }
        }else {
            self.temp1 = Int(medicalIController.temperatureValue)!
            self.temp2 = 0
        }
        
    }
    
    override func willActivate() {
        super.willActivate()
        crownSequencer.delegate = self
        crownSequencer.focus()
        
        self.lblTemperature1.setText("\(self.temp1)")
        self.lblTemperature2.setText("\(self.temp2)")
        self.lblUnit.setText(unit)
    }
    
    override func willDisappear() {
        let tempStr = String(format: "%d.%d", self.temp1, self.temp2)
        self.medicalIController.temperatureValue = tempStr
        self.medicalIController.temperatureValueUnit = self.unit
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func temp1Clicked() {
        tempActive1 = true
        tempActive2 = false
        unitActive  = false
        btnTemp1.setBackgroundColor(UIColor(hex: Constants.Colors.peach))
        btnTemp2.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        btnUnit.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblTemperature1.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblTemperature2.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblUnit.setTextColor((UIColor(hex: Constants.Colors.white)))
        
    }
    
    @IBAction func temp2Clicked() {
        tempActive1 = false
        tempActive2 = true
        unitActive  = false
        btnTemp1.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        btnTemp2.setBackgroundColor(UIColor(hex: Constants.Colors.peach))
        btnUnit.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblTemperature1.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblTemperature2.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblUnit.setTextColor((UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func unitClicked() {
        tempActive1 = false
        tempActive2 = false
        unitActive  = true
        btnTemp1.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        btnTemp2.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        btnUnit.setBackgroundColor(UIColor(hex: Constants.Colors.peach))
        
        self.lblTemperature1.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblTemperature2.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblUnit.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if tempActive1 {
            changeTempearture1(rotationalDelta : rotationalDelta)
        }
        if tempActive2 {
            changeTemperature2(rotationalDelta : rotationalDelta)
        }
        if unitActive {
            if rotationalDelta > 0 {
                temp1 = 95
                unit = "F"
                lblUnit.setText(unit)
                lblTemperature1.setText(String(describing :temp1))
            }
            else {
                temp1 = 36
                unit = "C"
                lblUnit.setText(unit)
                lblTemperature1.setText(String(describing :temp1))
            }
            self.medicalIController.valueChanged_temperature = true
        }
    }
    
    func changeTempearture1(rotationalDelta : Double){
        
        if unit == "F"{
            if temp1 >= 95 && temp1 <= 107 {
                if rotationalDelta > 0 && temp1 < 107{
                    temp1 += 1
                }
                else if  rotationalDelta < 0 && temp1 > 95{
                    temp1 -= 1
                }
            }
        }
        else {
            if temp1 >= 36 && temp1 <= 42 {
                if rotationalDelta > 0 && temp1 < 42{
                    temp1 += 1
                }
                else if rotationalDelta < 0 && temp1 > 36{
                    temp1 -= 1
                }
            }
        }
        
        self.lblTemperature1.setText("\(self.temp1)")
        self.medicalIController.valueChanged_temperature = true
    }
    
    func changeTemperature2(rotationalDelta : Double){
        
        if temp2 >= 0 && temp2 <= 9 {
            if rotationalDelta > 0 && temp2 < 9{
                temp2 += 1
            }
            else if  rotationalDelta < 0 && temp2 > 0{
                temp2 -= 1
            }
            self.lblTemperature2.setText("\(self.temp2)")
            self.medicalIController.valueChanged_temperature = true
        }
        
    }
    
}
