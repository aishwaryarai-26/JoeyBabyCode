//
//  LaunchScreenInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/22/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class LaunchScreenInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var wkSession : WCSession!
    var userEmail = ""
    var userPassword = ""
    var userId : Int?
    var accessToken : String?
    var user : UserInfo?
    @IBOutlet var logo: WKInterfaceGroup!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if (WCSession.isSupported()) {
            wkSession = WCSession.default
            wkSession.delegate = self
            wkSession.activate()
        }
        logo.setCornerRadius(15)
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        let user_id = UserDefaults.standard.integer(forKey: "wk_user_id")
        if  user_id != 0{
            
            DispatchQueue.main.async {
                let emptyDict: NSDictionary = NSDictionary()
                self.user = UserInfo.init(dict: emptyDict as! [String : Any])
                self.user?.user_id = UserDefaults.standard.integer(forKey: "wk_user_id")
                self.user?.user_name = UserDefaults.standard.string(forKey: "wk_user_name")
                self.user?.user_email = UserDefaults.standard.string(forKey: "wk_user_email")
                self.user?.access_token = UserDefaults.standard.string(forKey: "wk_access_token")
                self.user?.email_confirm_check = UserDefaults.standard.bool(forKey: "wk_email_confirm_check")
                let babyList = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)
                self.user?.baby_list = babyList as? [Dictionary<String, Any>]
                //print(self.user!)
                self.pushController(withName: Constants.Controllers.Baby_Select, context: self.user)
            }
            
        }else {
//            let okAction = WKAlertAction(title: "Ok", style: WKAlertActionStyle.default){
//                //self.dismiss()
//            }
//            presentAlert(withTitle: "User not found !", message: "Please login from your iPhone app.", preferredStyle: WKAlertControllerStyle.alert, actions:[okAction])
//            print("User not found !")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // MARK: WebService Calls
    func callLoginServiceWithInfo (userInfo: [String : Any]) {
        
        var paramsDict = [:] as! Dictionary<String,String>
        paramsDict["email"] = userInfo["email"] as? String
        paramsDict["password"] = userInfo["password"] as? String
        //paramsDict["device_token"] = ""

        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.userlogin, requestDict: paramsDict, headerValue: [:], isHud: true, successBlock: { (success, response) in
            if (response["success"] as! Bool){
                
                let emptyDict: NSDictionary = NSDictionary()
                self.user = UserInfo.init(dict: emptyDict as! [String : Any])
                self.user?.user_id = response["id"] as? Int
                self.user?.user_name = response["name"] as? String
                self.user?.user_email = response["user_email"] as? String
                self.user?.access_token = response["access_token"]as? String
                self.user?.email_confirm_check = response["email_confirm_check"]as? Bool
                self.user?.baby_list = response["baby_list"] as? [Dictionary<String, Any>]
                
                DispatchQueue.main.async() {
                    UserDefaults.standard.set(response["id"] as? Int , forKey: "wk_user_id")
                    UserDefaults.standard.set(response["name"] as? String , forKey: "wk_user_name")
                    UserDefaults.standard.set(response["user_email"] as? String , forKey: "wk_user_email")
                    UserDefaults.standard.set(response["access_token"]as? String , forKey: "wk_access_token")
                    UserDefaults.standard.set(response["email_confirm_check"]as? Bool , forKey: "wk_email_confirm_check")
                    let babyList = response["baby_list"] as? [Dictionary<String, Any>]
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                    UserDefaults.standard.synchronize()
                    self.pushController(withName: Constants.Controllers.Baby_Select, context: self.user)
                }
                
            }
        }) { (error) in
            print(error)
        }
    }
    
    // MARK: WCSessionDelegate Handlers
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state \(activationState.rawValue)")
        print(activationState)
    }
    
    // UserInfo Sender
    func transferUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        if wkSession.isReachable {
            return wkSession?.transferUserInfo(userInfo)
        }
        return nil
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("didFinish state userInfoTransfer: \(userInfoTransfer)")
    }

    // UserInfo Receiver
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("didReceiveUserInfo state : \(userInfo)")
        self.userEmail = userInfo["email"] as! String
        self.userPassword = userInfo["password"] as! String
        if (userInfo.count>0) {
            self.callLoginServiceWithInfo(userInfo: userInfo)
        }
        //DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
            //self.callLoginService()
        //}
    }
    
    // Message Sender
    func sendMessage(message: [String : AnyObject], replyHandler: (([String : AnyObject]) -> Void)? = nil, errorHandler: ((NSError) -> Void)? = nil){
        if wkSession.isReachable {
            wkSession?.sendMessage(message, replyHandler: (replyHandler as! ([String : Any]) -> Void), errorHandler: errorHandler as? (Error) -> Void)
        }
    }
    @IBAction func showBabies() {
        self.willActivate()
    }
    
}

// Message Receiver
func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
    print("activationDidCompleteWith state : \(message)")
    DispatchQueue.main.async {
        // make sure to put on the main queue to update UI!
    }
}

