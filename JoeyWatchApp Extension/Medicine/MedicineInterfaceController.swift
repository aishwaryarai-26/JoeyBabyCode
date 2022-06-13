//
//  MedicineInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/19/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class MedicineInterfaceController: WKInterfaceController {

    // MARK:- Outlets
    @IBOutlet var medicalTbl     : WKInterfaceTable!
    @IBOutlet var group          : WKInterfaceGroup!
    @IBOutlet var loader         : WKInterfaceImage!
    @IBOutlet var loaderView     : WKInterfaceGroup!
    
    // MARK:- Objects
    var attributesArr            : [String]?
    var medicalData              : ActivityList?
    var medicalInfo              : [String:Any]?
    var selectedBabyIndex        : Int     = 0
    var medicalType              : String = ""
    var medicineName             : String = ""
    var medicineDoseValue        : String = ""
    var medicineDoseUnit         : String = ""
    var symptomName              : String = ""
    var temperatureValue         : String = ""
    var temperatureValueUnit     : String = ""

    var sendToActivityInterface  : Bool   = false
    var valueChanged_Medicine             = false
    var valueChanged_Symptom              = false
    var valueChanged_temperature          = false
    
    // MARK:- Interface Controller methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Medical")
        
        medicalData = context as? ActivityList
        print(self.medicalData!)
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        self.medicalInfo = ((babyList[self.selectedBabyIndex])["pump_info"]) as? [String : Any]
        print(self.medicalData!)
        
        self.medicalType = "medicine"
        if (self.medicalData?.type?.lowercased()=="symptom" || self.medicalData?.type?.lowercased()=="temperature" || self.medicalData?.type?.lowercased()=="movement") {
            self.medicalType = "\(self.medicalData?.type?.lowercased() ?? "")"
        }
        
        self.medicineName = "panadol"
        self.medicineDoseValue = "2"
        self.medicineDoseUnit = "ml"
        self.symptomName = "Cough"
        self.temperatureValue = "36.7"
        self.temperatureValueUnit = "℃"
        self.sendToActivityInterface = false
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        self.setScreenData()
        self.stopLoader()
    }

    // MARK:- Custom Methods
    func setScreenData() {
        
        var medicalDataDict : [String:Any]?
        if (self.medicalInfo?.count)!>0 {
            if let dict = self.medicalInfo!["\(self.medicalType)"] {
                
                if (self.medicalType == "medicine") {
                    if (!self.valueChanged_Medicine) {
                        medicalDataDict = dict as? [String:Any]
                        self.medicineName = (medicalDataDict!["name"] as? String)!
                        self.medicineDoseValue = (medicalDataDict!["value"] as? String)!
                        self.medicineDoseUnit = (medicalDataDict!["unit"] as? String)!
                    }
                }
                else if (self.medicalType == "symptom") {
                    if (!self.valueChanged_Symptom) {
                        medicalDataDict = dict as? [String:Any]
                        self.symptomName = (medicalDataDict!["name"] as? String)!
                    }
                }
                else if (self.medicalType == "temperature") {
                    if (!self.valueChanged_temperature) {
                        medicalDataDict = dict as? [String:Any]
                        self.temperatureValue = (medicalDataDict!["value"] as? String)!
                        self.temperatureValueUnit = (medicalDataDict!["unit"] as? String)!
                    }
                }
            }
        }

        self.attributesArr?.removeAll()
        self.attributesArr = [String]()
        if (self.medicalType == "medicine") {
            self.attributesArr?.append(self.medicalType.capitalized)
            self.attributesArr?.append(self.medicineName.capitalized)
            let doseStr = String(format: "%@ %@", self.medicineDoseValue, self.medicineDoseUnit.lowercased())
            self.attributesArr?.append(doseStr)
        }
        else if (self.medicalType == "symptom") {
            self.attributesArr?.append(self.medicalType.capitalized)
            self.attributesArr?.append(self.symptomName.capitalized)
        }
        else if (self.medicalType == "temperature") {
            self.attributesArr?.append(self.medicalType.capitalized)
            let tempStr = String(format: "%@ %@", self.temperatureValue, self.temperatureValueUnit.capitalized)
            self.attributesArr?.append(tempStr)
        }
        else if (self.medicalType == "movement") {
            self.attributesArr?.append(self.medicalType.capitalized)
        }
        
        self.loadTableData()
    }
    
    func convertTemp(tVal:String,tUnit:String) -> (String){
        var corretedTVal = tVal
        if (tUnit.contains("F")) {
            var val = Float(tVal)
            val = (val!-32)/1.8
            corretedTVal = String(format: "%.2f", val!)
        }
        return corretedTVal
    }
    
    // MARK:- TableView Implementation
    func loadTableData() {
        self.medicalTbl.setNumberOfRows((attributesArr?.count)!, withRowType: "Med")
        for (nameIndex, name) in (attributesArr?.enumerated())! {
            let row = medicalTbl.rowController(at: nameIndex) as! Med
            row.lblTitle.setText(name)
            row.mainGroup.setBackgroundColor(UIColor(hex: Constants.Colors.medical))
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if (self.medicalType == "medicine") {
            if (self.attributesArr?.count != 3) {
                return
            }else {
                if rowIndex == 0 {
                    let context = ["attribute" : "MedType","controller" : self] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Type, context: context)
                }else if rowIndex == 1 {
                    let medNames = ["panadol", "neurofen", "zyrtec", "singular", "sudafed"]
                    let type = ["attribute" : "MedName","controller" : self,"medicineNames":medNames] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Type, context: type)
                }else {
                    let context = ["controller" : self] as [String : Any]
                    pushController(withName: Constants.Controllers.Medicine_Dosage, context: context)
                }
            }
        }
        else if (self.medicalType == "symptom") {
            if (self.attributesArr?.count != 2) {
                return
            }else {
                if rowIndex == 0 {
                    let context = ["attribute" : "MedType","controller" : self] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Type, context: context)
                }else if rowIndex == 1 {
                    let sympNames = ["fever", "cough", "vomit", "rashes"]
                    let type = ["attribute" : "SympName","controller" : self,"symptomNames":sympNames] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Type, context: type)
                }
            }
        }
        else if (self.medicalType == "temperature") {
            if (self.attributesArr?.count != 2) {
                return
            }else {
                if rowIndex == 0 {
                    let context = ["attribute" : "MedType","controller" : self] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Type, context: context)
                }else if rowIndex == 1 {
                    let contextDict = ["controller" : self] as [String : Any]
                    pushController(withName:  Constants.Controllers.Medicine_Set_Temperature, context: contextDict)
                }
            }
        }
        else if (self.medicalType == "movement") {
            if rowIndex == 0 {
                let context = ["attribute" : "MedType","controller" : self] as [String : Any]
                pushController(withName:  Constants.Controllers.Medicine_Type, context: context)
            }
        }
        
    }
    
    @IBAction func saveClicked() {
         self.callSaveWebservice()
    }
    
    // MARK:- Web Service calls
    func callSaveWebservice(){

        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["type"] = self.medicalType
        paramsDict["name"] = "medical"
        paramsDict["value"] = 0
        paramsDict["unit"] = ""
        paramsDict["notes"] = ""
        paramsDict["time"] = Constants.getDate(date: Date())
        
        if (self.medicalType == "medicine"){
            paramsDict["value"] = Int(self.medicineDoseValue)
            paramsDict["unit"] = self.medicineDoseUnit
            paramsDict["medicine"] = self.medicineName
        }
        else if (self.medicalType == "symptom"){
            paramsDict["symptom"] = self.symptomName
        }
        else if (self.medicalType == "temperature"){
            paramsDict["value"] = self.convertTemp(tVal: self.temperatureValue, tUnit: self.temperatureValueUnit)
            paramsDict["unit"] = "°C"
        }
        
       self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            self.stopLoader()
            if (response["success"] as? Bool)!{
                // Get Baby Details
                var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                (babyList![selectedBIndex])["medical_info"] = response["info"]
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                UserDefaults.standard.synchronize()
                self.sendToActivityInterface = true
                self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_medicine)
            }
            else {
                print("failed !")
            }
        }, errorBlock: { (error) in
            print(error)
        })
        
    }
    
}
extension MedicineInterfaceController {
    func showLoader() {
        self.setLoader(hidden: false)
        loader.setImageNamed("loader")
        loader.startAnimatingWithImages(in: NSRange(location: 1,
                                                    length: 8), duration: 0.8, repeatCount: -1)
    }
    func stopLoader() {
        self.loader.stopAnimating()
        self.setLoader(hidden: true)
    }
    
    private func setLoader(hidden:Bool) {
        self.loaderView.setHidden(hidden)
        self.group.setHidden(!hidden)
    }
}
class Med : NSObject {
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblTitle: WKInterfaceLabel!
}

