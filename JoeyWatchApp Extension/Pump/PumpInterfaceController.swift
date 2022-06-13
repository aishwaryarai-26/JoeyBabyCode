//
//  PumpInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation

class PumpInterfaceController: WKInterfaceController {
    
    @IBOutlet var btnLeft : WKInterfaceButton!
    @IBOutlet var btnRight : WKInterfaceButton!
    @IBOutlet var timerDurationLeft : WKInterfaceTimer!
    @IBOutlet var timerDurationRight : WKInterfaceTimer!
    @IBOutlet var timerBtnLeft : WKInterfaceButton!
    @IBOutlet var timerBtnRight : WKInterfaceButton!
    @IBOutlet var volumeBtnLeft : WKInterfaceButton!
    @IBOutlet var volumeBtnRight : WKInterfaceButton!
    @IBOutlet var btnSave : WKInterfaceButton!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    @IBOutlet var loaderView: WKInterfaceGroup!
    
    var shouldAddLeftData                      = false
    var shouldAddRightData                      = false
    var isBtnLeftSelected                      = false
    var isBtnRightSelected                      = false
    var myTimerLeft        : Timer?
    var myTimerRight        : Timer?
    var isPausedLeft                      = true
    var isPausedRight                      = true //flag to determine if it is paused or not
    var elapsedTimeLeft    : TimeInterval = 0.0
    var elapsedTimeRight    : TimeInterval = 0.0 //time that has passed between pause/resume
    var startTimeLeft                     = Date()
    var startTimeRight                     = Date()
    var durationLeft        : TimeInterval = 0.0
    var durationRight       : TimeInterval = 0.0
    var timerValueLeft     : Int          = 0
    var timerValueRight     : Int          = 0
    var volumeValueLeft     : String          = "0"
    var volumeValueRight     : String          = "0"
    
    var pumpData     : ActivityList?
    var pumpInfo      : [String:Any]?
    var selectedBabyIndex     : Int          = 0
    
    var sendToActivityInterface     : Bool          = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Pump")
        self.pumpData = context as? ActivityList
        print(self.pumpData!)
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        self.pumpInfo = ((babyList[self.selectedBabyIndex])["pump_info"]) as? [String : Any]
        print(self.pumpInfo!)
        
        var pumpDataDict : [String:Any]?
        
        if (self.pumpInfo?.count)!>0 {
            if let dict = self.pumpInfo!["left"] {
                pumpDataDict = dict as? [String:Any]
                self.timerValueLeft = (pumpDataDict!["duration"] as? Int)!
                self.volumeValueLeft = "\((pumpDataDict!["value"] as? Float)!)"
            }
            if let dict = self.pumpInfo!["right"] {
                pumpDataDict = dict as? [String:Any]
                self.timerValueRight = (pumpDataDict!["duration"] as? Int)!
                self.volumeValueRight = "\((pumpDataDict!["value"] as? Float)!)"
            }
        }
        
        print(self.timerValueLeft)
        print(self.timerValueRight)
    }
    
    override func willActivate() {
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        setupTimerLeft()
        setupTimerRight()
        setupVolumeLeft()
        setupVolumeRight()
        self.stopLoader()
    }
    
    override func willDisappear() {
        self.myTimerLeft?.invalidate()
        self.myTimerRight?.invalidate()
    }
    
    //MARK: - IBActions Actions
    @IBAction func btnLeftClicked() {
        if !isPausedRight {
            print("First stop active timer !")
            return
        }
        isBtnLeftSelected = true
        isBtnRightSelected = false
        shouldAddLeftData = true
        self.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
        self.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.pump)))
        self.changeTextColor(sender: self.btnLeft, txt: "Left", txtColor: (UIColor(hex: Constants.Colors.white)))
        self.changeTextColor(sender: self.btnRight, txt: "Right", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
    }
    
    @IBAction func btnRightClicked() {
        if !isPausedLeft {
            print("First stop active timer !")
            return
        }
        isBtnLeftSelected = false
        isBtnRightSelected = true
        shouldAddRightData = true
        self.btnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.pump)))
        self.btnRight.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
        self.changeTextColor(sender: self.btnLeft, txt: "Left", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        self.changeTextColor(sender: self.btnRight, txt: "Right", txtColor: (UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func timerDurationLeftClicked() {
        
        if (!isBtnLeftSelected) {
            print("Please select side !")
            return
        }
        if !isPausedLeft {
            print("Please Stop active timer!")
            return
        }
        
        let dict : [String : Any] = ["Controller" : self, "Timer": "timerValueLeft"]
        pushController(withName: Constants.Controllers.Pump_Set_Timer, context: dict)
    }
    
    @IBAction func timerDurationRightClicked() {
        
        if (!isBtnRightSelected) {
            print("Please select side !")
            return
        }
        if !isPausedRight {
            print("Please Stop active timer!")
            return
        }
        
        let dict : [String : Any] = ["Controller" : self, "Timer": "timerValueRight"]
        pushController(withName: Constants.Controllers.Pump_Set_Timer, context: dict)
    }
    
    @IBAction func timerBtnLeftClicked() {
        
        if (!isBtnLeftSelected) {
            print("Please select side !")
            return
        }
        
        if isPausedLeft{
            isPausedLeft = false
            myTimerLeft = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PumpInterfaceController.timerLeft), userInfo: nil, repeats: true)
            timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
            timerDurationLeft.start()
            startTimeLeft = Date()
            self.btnSave.setEnabled(false)
            
            self.timerBtnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
            self.changeTextColor(sender: self.timerBtnLeft, txt: "Pause", txtColor: (UIColor(hex: Constants.Colors.white)))
        }
        else{
            isPausedLeft = true
            timerDurationLeft.stop()
            myTimerLeft!.invalidate()
            self.btnSave.setEnabled(true)
            
            self.timerBtnLeft.setBackgroundColor((UIColor(hex: Constants.Colors.pump)))
            self.changeTextColor(sender: self.timerBtnLeft, txt: "Timer", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        }
        
    }
    
    @IBAction func timerBtnRightClicked() {
        
        if (!isBtnRightSelected) {
            print("Please select side !")
            return
        }
        
        if isPausedRight{
            isPausedRight = false
            myTimerRight = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PumpInterfaceController.timerRight), userInfo: nil, repeats: true)
            timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
            timerDurationRight.start()
            startTimeRight = Date()
            self.btnSave.setEnabled(false)
            
            self.timerBtnRight.setBackgroundColor((UIColor(hex: Constants.Colors.labelColor)))
            self.changeTextColor(sender: self.timerBtnRight, txt: "Pause", txtColor: (UIColor(hex: Constants.Colors.white)))
        }
        else{
            isPausedRight = true
            timerDurationRight.stop()
            myTimerRight!.invalidate()
            self.btnSave.setEnabled(true)
            
            self.timerBtnRight.setBackgroundColor((UIColor(hex: Constants.Colors.pump)))
            self.changeTextColor(sender: self.timerBtnRight, txt: "Timer", txtColor: (UIColor(hex: Constants.Colors.labelColor)))
        }
        
    }
    
    @IBAction func volumeBtnLeftClicked() {
        
        if (!isBtnLeftSelected) {
            print("Please select side !")
            return
        }
        if !isPausedLeft {
            print("Please Stop active timer!")
            return
        }
        let dict : [String : Any] = ["Controller" : self, "Volume": "volumeValueLeft"]
        pushController(withName: Constants.Controllers.Pump_Set_Volume, context: dict)
        
    }
    
    @IBAction func volumeBtnRightClicked() {
        
        if (!isBtnRightSelected) {
            print("Please select side !")
            let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
            self.presentAlert(withTitle: "Joey", message: "Please select side !", preferredStyle: .alert, actions: [ok])
            return
        }
        if !isPausedRight {
            print("Please Stop active timer!")
            return
        }
        let dict : [String : Any] = ["Controller" : self, "Volume": "volumeValueRight"]
        pushController(withName: Constants.Controllers.Pump_Set_Volume, context: dict)
        
    }
    
    @objc func timerLeft(){
        print("LeftTimer")
        elapsedTimeLeft += 1.0
        timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
    }
    
    @objc func timerRight(){
        print("RightTimer")
        elapsedTimeRight += 1.0
        timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
    }
    
    @IBAction func saveClicked() {
        print("saveClicked")
        if (!isBtnLeftSelected && !isBtnRightSelected) {
            let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
            self.presentAlert(withTitle: "Joey", message: "Please select side !", preferredStyle: .alert, actions: [ok])
            print("Please select side !")
            return
        }
        self.callSaveWebservice()
    }
    
    func callSaveWebservice(){
        
        let pumpDurationValueLeft = timerValueLeft + Int(self.roundUp((elapsedTimeLeft/60), toNearest: 1))
        let pumpDurationValueRight = timerValueRight + Int(self.roundUp((elapsedTimeRight/60), toNearest: 1))
        if (!(pumpDurationValueLeft>0) && !(pumpDurationValueRight>0)) {
            let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
            self.presentAlert(withTitle: "Joey", message: "No data has been entered !", preferredStyle: .alert, actions: [ok])
            
            return
        }
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = "pump"
        paramsDict["notes"] = ""
        
        if (shouldAddLeftData && !shouldAddRightData) {
            
            if !(pumpDurationValueLeft>0) {
                let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
                self.presentAlert(withTitle: "Joey", message: "No data has been entered!", preferredStyle: .alert, actions: [ok])
                
                return
            }
            paramsDict["type"] = "left"
            paramsDict["value"] = volumeValueLeft
            paramsDict["unit"] = "ml"
            paramsDict["duration"] = pumpDurationValueLeft
            paramsDict["time"] = Constants.getDate(date: Date())
        }
        else if (!shouldAddLeftData && shouldAddRightData) {
            
            if !(pumpDurationValueRight>0) {
                Alert.alertView(message: "No data has been entered!", controller: self)
                return
            }
            paramsDict["type"] = "right"
            paramsDict["value"] = volumeValueRight
            paramsDict["unit"] = "ml"
            paramsDict["duration"] = pumpDurationValueRight
            paramsDict["time"] = Constants.getDate(date: Date())
        }
        else if (shouldAddLeftData && shouldAddRightData) {
            
            if (!(pumpDurationValueLeft>0) || !(pumpDurationValueRight>0)) {
                Alert.alertView(message:"Data is missing!", controller: self)
                return
            }
            var dictL = [String:Any]()
            dictL["value"] = volumeValueLeft
            dictL["unit"] = "ml"
            dictL["duration"] = pumpDurationValueLeft
            dictL["time"] = Constants.getDate(date: Date())
            
            var dictR = [String:Any]()
            dictR["value"] = volumeValueRight
            dictR["unit"] = "ml"
            dictR["duration"] = pumpDurationValueRight
            dictR["time"] = Constants.getDate(date: Date())
            
            var dict = [String:Any]()
            dict["left"] = dictL
            dict["right"] = dictR
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                var jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                jsonString = jsonString?.trimmingCharacters(in: CharacterSet.whitespaces)
                jsonString = jsonString?.replacingOccurrences(of: "\n", with: "")
                jsonString = jsonString?.replacingOccurrences(of: "\\\"", with: "\"")
                paramsDict["type"] = "left+right"
                paramsDict["nursingData"] = jsonString
            } catch {
                let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
                self.presentAlert(withTitle: "Joey", message: "\(error.localizedDescription)", preferredStyle: .alert, actions: [ok])
                
            }
            
        }
        
       self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            self.stopLoader()
            if (response["success"] as? Bool)!{
                // Get Baby Details
                var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                (babyList![selectedBIndex])["pump_info"] = response["info"]
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                UserDefaults.standard.synchronize()
                self.sendToActivityInterface = true
                self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_pump)
            }
            else {
                Alert.alertView(message:"failed!", controller: self)
            }
        }, errorBlock: { (error) in
            print(error)
        })
        
    }
    
    //Custom Method
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
    
    func setupTimerLeft() {
        durationLeft = TimeInterval((timerValueLeft * 60)+1)
        timerDurationLeft.setDate(Date(timeIntervalSinceNow: durationLeft + elapsedTimeLeft))
        timerDurationLeft.stop()
    }
    
    func setupTimerRight() {
        durationRight = TimeInterval((timerValueRight * 60)+1)
        timerDurationRight.setDate(Date(timeIntervalSinceNow: durationRight + elapsedTimeRight))
        timerDurationRight.stop()
    }
    
    func setupVolumeLeft() {
        
        let valStr = self.volumeValueLeft
        self.volumeBtnLeft.setTitle("\(valStr) ml")
        
        if valStr.contains("."){
            let seperatedValues = valStr.split(separator: ".")
            
            if seperatedValues.count>1 {
                let val = seperatedValues.last!
                if val == "0" {
                    self.volumeValueLeft = "\(seperatedValues.first!)"
                    self.volumeBtnLeft.setTitle("\(seperatedValues.first!) ml")
                }else {
                    self.volumeBtnLeft.setTitle("\(valStr) ml")
                }
            }
            else {
                let val = seperatedValues.first!
                self.volumeBtnLeft.setTitle("\(val) ml")
            }
            
        }
    }
    
    func setupVolumeRight() {
        
        let valStr = self.volumeValueRight
        self.volumeBtnRight.setTitle("\(valStr) ml")
        
        if valStr.contains("."){
            let seperatedValues = valStr.split(separator: ".")
            
            if seperatedValues.count>1 {
                let val = seperatedValues.last
                if val == "0" {
                    self.volumeValueRight = "\(seperatedValues.first!)"
                    self.volumeBtnRight.setTitle("\(seperatedValues.first!) ml")
                }else {
                    self.volumeBtnRight.setTitle("\(valStr) ml")
                }
            }
            else {
                let val = seperatedValues.first!
                self.volumeBtnRight.setTitle("\(val) ml")
            }
            
        }
    }
    
}
extension PumpInterfaceController {
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
        self.loader.setHidden(hidden)
        self.group.setHidden(!hidden)
    }
}
