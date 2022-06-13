//
//  AddReminderInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 7/11/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class AddReminderInterfaceController: WKInterfaceController, rowSwitchButtonClicked {
    
    // MARK:- Outlets
    @IBOutlet var btnSetAlarm: WKInterfaceButton!
    @IBOutlet var reminderTbl: WKInterfaceTable!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    @IBOutlet var loaderView: WKInterfaceGroup!
    
    // MARK:- Objects
    var switchValue = true
    var timeValue     : String          = ""
    var repeatValue   : String          = ""
    var alarmTitle    : String          = ""
    
    var hours         : Int?
    var minutes       : Int?
    var timeFormat    : String?
    
    var contextData   : [String: Any]?  = [:]
    var reminderDetails : ReminderListModel?
    var activityType  : String          = ""
    
    var alarmLabelValue = "      "
    // MARK:- Interface Controller methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("")
        
        self.contextData = context as? [String:Any]
        if (self.contextData!["attribute"] as! String == "Edit") {
            setTitle("Edit Alarm")
            self.reminderDetails = self.contextData!["context"] as? ReminderListModel
            // Configure interface objects here.
            let tStr = self.reminderDetails?.time
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
            let date = formatter.date(from: tStr!)
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            let dateComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: date!)
            self.hours = dateComponents.hour
            self.minutes = dateComponents.minute
            self.repeatValue = (self.reminderDetails?.recurrence)!
            self.alarmTitle = "Alarm"
            
            // set button title
            self.btnSetAlarm.setTitle("Delete")
            // Set snooze value
            self.switchValue = !(reminderDetails?.disabled_check)!
            
        }else if (self.contextData!["attribute"] as! String == "Add") {
            setTitle("Add Alarm")
            // Configure interface objects here.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale.init(identifier: "en_US")
            let nowDate = dateFormatter.string(from: Date())
            let dateTime = getDateTimeComponent(date: nowDate)
            self.hours = dateTime.hour
            self.minutes = dateTime.minute
            self.repeatValue = "Never"
            self.alarmTitle = "Alarm"
            
            // set button title
            self.btnSetAlarm.setTitle("Set Alarm")
            // Set default snooze value
            self.switchValue = true
            // set activity type
            self.activityType = self.contextData!["type"] as! String
            
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTime()
        self.loadTableData()
    }
    
    // MARK:- TableView Implementation
    func loadTableData() {
        let rowTypes = ["ReminderCell","ReminderCell","ReminderCell", "ReminderSnoozeCell"];
        self.reminderTbl.setRowTypes(rowTypes)
        
        for count in 0...rowTypes.count-1 {
            let rowType = rowTypes[count];
            if (rowType=="ReminderCell")
            {
                let row = self.reminderTbl.rowController(at: count) as! ReminderCell
                if (count==0) {
                    row.lblTitle.setText("Set Time")
                    row.lblValue.setText(self.timeValue)
                }else if (count==1) {
                    row.lblTitle.setText("Repeat")
                    row.lblValue.setText(self.repeatValue.capitalized)
                }else if (count==2) {
                    row.lblTitle.setText(alarmLabelValue)
                    row.lblValue.setText(self.alarmTitle.capitalized)
                }
            }
            else{
                let row = self.reminderTbl.rowController(at: 3) as! ReminderSnoozeCell
                row.lblSnooze.setText("Snooze")
                row.switchSnooze.setOn(self.switchValue)
                row.delegate = self
            }
        }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if (self.contextData!["attribute"] as! String == "Edit") {
            return
        }
        
        let context = ["controller" : self] as [String : Any]
        if rowIndex == 0 {
            pushController(withName:  Constants.Controllers.Reminder_Set_Time, context: context)
        }else if rowIndex == 1 {
            pushController(withName:  Constants.Controllers.Reminder_Set_Repeat, context: context)
        }else if rowIndex == 2 {
            self.presentTextInputController(withSuggestions: ["Hello","Goodbye","Hey"], allowedInputMode: WKTextInputMode.plain,
                                                           completion:{(results) -> Void in
                                                            let aResult = results?[0] as? String
                                                            print(aResult)
                                                            self.alarmLabelValue = aResult!
                                                            self.loadTableData()
            })
        }
        
    }
    
    // MARK:- IBActions
    @IBAction func btnSetAlarmAction() {
        if (self.contextData!["attribute"] as! String == "Edit") {
            print("Delete Alarm")
            self.callServiceToDeleteReminder()
        }else if (self.contextData!["attribute"] as! String == "Add") {
            print("Set Alarm")
            self.callServiceToAddReminder()
        }
    }
    
    // MARK:- Custom Methods
    func callServiceToAddReminder() {
        
        // set recurrance data
        var repeatValArr = [String]()
        let repeatDaysArr = self.repeatValue.components(separatedBy: ",")
        if (repeatDaysArr.contains("sunday")) {
            repeatValArr.append("0")
        }
        if (repeatDaysArr.contains("monday")) {
            repeatValArr.append("1")
        }
        if (repeatDaysArr.contains("tuesday")) {
            repeatValArr.append("2")
        }
        if (repeatDaysArr.contains("wednesday")) {
            repeatValArr.append("3")
        }
        if (repeatDaysArr.contains("thursday")) {
            repeatValArr.append("4")
        }
        if (repeatDaysArr.contains("friday")) {
            repeatValArr.append("5")
        }
        if (repeatDaysArr.contains("saturday")) {
            repeatValArr.append("6")
        }
        
        if (repeatDaysArr.contains("everyday")) {
            repeatValArr.removeAll()
            repeatValArr.append("0")
            repeatValArr.append("1")
            repeatValArr.append("2")
            repeatValArr.append("3")
            repeatValArr.append("4")
            repeatValArr.append("5")
            repeatValArr.append("6")
        }
        
        if (repeatDaysArr.contains("weekdays")) {
            repeatValArr.removeAll()
            repeatValArr.append("1")
            repeatValArr.append("2")
            repeatValArr.append("3")
            repeatValArr.append("4")
            repeatValArr.append("5")
        }
        
        if (repeatDaysArr.contains("weekends")) {
            repeatValArr.removeAll()
            repeatValArr.append("6")
            repeatValArr.append("0")
        }
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = self.activityType
        paramsDict["type"] = self.activityType
        paramsDict["recurrence"] = repeatValArr.joined(separator: ",")
        
        let cal = Calendar.current
        var component = cal.dateComponents([.year, .month, .weekOfYear, .weekday], from: Date())
        component.hour = self.hours
        component.minute = self.minutes
        var selDateTime = cal.date(from: component)
        paramsDict["time"] = self.getDateString(date: selDateTime!)
        self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addActivityReminder, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            self.stopLoader()
            if (response["success"] as? Bool)!{
                
                let reminderId = "\(response["id"] ?? 0)"
                
                if(repeatValArr.count==0)
                {
                    let dateDiffValue = selDateTime?.compare(Date())
                    if(dateDiffValue!.rawValue<0){
                        print("Past Time")
                        // set time to next day
                        selDateTime = selDateTime?.addingTimeInterval(24*60*60)
                    }
                    self.registerLocalNotificationsWithTime(rID: reminderId, nDate: selDateTime!, babyName: babydetails["name"] as! String, repeatsReminder: false)
                    
                }else {
                    
                    for day in repeatValArr{
                        let weekDay = Int(day)! + 1
                        if((weekDay != 0)&&(component.weekday!>weekDay)){
                            component.weekOfYear! += 1
                        }
                        component.weekday = weekDay
                        component.hour = self.hours
                        component.minute = self.minutes
                        self.registerLocalNotificationsWithTime(rID: reminderId, nDate: selDateTime!, babyName: babydetails["name"] as! String, repeatsReminder: true)
                    }
                    
                }
                self.pop()
            }
            else {
                print("failed !")
            }
        }, errorBlock: { (error) in
            print(error)
        })
        
    }
    
    func callServiceToDeleteReminder() {
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["id"] = self.reminderDetails?.id
        
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.deleteActivityReminder, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            
            if (response["success"] as? Bool)!{
                self.deleteReminderFromDevice()
            }
            else {
                print("failed !")
            }
        }, errorBlock: { (error) in
            print(error)
        })
        
    }
    
    func setTime(){
        if (hours! < 12) {
            self.timeFormat = "AM"
        }else if (hours! > 12){
            self.timeFormat = "PM"
            if(hours!>=24){
                hours = hours!-12
            }
        }else {
            self.timeFormat = "PM"
        }
        self.timeValue = String(format: "%02d:%02d", hours!,minutes!)
    }
    
    func deleteReminderFromDevice() {
        print("delete")
        let reminderId = "\(self.reminderDetails?.id ?? 0)"
        var notiRequestIdentifier = String(format: "reminder_%@", reminderId)
        if (((self.reminderDetails?.recurrence) != nil) && (self.reminderDetails?.recurrence?.count)!>0) {
            notiRequestIdentifier = String(format: "repeating_reminder_%@", reminderId)
        }
        
        var pendingList = Array<String>()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
                for obj in notifications {
                    if (obj.identifier == notiRequestIdentifier) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notiRequestIdentifier])
                        pendingList.append(obj.identifier)
                    }
                }
                print(pendingList)
                self.pop()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func rowClicked(value:Bool){
        print(value)
        self.switchValue = value
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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let dateStr = dateFormatter.string(from: date)
        print("\(dateStr)")
        return dateStr
    }
    
    func registerLocalNotificationsWithTime(rID:String, nDate:Date, babyName:String, repeatsReminder:Bool) {
        
        let cal = Calendar.current
        let component = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nDate)
        
        let tInterval = (cal.date(from: component)?.timeIntervalSinceNow)!
        let localTrigger = UNTimeIntervalNotificationTrigger(timeInterval: tInterval, repeats: repeatsReminder)
        
        let content = UNMutableNotificationContent()
        content.title = String("[\(babyName)]-Reminder")
        content.body = self.activityType
        
        //var notiRequestIdentifier = self.getTimestampInMillis()
        var notiRequestIdentifier = String(format: "reminder_%@", rID)
        content.categoryIdentifier = UserNotificationCategory.primaryMode.rawValue
        if (repeatsReminder) {
            content.categoryIdentifier = UserNotificationCategory.repeating.rawValue
            notiRequestIdentifier = String(format: "repeating_reminder_%@", rID)
        }
        content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
        let request = UNNotificationRequest(identifier:notiRequestIdentifier, content: content, trigger: localTrigger)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    Alert.alertView(message: "\(error.localizedDescription)", controller: self)
                } else {
                    Alert.alertView(message: "\(self.activityType) Notfication is scheduled", controller: self)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func getTimestampInMillis() -> Int64! {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
}
extension AddReminderInterfaceController {
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
class ReminderCell : NSObject {
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblTitle: WKInterfaceLabel!
    @IBOutlet var lblValue: WKInterfaceLabel!
}

protocol rowSwitchButtonClicked : NSObjectProtocol{
    func rowClicked(value:Bool)
}

class ReminderSnoozeCell : NSObject {
    weak var delegate : rowSwitchButtonClicked?
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblSnooze: WKInterfaceLabel!
    @IBOutlet var switchSnooze: WKInterfaceSwitch!
    
    @IBAction func toggleSnooze(_ value: Bool) {
        delegate?.rowClicked(value: value)
    }
}

