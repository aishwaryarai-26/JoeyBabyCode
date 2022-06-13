//
//  ReminderInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/21/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ReminderInterfaceController: WKInterfaceController, WKCrownDelegate {

    // MARK:- Outlets
    @IBOutlet var tableViewReminder: WKInterfaceTable!
    @IBOutlet var btnAddAlarm: WKInterfaceButton!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    @IBOutlet var loaderView: WKInterfaceGroup!
    
    // MARK:- Objects
    var session : WCSession!
    var reminderList : [Dictionary<String,Any>] = [[:]]
    var reminder : [ReminderListModel]? = []
    var context : ActivityList?
    
    // MARK:- Interface Controller methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //Set Background Color of Add Button
        self.context = context as? ActivityList
        // Set Navigation Title
        let activityName = self.context?.attribute_name
        setTitle("\(activityName!) Alarms")
        // Set add button background
        let color = setBackgroud(attribute: (self.context?.attribute_name)!)
        self.btnAddAlarm.setBackgroundColor(UIColor(hex: color))
    }

    override func willActivate() {
        super.willActivate()
        if (WCSession.isSupported()) {
            session = WCSession.default
//            session.delegate = self
            session.activate()
        }
        crownSequencer.delegate = self
        crownSequencer.focus()
        
        //Get ReminderList
        self.getReminderList()
        self.stopLoader()
    }
    
     // MARK:- WKCrown Delegate
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        print("rotationalDelta: \(rotationalDelta)")
    }
    
    // MARK:- Custom Methods
    func getReminderList() {

        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["type"] = self.context?.name

       self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.getActivityReminderList, requestDict: paramsDict, headerValue: [:], isHud: true, successBlock: { (success, response) in
            self.stopLoader()
            if response["list"] != nil
            {
                self.reminderList = response["list"] as! [[String:Any]]
                self.reminder = self.reminderList.map { ReminderListModel(dict: $0) }
                print(self.reminderList)
                DispatchQueue.main.async {
                    self.loadData()
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    @objc func switchToggled(notification: NSNotification){
        let dict = notification.object as! Dictionary<String, Any>
        let indexPath = dict["cellIndex"] as! Int
        print(indexPath)
    }
    
    func setBackgroud(attribute: String) -> (String) {
        switch attribute{
        case "Feed"     : return (Constants.Colors.feed)
        case "Poo"      : return (Constants.Colors.poo)
        case "Wee"      : return (Constants.Colors.wee)
        case "Pump"     : return (Constants.Colors.pump)
        case "Medical"  : return (Constants.Colors.medical)
        case "Sleep"    : return (Constants.Colors.sleep)
        default         : return ("")
        }
    }
    
    // MARK:- TableView Implementation
    func loadData(){
        self.tableViewReminder.setNumberOfRows((reminder?.count)!, withRowType: "ReminderListingTableViewCell")
        for (index, reminderData) in (reminder?.enumerated())! {

            let row = tableViewReminder.rowController(at: index) as! ReminderListingTableViewCell
            //Set Time
            let tStr = reminderData.time
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
            let date = formatter.date(from: tStr!)
            formatter.dateFormat = "HH:mm";
            let dateStr = formatter.string(from: date!)
            let timeStr = "\(dateStr)"
            
            row.lblTimeReminder.setText(timeStr)
            //Set type label
            row.lblTypeReminder?.setText(reminderData.name)
            row.switchOnOffReminder?.setOn(!reminderData.disabled_check!)
            // Set Cell Index
            row.cellIndex = index
        }
        
    }
    
    override func table(_: WKInterfaceTable, didSelectRowAt: Int){
        let reminderData = reminder![didSelectRowAt]
        let context = ["attribute" : "Edit", "controller" : self, "context" : reminderData] as [String : Any]
        pushController(withName: Constants.Controllers.Add_Reminder  , context: context)
    }
    
    // MARK:- IBActions
    @IBAction func didSelectAddAlarm(_ sender: WKInterfaceButton) {
        let activityName = (self.context?.attribute_name) ?? ""
        let context = ["attribute" : "Add", "controller" : self, "type" : activityName] as [String : Any]
        pushController(withName: Constants.Controllers.Add_Reminder  , context: context)
    }
}
// MARK:- WKSession Delegates
//extension ReminderInterfaceController : WCSessionDelegate {
//    func sessionDidBecomeInactive(_ session: WCSession) {
//
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//
//    }
//
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void){
//        print(message)
//    }
//
//    @available(iOS 9.3, *)
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
//        print(error?.localizedDescription ?? "Error")
//    }
//}
extension ReminderInterfaceController {
    func showLoader() {
        self.setLoader(hidden: false)
        loader.setImageNamed("loader")
        loader.startAnimatingWithImages(in: NSRange(location: 1,
                                                    length: 8), duration: 0.8, repeatCount: -1)
    }
    func stopLoader() {
        self.loaderView.stopAnimating()
        self.setLoader(hidden: true)
    }
    
    private func setLoader(hidden:Bool) {
        self.loaderView.setHidden(hidden)
        self.group.setHidden(!hidden)
    }
}
