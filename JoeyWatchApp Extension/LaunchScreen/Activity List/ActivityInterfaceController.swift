//
//  ActivityInterfaceController.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/16/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ActivityInterfaceController: WKInterfaceController,WCSessionDelegate,WKCrownDelegate {
    
    private var session : WCSession!
    private var arrFriendList  : NSArray = []
    private var activityList : [Dictionary<String,Any>] = [[:]]
    private var activities : [ActivityList]? = []
    private var selectedBabyDict : Dictionary<String,Any> = [:]
    private var contextData : [String: Any]? = [:]
    @IBOutlet var tableViewActivity: WKInterfaceTable!
    @IBOutlet var loaderView: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.contextData = context as? [String:Any]
        self.selectedBabyDict = self.contextData![Keys.babiesDict] as! Dictionary<String, Any>
        self.setTitle("\(self.selectedBabyDict[Keys.name] ?? "")")       
        
    }
    
    override func willActivate() {
        super.willActivate()
        // get activity list
        self.getActivityList()
    
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        crownSequencer.delegate = self
        crownSequencer.focus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ActivityInterfaceController.alarmClicked(notification:)), name: Notification.Name("alarmClicked"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ActivityInterfaceController.flashClicked(notification:)), name: Notification.Name("flashClicked"), object: nil)
    }
    
    override func willDisappear() {
        print("willDisappear")
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Webservice Call
extension ActivityInterfaceController {
    func getActivityList() {
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: Keys.selected_baby)
        let babydetails = babyList![selectedBIndex]
        
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["limit"] = "30"
        paramsDict["offset"] = "0"
        self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.getActivityList, requestDict: paramsDict, headerValue: [:], isHud: true, successBlock: { (success, response) in
            
            if response["list"] != nil
            {
                self.activityList = response["list"] as! [[String:Any]]
                self.activities = self.activityList.map { ActivityList(dict: $0) }
                print(self.activityList)
            }
            DispatchQueue.main.async {
                self.loadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    
    
    
    // Tableview delegate
        func loadData(){
        stopLoader()
            
        self.tableViewActivity.setNumberOfRows((activities?.count)!, withRowType: "ActivityTableViewCell")
        for (index, name) in (activities?.enumerated())! {
            
            let row = tableViewActivity.rowController(at: index) as! ActivityTableViewCell
            //Set Time
            var strMut = NSMutableAttributedString()
            let timeStr = name.time!
            strMut =  NSMutableAttributedString(string: timeStr, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0, weight: .medium)])
            strMut.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10.0, weight: .medium)], range: NSMakeRange(6,2))
            row.lblTimeActivity.setAttributedText(strMut)
            
            // Set minute ago label
            if let diffStr = name.diff {
                if diffStr.count>0 {
                    row.lblMinAgoActivity?.setText("\(diffStr) ago")
                }else {
                    row.lblMinAgoActivity?.setText("\(diffStr)")
                }
            }

            //Set value label
            row.lblValueActivity?.setText(name.attribute_value)

            //Set type label
            row.lblTypeActivity?.setText("")
            if(name.name == "sleep") {
                
                if ((name.diff?.count)!>0) {
                    if (name.type == "sleep_cycle") {
                        if let attVal = name.attribute_value{
                            row.lblTypeActivity?.setText("Awake")
                            row.lblValueActivity?.setText("Last: \(attVal)")
                        }
                    }else {
                        row.lblTypeActivity?.setText("Sleeping")
                        row.lblValueActivity?.setText("")
                    }
                }
                else {
                    row.lblTypeActivity?.setText("")
                    row.lblValueActivity?.setText("")
                }
            }

            //Set Background Color of the cell
            let color = setBackgroud(attribute: name.attribute_name!)
            row.mainGroup.setBackgroundColor(UIColor(hex: color.0))
            row.imgActivityTypeActivity.setImageNamed(color.1)
            
            // Set Cell Index
            row.cellIndex = index
        }
            
    }
    
    func setBackgroud(attribute: String) -> (String,String) {
        switch attribute{
        case "Feed"     : return (Constants.Colors.feed     , Constants.Images.activity_feed)
        case "Poo"      : return (Constants.Colors.poo      , Constants.Images.activity_poo)
        case "Wee"      : return (Constants.Colors.wee      , Constants.Images.activity_wee)
        case "Pump"     : return (Constants.Colors.pump     , Constants.Images.activity_pump)
        case "Medical"  : return (Constants.Colors.medical  , Constants.Images.activity_medical)
        case "Med"      : return (Constants.Colors.medical  , Constants.Images.activity_medical)
        case "Sleep"    : return (Constants.Colors.sleep    , Constants.Images.activity_sleep)
        default         : return ("", "")
        }
    }
    
    override func table(_: WKInterfaceTable, didSelectRowAt: Int){
        
        let context = activities![didSelectRowAt]
        switch context.name!.capitalized {
        case "Feed"     : pushController(withName: Constants.Controllers.New_FeedInterfaceController       , context: context)
        case "Poo"      : pushController(withName: Constants.Controllers.Poo        , context: context)
        case "Wee"      : pushController(withName: Constants.Controllers.Wee        , context: context)
        case "Pump"     : pushController(withName: Constants.Controllers.Pump       , context: context)
        case "Medical"  : pushController(withName: Constants.Controllers.Medicine   , context: context)
        case "Sleep"    : pushController(withName: Constants.Controllers.Sleep      , context: context)
        default         : break
            
        }
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void){
        print(message)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
        print(error?.localizedDescription ?? "")
    }
    
}

//MARK:- Actions
extension ActivityInterfaceController {
    @objc func methodOfReceivedNotification(notification: NSNotification){
        let dict = notification.object as! Dictionary<String, Any>
        let indexPath = dict["cellIndex"] as! Int
        print(indexPath)
    }
    
    
    @objc func alarmClicked(notification: NSNotification){
        let dict = notification.object as! Dictionary<String, Any>
        let indexPath = dict["cellIndex"] as! Int
        print(indexPath)
        let context = activities![indexPath]
        pushController(withName: Constants.Controllers.Reminder, context: context)
    }
    
    @objc func flashClicked(notification: NSNotification) {
        let dict = notification.object as! Dictionary<String, Any>
        let indexPath = dict["cellIndex"] as! Int
        print(indexPath)
    }
}
extension ActivityInterfaceController {
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
        self.tableViewActivity.setHidden(!hidden)
    }
}

