//
//  DoseVolumeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 7/9/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class DoseVolumeInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblValue: WKInterfaceLabel!
    @IBOutlet var btnDot: WKInterfaceButton!
    
    var medicalIController : MedicineInterfaceController!
    var contextData : [String: Any]? = [:]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Dose")
        
        self.contextData = context as? [String:Any]
        var volText = ""
        
        self.medicalIController = self.contextData!["controller"] as! MedicineInterfaceController
        volText = String(self.medicalIController.medicineDoseValue)
        lblValue.setText("\(volText)")
        
        if (medicalIController.medicineDoseUnit.lowercased() == "droplet" || medicalIController.medicineDoseUnit.lowercased() == "puff" || medicalIController.medicineDoseUnit.lowercased() == "dose" || medicalIController.medicineDoseUnit.lowercased() == "cream") {
            self.btnDot.setTitle("")
            self.btnDot.setEnabled(false)
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
        var currentValue = "\(medicalIController.medicineDoseValue)"
        currentValue = String(currentValue.dropLast())
        
        if currentValue == "" {
            medicalIController.medicineDoseValue = "0"
            lblValue.setText("0")
        }else{
            lblValue.setText(currentValue)
            medicalIController.medicineDoseValue = currentValue
        }
        
        self.medicalIController.valueChanged_Medicine = true
        
    }
    
    @IBAction func dotClicked() {
        
        let newValue = "."
        var currentValue = ""
        
        currentValue = "\(medicalIController.medicineDoseValue)"
        if (currentValue.contains("." )) {
            return
        }
        if currentValue == "" {
            currentValue = "0"
        }
        currentValue += newValue
        let value = Float(currentValue)
        if value! < 200 {
            medicalIController.medicineDoseValue = "\(currentValue)"
            lblValue.setText(currentValue)
        }
        else {
            medicalIController.medicineDoseValue = "200"
            lblValue.setText("200")
        }
        
        self.medicalIController.valueChanged_Medicine = true
        
    }
    
    func appendValue(value: Int) {
        
        let newValue = "\(value)"
        var currentValue = ""
        
        currentValue = "\(medicalIController.medicineDoseValue)"
        if currentValue == "0" {
            currentValue = ""
        }
        
        if currentValue.contains("."){
            let seperatedValues = currentValue.split(separator: ".")
            let val = seperatedValues.last
            if (seperatedValues.count>1 && val?.count != 0) {
                Alert.alertView(message:"Only one decimal value can be entered!", controller: self)
                return
            }
        }
        
        currentValue += newValue
        let value = Float(currentValue)
        if value! < 200 {
            medicalIController.medicineDoseValue = "\(currentValue)"
            lblValue.setText(currentValue)
        }
        else {
            medicalIController.medicineDoseValue = "200"
            lblValue.setText("200")
        }
        self.medicalIController.valueChanged_Medicine = true
        
    }
    
    func getDisplayAmount(value: Float) -> String {
        return "\(value)"
    }
    
}
