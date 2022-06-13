//
//  MedicineTypeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/19/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class MedicineTypeInterfaceController: WKInterfaceController {

    @IBOutlet var typeListTbl: WKInterfaceTable!

    var medicalIController : MedicineInterfaceController!
    var dosageIController : DosageInterfaceController!
    var contextData : [String: Any]? = [:]
    var medNames = [String]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("")
        // Configure interface objects here.
        self.contextData = context as? [String:Any]
        self.medicalIController = self.contextData!["controller"] as! MedicineInterfaceController
        
        if self.contextData!["attribute"] as! String == "MedType" {
            self.setTitle("Type")
            medNames = ["medicine","symptom","temperature","movement"]
        }else if self.contextData!["attribute"] as! String == "MedName"{
            self.setTitle("Medicine")
            medNames = self.contextData!["medicineNames"] as! [String]
        }else if self.contextData!["attribute"] as! String == "SympName"{
            self.setTitle("Symptom")
            medNames = self.contextData!["symptomNames"] as! [String]
        }else if self.contextData!["attribute"] as! String == "doseUnit"{
            self.setTitle("Unit")
            medNames = self.contextData!["doseUnitNames"] as! [String]
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.loadTableData()
    }
    
    func loadTableData() {
        self.typeListTbl.setNumberOfRows(medNames.count, withRowType: "Typ")
        for (nameIndex, name) in (medNames.enumerated()) {
            let row = self.typeListTbl.rowController(at: nameIndex) as! Typ
            row.lblTypeName.setText(name.capitalized)

            if self.contextData!["attribute"] as! String == "MedType" {
                if (name == self.medicalIController.medicalType.lowercased()) {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "MedName"{
                if (name == self.medicalIController.medicineName.lowercased()) {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "SympName"{
                if (name == self.medicalIController.symptomName.lowercased()) {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "doseUnit"{
                row.lblTypeName.setText(name.lowercased())
                if (name == self.medicalIController.medicineDoseUnit.lowercased()) {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }

        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        for (nameIndex, name) in medNames.enumerated() {
            print(name)
            let row = self.typeListTbl.rowController(at: nameIndex) as! Typ
            
            if self.contextData!["attribute"] as! String == "MedType" {
                if rowIndex == nameIndex {
                    self.medicalIController.medicalType = name
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "MedName"{
                if rowIndex == nameIndex {
                    self.medicalIController.medicineName = name
                    self.medicalIController.valueChanged_Medicine = true
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "SympName"{
                if rowIndex == nameIndex {
                    self.medicalIController.symptomName = name
                    self.medicalIController.valueChanged_Symptom = true
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }
            }else if self.contextData!["attribute"] as! String == "doseUnit"{
                if rowIndex == nameIndex {
                    self.medicalIController.medicineDoseUnit = name
                    self.medicalIController.valueChanged_Medicine = true
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
                    row.lblTypeName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }else {
                    row.bgGroup.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                    row.lblTypeName.setTextColor(UIColor.white)
                }

            }
            
        }
    }
    
}

class Typ: NSObject {
    @IBOutlet var lblTypeName:WKInterfaceLabel!
    @IBOutlet var bgGroup:WKInterfaceGroup!
}
