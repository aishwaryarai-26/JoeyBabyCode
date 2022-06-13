//
//  New_FeedInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 7/13/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class New_FeedInterfaceController: WKInterfaceController, nursingEventsHandler {
    
    // MARK:- Outlets
    @IBOutlet var feedTbl: WKInterfaceTable!
    @IBOutlet var btnSave : WKInterfaceButton!
    @IBOutlet var loader: WKInterfaceImage!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var loaderView: WKInterfaceGroup!
    
    // MARK:- Objects
    // For Nursing
    var valueChanged_NursingTimerLeft           = false
    var valueChanged_NursingTimerRight          = false
    var shouldAddLeftData                       = false
    var shouldAddRightData                      = false
    var isBtnLeftSelected                       = false
    var isBtnRightSelected                      = false
    var myTimerLeft              : Timer?
    var myTimerRight             : Timer?
    var isPausedLeft                            = true
    var isPausedRight                           = true //flag to determine if it is paused or not
    var elapsedTimeLeft          : TimeInterval = 0.0
    var elapsedTimeRight         : TimeInterval = 0.0 //secounds that have passed on timer
    var startTimeLeft                           = Date()
    var startTimeRight                          = Date()
    var durationLeft             : TimeInterval = 0.0
    var durationRight            : TimeInterval = 0.0
    var timerValueLeft           : Int          = 0
    var timerValueRight          : Int          = 0
    
    // For FBWJ
    var valueChanged_FBWJ                       = false
    var feedVolume               : Int          = 0
    // For Solid
    var valueChanged_SolidsVolume               = false
    var volume                   : String       = "0"
    var unit                     : String       = "gm"
    
    // Common
    var FeedData : ActivityList?
    var feedInfo      : [String:Any]?
    var selectedBabyIndex     : Int          = 0
    var attributesArr      : [String]?
    var feedType : String = ""
    var sendToActivityInterface     : Bool          = false
    
    // MARK:- Interface Controller methods
    override func awake(withContext context: Any?) {
        // Common
        super.awake(withContext: context)
        self.setTitle("Feed")
        self.FeedData = context as? ActivityList
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        self.feedInfo = ((babyList[self.selectedBabyIndex])["feed_info"]) as? [String : Any]
        
        self.feedType = "\(self.FeedData?.type?.lowercased() ?? "")"
        if (self.feedType.count==0) {
            self.feedType = "formula"
        }
        
    }
    
    override func willActivate() {
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        self.setScreenData()
        self.stopLoader()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // MARK:- TableView Implementation
    func loadTableData() {
        
        if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice"))
        {
            let rowTypes = ["FeedTypeCell","FeedTypeCell"];
            self.feedTbl.setRowTypes(rowTypes)
            
            for count in 0...rowTypes.count-1 {
                let rowType = rowTypes[count];
                if (rowType=="FeedTypeCell"){
                    let row = self.feedTbl.rowController(at: count) as! FeedTypeCell
                    let attributeStr = self.attributesArr![count] as String
                    row.lblFeedType.setText("\(attributeStr)")
                }
            }
            
        }
        else if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
            let rowTypes = ["FeedTypeCell","FeedNursingCell"];
            self.feedTbl.setRowTypes(rowTypes)
            
            for count in 0...rowTypes.count-1 {
                let rowType = rowTypes[count];
                if (rowType=="FeedTypeCell"){
                    let row = self.feedTbl.rowController(at: count) as! FeedTypeCell
                    let attributeStr = self.attributesArr![count] as String
                    row.lblFeedType.setText("\(attributeStr)")
                }
                else if (rowType=="FeedNursingCell") {
                    let row = self.feedTbl.rowController(at: count) as! FeedNursingCell
                    row.nursingEventDelegate = self
                    // Check and set previous selected side if any
                    if (self.isBtnLeftSelected == true) {
                        row.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
                        row.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
                        self.changeTextColor(sender: row.btnLeft, txt: "Left", txtColor: (UIColor(hex: Constants.Colors.white)))
                    }else if (self.isBtnRightSelected == true) {
                        row.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
                        row.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
                        self.changeTextColor(sender: row.btnRight, txt: "Right", txtColor: (UIColor(hex: Constants.Colors.white)))
                    }
                    // set left timer value
                    durationLeft = TimeInterval((timerValueLeft * 60)+1)
                    row.timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
                    row.timerDurationLeft.stop()
                    // set right timer value
                    durationRight = TimeInterval((timerValueRight * 60)+1)
                    row.timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
                    row.timerDurationRight.stop()
                }
                
            }
            
        }
        else if (self.feedType == "solids") {
            let rowTypes = ["FeedTypeCell","FeedTypeCell","FeedTypeCell"];
            self.feedTbl.setRowTypes(rowTypes)
            
            for count in 0...rowTypes.count-1 {
                let rowType = rowTypes[count];
                if (rowType=="FeedTypeCell"){
                    let row = self.feedTbl.rowController(at: count) as! FeedTypeCell
                    let attributeStr = self.attributesArr![count] as String
                    row.lblFeedType.setText("\(attributeStr)")
                }
            }
            
        }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice")) {
            if (self.attributesArr?.count != 2) {
                return
            }else {
                if rowIndex == 0 {
                    let dict : [String : Any] = ["Controller" : self,  "context" : self.FeedData!]
                    self.pushController(withName:Constants.Controllers.Feed_Type, context: dict)
                }else if rowIndex == 1 {
                    let dict : [String : Any] = ["Controller" : self,  "type" : "FeedInterface"]
                    self.pushController(withName:Constants.Controllers.Volume, context: dict)
                }
            }
        }
        else if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
            if (self.attributesArr?.count != 2) {
                return
            }else {
                if rowIndex == 0 {
                    let dict : [String : Any] = ["Controller" : self,  "context" : self.FeedData!]
                    self.pushController(withName:Constants.Controllers.Feed_Type, context: dict)
                }else if rowIndex == 1 {
                    let dict : [String : Any] = ["Controller" : self,  "type" : "FeedInterface"]
                    self.pushController(withName:Constants.Controllers.Volume, context: dict)
                }
            }
        }
        else if (self.feedType == "solids") {
            if (self.attributesArr?.count != 3) {
                return
            }else {
                if rowIndex == 0 {
                    let dict : [String : Any] = ["Controller" : self,  "context" : self.FeedData!]
                    self.pushController(withName:Constants.Controllers.Feed_Type, context: dict)
                }else if rowIndex == 1 {
                    let context = ["Controller" : self, "type" : "SolidInterface"] as [String : Any]
                    self.pushController(withName:Constants.Controllers.Feed_Serving_Unit, context: context)
                }else if rowIndex == 2{
                    let context = ["Controller" : self, "type" : "SolidInterface"] as [String : Any]
                    self.pushController(withName:Constants.Controllers.Volume, context: context)
                }
            }
        }
        
    }
    
    // MARK:- Nursing Events Handler delegates
    func btnLeftClicked(nursingCell:FeedNursingCell) {
        if !isPausedRight {
            print("First stop active timer !")
            return
        }
        isBtnLeftSelected = true
        isBtnRightSelected = false
        shouldAddLeftData = true
        nursingCell.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
        nursingCell.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
        self.changeTextColor(sender: nursingCell.btnLeft, txt: "Left", txtColor: (UIColor(hex: Constants.Colors.white)))
        self.changeTextColor(sender: nursingCell.btnRight, txt: "Right", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
    }
    
    func btnRightClicked(nursingCell:FeedNursingCell) {
        if !isPausedLeft {
            print("First stop active timer !")
            return
        }
        isBtnLeftSelected = false
        isBtnRightSelected = true
        shouldAddRightData = true
        nursingCell.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
        nursingCell.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
        self.changeTextColor(sender: nursingCell.btnLeft, txt: "Left", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        self.changeTextColor(sender: nursingCell.btnRight, txt: "Right", txtColor: (UIColor(hex: Constants.Colors.white)))
    }
    
    func timerDurationLeftClicked(nursingCell:FeedNursingCell) {
        
        if (!isBtnLeftSelected) {
            Alert.alertView(message: "Please select side !", controller: self)
            return
        }
        if !isPausedLeft {
            Alert.alertView(message: "Please Stop active timer!", controller: self)
            return
        }
        
        let dict : [String : Any] = ["Controller" : self, "Timer": "timerValueLeft"]
        pushController(withName: Constants.Controllers.Feed_Nursing_Timer, context: dict)
    }
    
    func timerDurationRightClicked(nursingCell:FeedNursingCell) {
        
        if (!isBtnRightSelected) {
            Alert.alertView(message: "Please select side !", controller: self)
            return
        }
        if !isPausedRight {
            Alert.alertView(message: "Please Stop active timer!", controller: self)
            return
        }
        
        let dict : [String : Any] = ["Controller" : self, "Timer": "timerValueRight"]
        pushController(withName: Constants.Controllers.Feed_Nursing_Timer, context: dict)
    }
    
    func timerBtnLeftClicked(nursingCell:FeedNursingCell) {
        
        if (!isBtnLeftSelected) {
            Alert.alertView(message: "Please select side!", controller: self)
            return
        }
        self.valueChanged_NursingTimerLeft = true
        
        if isPausedLeft{
            isPausedLeft = false
            myTimerLeft = Timer.scheduledTimer(timeInterval: 1.0, target: nursingCell, selector: #selector(nursingCell.timerLeft), userInfo: nil, repeats: true)
            nursingCell.timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
            nursingCell.timerDurationLeft.start()
            startTimeLeft = Date()
            self.btnSave.setEnabled(false)
            
            nursingCell.timerBtnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
            self.changeTextColor(sender: nursingCell.timerBtnLeft, txt: "Pause", txtColor: (UIColor(hex: Constants.Colors.white)))
        }
        else{
            isPausedLeft = true
            nursingCell.timerDurationLeft.stop()
            myTimerLeft!.invalidate()
            self.btnSave.setEnabled(true)
            
            nursingCell.timerBtnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
            self.changeTextColor(sender: nursingCell.timerBtnLeft, txt: "Timer", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        }
        
    }
    
    func timerBtnRightClicked(nursingCell:FeedNursingCell) {
        
        if (!isBtnRightSelected) {
            Alert.alertView(message: "Please select side!", controller: self)
            return
        }
        self.valueChanged_NursingTimerRight = true
        
        if isPausedRight{
            isPausedRight = false
            myTimerRight = Timer.scheduledTimer(timeInterval: 1.0, target: nursingCell, selector: #selector(nursingCell.timerRight), userInfo: nil, repeats: true)
            nursingCell.timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
            nursingCell.timerDurationRight.start()
            startTimeRight = Date()
            self.btnSave.setEnabled(false)
            
            nursingCell.timerBtnRight.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
            self.changeTextColor(sender: nursingCell.timerBtnRight, txt: "Pause", txtColor: (UIColor(hex: Constants.Colors.white)))
        }
        else{
            isPausedRight = true
            nursingCell.timerDurationRight.stop()
            myTimerRight!.invalidate()
            self.btnSave.setEnabled(true)
            
            nursingCell.timerBtnRight.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
            self.changeTextColor(sender: nursingCell.timerBtnRight, txt: "Timer", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        }
        
    }
    
    func timerLeft(nursingCell:FeedNursingCell) {
        elapsedTimeLeft += 1.0
        nursingCell.timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
    }
    
    func timerRight(nursingCell:FeedNursingCell) {
        elapsedTimeRight += 1.0
        nursingCell.timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
    }
    
    // MARK:- Custom Methods
    func setScreenData() {
        
        // set default/prev values
        var feedDataDict : [String:Any]?
        if (self.feedInfo?.count)!>0 {
            
            if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice")) {
                if (!self.valueChanged_FBWJ) {
                    if let dict = self.feedInfo!["\(self.feedType)"] {
                        feedDataDict = dict as? [String:Any]
                        self.feedVolume = (feedDataDict!["value"] as? Int)!
                    }
                }
                
            }
            
            if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
                if (!self.valueChanged_NursingTimerLeft) {
                    if let dict = self.feedInfo!["lboob"] {
                        feedDataDict = dict as? [String:Any]
                        self.timerValueLeft = (feedDataDict!["duration"] as? Int)!
                    }
                }
                if (!self.valueChanged_NursingTimerRight) {
                    if let dict = self.feedInfo!["rboob"] {
                        feedDataDict = dict as? [String:Any]
                        self.timerValueRight = (feedDataDict!["duration"] as? Int)!
                    }
                }
            }
            
            if (self.feedType == "solids") {
                if (!self.valueChanged_SolidsVolume) {
                    if let dict = self.feedInfo!["solids"] {
                        feedDataDict = dict as? [String:Any]
                        self.volume = "\((feedDataDict!["value"] as? Float)!)"
                        self.unit = (feedDataDict!["unit"] as? String)!
                    }
                }
            }
            
        }
        
        self.attributesArr?.removeAll()
        self.attributesArr = [String]()
        if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice")) {
            if(self.feedType == "bbottle"){
                self.attributesArr?.append("Breastmilk")
            }else {
                self.attributesArr?.append(self.feedType.capitalized)
            }
            let volumeStr = String(format: "%@ ml", String(self.feedVolume))
            self.attributesArr?.append(volumeStr)
        }
        else if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
            self.attributesArr?.append("Nursing")
            self.attributesArr?.append("SDT")
        }
        else if (self.feedType == "solids") {
            self.attributesArr?.append(self.feedType.capitalized)
            let volumeStr = String(format: "%@", self.volume)
            let unitStr = String(format: "%@", self.unit)
            self.attributesArr?.append(unitStr)
            self.attributesArr?.append(volumeStr)
        }
        
        self.loadTableData()
    }
    
    func getDisplayAmount(value: Int) -> String {
        return "\(value)"
    }
    
    func roundUp(_ value: Double, toNearest: Double) -> Double {
        return ceil(value / toNearest) * toNearest
    }
    
    func changeTextColor(sender:WKInterfaceButton, txt:String, txtColor:UIColor)  {
        let attString = NSMutableAttributedString(string: txt)
        attString.setAttributes([NSAttributedStringKey.foregroundColor: txtColor], range: NSMakeRange(0, attString.length))
        sender.setAttributedTitle(attString)
    }
    
    //    @objc func timerLeft(){
    //        print("LeftTimer")
    //        elapsedTimeLeft += 1.0
    //        //timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
    //    }
    
    //    @objc func timerRight(){
    //        print("RightTimer")
    //        elapsedTimeRight += 1.0
    //        //timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
    //    }
    
    // MARK:- IBActions
    @IBAction func savemethod() {
        
        // For FBWJ
        if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice")) {
            let val = self.feedVolume
            if !(val>0){
                Alert.alertView(message: "Please select volume!", controller: self)
                return
            }
        }
        // For Nursing
        if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
            if (!isBtnLeftSelected && !isBtnRightSelected) {
                Alert.alertView(message: "Please select side!", controller: self)
                return
            }
        }
        // For Solid
        if (self.feedType == "solids") {
            if !(self.unit.count>0){
                Alert.alertView(message: "No data has been entered!", controller: self)
                return
            }
            let sVal = Float(self.volume)
            if !(sVal!>Float(0)){
                Alert.alertView(message: "Please select volume!", controller: self)
                return
            }
        }
        self.callSaveWebservice()
    }
    
    func callSaveWebservice(){
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = "feed"
        paramsDict["notes"] = ""
        
        if ((self.feedType == "bbottle") || (self.feedType == "formula") || (self.feedType == "water") || (self.feedType == "juice")) {
            // For FBWJ
            paramsDict["value"] = Float(self.feedVolume)
            paramsDict["type"] = self.feedType
            paramsDict["unit"] = "ml"
            paramsDict["duration"] = 0
            paramsDict["time"] = Constants.getDate(date: Date())
        }
        else if ((self.feedType == "solids")) {
            // For Solids
            if self.unit == "gm" {
                let val = Int(self.volume)
                paramsDict["value"] = Float(val!)
            }
            else {
                let val = Float(self.volume)
                paramsDict["value"] = val!
            }
            paramsDict["type"] = self.feedType
            paramsDict["unit"] = self.unit
            paramsDict["duration"] = 0
            paramsDict["time"] = Constants.getDate(date: Date())
        }
        else if ((self.feedType == "lboob") || (self.feedType == "rboob") || (self.feedType == "lboob+rboob")) {
            // For Nursing
            let feedDurationValueLeft = timerValueLeft + Int(self.roundUp((elapsedTimeLeft/60), toNearest: 1))
            let feedDurationValueRight = timerValueRight + Int(self.roundUp((elapsedTimeRight/60), toNearest: 1))
            if (!(feedDurationValueLeft>0) && !(feedDurationValueRight>0)) {
                Alert.alertView(message: "No data has been entered!", controller: self)
                return
            }
            
            if (shouldAddLeftData && !shouldAddRightData) {
                
                if !(feedDurationValueLeft>0) {
                    Alert.alertView(message: "No data has been entered!", controller: self)
                    return
                }
                paramsDict["type"]      = "lboob"
                paramsDict["value"]     = feedDurationValueLeft
                paramsDict["unit"]      = "min"
                paramsDict["duration"]  = feedDurationValueLeft
                paramsDict["time"]      = Constants.getDate(date: Date())
            }
            else if (!shouldAddLeftData && shouldAddRightData) {
                
                if !(feedDurationValueRight>0) {
                    Alert.alertView(message: "No data has been entered!", controller: self)
                    return
                }
                paramsDict["type"]      = "rboob"
                paramsDict["value"]     = feedDurationValueRight
                paramsDict["unit"]      = "min"
                paramsDict["duration"]  = feedDurationValueRight
                paramsDict["time"]      = Constants.getDate(date: Date())
            }
            else if (shouldAddLeftData && shouldAddRightData) {
                
                if (!(feedDurationValueLeft>0) || !(feedDurationValueRight>0)) {
                    Alert.alertView(message: "Data is missing!", controller: self)
                    return
                }
                var dictL               = [String:Any]()
                dictL["value"]          = feedDurationValueLeft
                dictL["unit"]           = "min"
                dictL["duration"]       = feedDurationValueLeft
                dictL["time"]           = Constants.getDate(date: Date())
                
                var dictR               = [String:Any]()
                dictR["value"]          = feedDurationValueRight
                dictR["unit"]           = "min"
                dictR["duration"]       = feedDurationValueRight
                dictR["time"]           = Constants.getDate(date: Date())
                
                var dict                = [String:Any]()
                dict["lboob"]           = dictL
                dict["rboob"]           = dictR
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    var jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                    jsonString = jsonString?.trimmingCharacters(in: CharacterSet.whitespaces)
                    jsonString = jsonString?.replacingOccurrences(of: "\n", with: "")
                    jsonString = jsonString?.replacingOccurrences(of: "\\\"", with: "\"")
                    paramsDict["type"] = "lboob+rboob"
                    paramsDict["nursingData"] = jsonString
                } catch {
                    Alert.alertView(message: "\(error.localizedDescription)", controller: self)
                }
            }
        }
        self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            self.stopLoader()
            if (response["success"] as? Bool)!{
                // Get Baby Details
                var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                (babyList![selectedBIndex])["feed_info"] = response["info"]
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                UserDefaults.standard.synchronize()
                self.sendToActivityInterface = true
                self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_feed)
            }
            else {
                Alert.alertView(message: "Failed", controller: self)
            }
        }, errorBlock: { (error) in
            print(error)
        })
        
    }
}

// MARK:- Custom Cells

// Common
class FeedTypeCell : NSObject {
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblFeedType: WKInterfaceLabel!
}

// For Nursing type
protocol nursingEventsHandler : NSObjectProtocol{
    func btnLeftClicked(nursingCell:FeedNursingCell)
    func btnRightClicked(nursingCell:FeedNursingCell)
    func timerDurationLeftClicked(nursingCell:FeedNursingCell)
    func timerDurationRightClicked(nursingCell:FeedNursingCell)
    func timerBtnLeftClicked(nursingCell:FeedNursingCell)
    func timerBtnRightClicked(nursingCell:FeedNursingCell)
    //Timer
    func timerLeft(nursingCell:FeedNursingCell)
    func timerRight(nursingCell:FeedNursingCell)
}

class FeedNursingCell : NSObject {
    weak var nursingEventDelegate : nursingEventsHandler?
    
    @IBOutlet var btnLeft: WKInterfaceButton!
    @IBOutlet var btnRight: WKInterfaceButton!
    @IBOutlet var timerDurationLeft: WKInterfaceTimer!
    @IBOutlet var timerDurationRight: WKInterfaceTimer!
    @IBOutlet var timerBtnLeft: WKInterfaceButton!
    @IBOutlet var timerBtnRight: WKInterfaceButton!
    
    @IBAction func didSelectBtnLeft() {
        nursingEventDelegate?.btnLeftClicked(nursingCell: self)
    }
    @IBAction func didSelectBtnRight() {
        nursingEventDelegate?.btnRightClicked(nursingCell: self)
    }
    @IBAction func didSelectTimerDurationLeft() {
        nursingEventDelegate?.timerDurationLeftClicked(nursingCell: self)
    }
    @IBAction func didSelectTimerDurationRight() {
        nursingEventDelegate?.timerDurationRightClicked(nursingCell: self)
    }
    @IBAction func didSelectTimerBtnLeft() {
        nursingEventDelegate?.timerBtnLeftClicked(nursingCell: self)
    }
    @IBAction func didSelectTimerBtnRight() {
        nursingEventDelegate?.timerBtnRightClicked(nursingCell: self)
    }
    
    // Timers
    @objc func timerLeft(){
        nursingEventDelegate?.timerLeft(nursingCell:self)
    }
    
    @objc func timerRight(){
        nursingEventDelegate?.timerRight(nursingCell: self)
    }
    
}
extension New_FeedInterfaceController {
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
