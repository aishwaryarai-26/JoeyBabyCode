//
//  SleepInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/19/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class SleepInterfaceController: WKInterfaceController {

    @IBOutlet var lblHeader     : WKInterfaceLabel!
    @IBOutlet var btndate       : WKInterfaceButton!
    @IBOutlet var lblTime       : WKInterfaceLabel!
    @IBOutlet var loader        : WKInterfaceImage!
    @IBOutlet var group         : WKInterfaceGroup!
    @IBOutlet var loaderView    : WKInterfaceGroup!
    var sleepData               : ActivityList?
    var sleepInfo               : [String:Any]?

    var hours                   : Int?
    var minutes                 : Int?
    var timeFormat              : String?
    
    var date                    : Int?
    var month                   : Int?
    var year                    : Int?
    
    var sleepStartDate                   : Date?
    var selectedBabyIndex                    : Int?
    var cycle                   : Bool?
    
    var sendToActivityInterface     : Bool          = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Sleep")
        
        sleepData = context as? ActivityList
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        
        self.sleepInfo = ((babyList[self.selectedBabyIndex!])["sleep_info"]) as? [String : Any]
        print(self.sleepInfo!)

        if (sleepData?.type == "sleeping"){
            lblHeader.setText("End")
            cycle = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale.init(identifier: "en_US")
            let createdDate = dateFormatter.date(from: (sleepData?.created_at)!)
            let dateStr = dateFormatter.string(from: createdDate!)
            let dateTime = getDateTimeComponent(date: dateStr)
            hours = dateTime.hour
            minutes = dateTime.minute
            date = dateTime.day
            month = dateTime.month
            year = dateTime.year
            
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            sleepStartDate = calendar.date(from: dateTime)
        }
        else{
            lblHeader.setText("Start")
            cycle = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale.init(identifier: "en_US")
            let nowDate = dateFormatter.string(from: Date())
            let dateTime = getDateTimeComponent(date: nowDate)
            hours = dateTime.hour
            minutes = dateTime.minute
            date = dateTime.day
            month = dateTime.month
            year = dateTime.year
            
        }

    }

    override func willActivate() {
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        setTime()
        setDate()
        self.stopLoader()
    }

    @IBAction func timeClicked() {
        let dict = ["Controller" : self] as [String : Any]
        pushController(withName: Constants.Controllers.Sleep_Set_Time, context: dict)
    }
    @IBAction func dateClicked() {
        let dict = ["Controller" : self ]
        pushController(withName: Constants.Controllers.Sleep_Set_Date, context: dict)
    }
    @IBAction func saveClicked() {
        callWebservice()
    }
    
    func callWebservice(){
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = "sleep"
        paramsDict["unit"] = "min"
        paramsDict["value"] = 0
        paramsDict["notes"] = ""
        
        // get date from selected components
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        var dateComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: Date())
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = date
        dateComponents.hour = hours
        if (timeFormat == "PM") {
            dateComponents.hour = hours!+12
        }
        dateComponents.minute = minutes
        let selectedDate = calendar.date(from: dateComponents)
        
        if (sleepData?.type == "sleeping") {
            // End
            let diffInMinutes = calendar.dateComponents([.minute], from: sleepStartDate!, to: selectedDate!).minute
            if (diffInMinutes!<0) {
                Alert.alertView(message: "You can not set the end time prior to start time !!", controller: self)
                return
            }
            paramsDict["type"] = "sleep_cycle"
            paramsDict["duration"] = diffInMinutes
            paramsDict["value"] = diffInMinutes
            paramsDict["id"] = sleepData?.id
            if let note = sleepData?.notes {
                paramsDict["notes"] = note
            }
        }
        else {
            // Start
            paramsDict["type"] = "sleeping"
            paramsDict["value"] = 0
        }
        paramsDict["time"] = self.getDateString(date: selectedDate!)
        
        if (sleepData?.type == "sleeping"){
            
           self.showLoader()
            WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.editBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
                print(response)
                self.stopLoader()
                if (response["success"] as? Bool)!{
                    // Get Baby Details
                    var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                    (babyList![selectedBIndex])["sleep_info"] = response["info"]
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                    UserDefaults.standard.synchronize()
                    self.sendToActivityInterface = true
                    self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_sleep)
                    
                }else {
                    Alert.alertView(message: "failed!", controller: self)
                }
                
            }, errorBlock: { (error) in
                print(error)
            })
            
        }
        else {
            
           self.showLoader()
            WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
                print(response)
                self.stopLoader()
                if (response["success"] as? Bool)!{
                    // Get Baby Details
                    var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                    (babyList![selectedBIndex])["sleep_info"] = response["info"]
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                    UserDefaults.standard.synchronize()
                    self.sendToActivityInterface = true
                    self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_sleep)
                    
                }else {
                    Alert.alertView(message: "failed!", controller: self)
                }
                
            }, errorBlock: { (error) in
                print(error)
            })
        }
    }
    
    func setTime(){
        
        if (hours! < 12) {
            timeFormat = "AM"
        }else if (hours! > 12){
            hours! = hours!%12;
            timeFormat = "PM"
        }else {
            timeFormat = "PM"
        }

        //lblTime.setText("\(hours!):\(minutes!) \(timeFormat!)")
        lblTime.setText(String(format: "%02d:%02d %@", hours!,minutes!,timeFormat!))
    }
    
    func setDate(){
        
        //btndate.setTitle("\(self.date!)-\(month!)-\(year!)")
        btndate.setTitle(String(format: "%02d-%02d-%d", date!,month!,year!))
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        var dateComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: Date())
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = date
        dateComponents.hour = hours
        dateComponents.minute = minutes
        
        if let dte =  calendar.date(from: dateComponents){
            let isToday = calendar.isDateInToday(dte)
            if isToday {
                btndate.setTitle("Today")
            }
        }
    }
    
    func getDateTimeComponent(date : String!) -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        let dateObj = dateFormatter.date(from: date)
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: dateObj!)
        return dateComponents
    }
    
    func getDateString(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let dateStr = dateFormatter.string(from: date)
        print("\(dateStr)")
        return dateStr
    }

}
extension SleepInterfaceController {
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
