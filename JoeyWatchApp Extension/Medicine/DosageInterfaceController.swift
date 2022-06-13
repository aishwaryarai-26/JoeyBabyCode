//
//  DosageInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/20/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class DosageInterfaceController: WKInterfaceController {

    // MARK:- Outlets
    @IBOutlet var lblUnit: WKInterfaceLabel!
    @IBOutlet var lblVolume: WKInterfaceLabel!
    
    // MARK:- Objects
    var doseValue     : String          = ""
    var doseUnit     : String          = ""
    var medicalIController : MedicineInterfaceController!
    var contextData : [String: Any]? = [:]
    
    // MARK:- Interface Controller methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Dosage")
        // Configure interface objects here.
        self.contextData = context as? [String:Any]
        self.medicalIController = self.contextData!["controller"] as! MedicineInterfaceController

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.doseValue = self.medicalIController.medicineDoseValue
        self.doseUnit = self.medicalIController.medicineDoseUnit
        
        self.lblVolume.setText(self.doseValue)
        self.lblUnit.setText(self.doseUnit)
        
        if (medicalIController.medicineDoseUnit.lowercased() == "droplet" || medicalIController.medicineDoseUnit.lowercased() == "puff" || medicalIController.medicineDoseUnit.lowercased() == "dose" || medicalIController.medicineDoseUnit.lowercased() == "cream"){
            if (medicalIController.medicineDoseValue.contains(".")) {
                let val = self.roundUp(Double(medicalIController.medicineDoseValue)!, toNearest: 1.0)
                self.medicalIController.medicineDoseValue = "\(val)"
                self.lblVolume.setText("\(val)")
            }
        }
        
    }
    
    // MARK:- Custom Methods
    func roundUp(_ value: Double, toNearest: Double) -> Int {
        return Int(ceil(value / toNearest) * toNearest)
    }
    
    // MARK:- IBActions
    @IBAction func unitClicked() {
        let doseUnitList = ["ml", "oz", "tbsp", "sachet", "tablet", "droplet", "puff", "dose", "cream"]
        let contextDict = ["attribute" : "doseUnit","controller" : self.medicalIController,"doseUnitNames":doseUnitList] as [String : Any]
        pushController(withName:  Constants.Controllers.Medicine_Type, context: contextDict)
    }
    
    @IBAction func volumeClicked() {
        let contextDict = ["controller" : self.medicalIController] as [String : Any]
        pushController(withName:  Constants.Controllers.Medicine_Dose_Volume, context: contextDict)
    }
    
}
