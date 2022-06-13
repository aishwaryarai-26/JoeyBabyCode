//
//  ActivityTableViewCell.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/16/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit

class ActivityTableViewCell: NSObject {
    
    @IBOutlet var mainGroup: WKInterfaceGroup!

    @IBOutlet var lblTimeActivity: WKInterfaceLabel!
    @IBOutlet var lblMinAgoActivity: WKInterfaceLabel?
    @IBOutlet var lblTypeActivity: WKInterfaceLabel?
    @IBOutlet var lblValueActivity: WKInterfaceLabel?
    
    @IBOutlet var btnAlarmActivity: WKInterfaceButton!
    @IBOutlet var imgFlashActivity: WKInterfaceImage!
    @IBOutlet var imgActivityTypeActivity: WKInterfaceImage!
    
    var cellIndex : Int = 0
    
    @IBAction func btnAlarmClicked(_ sender : WKInterfaceButton) {
        NotificationCenter.default.post(name: Notification.Name("alarmClicked"), object: ["cellIndex" : cellIndex])
    }
    
//    @IBAction func handleGesture(gestureRecognizer : WKGestureRecognizer){
//        NotificationCenter.default.post(name: Notification.Name("handleGesture"), object: ["cellIndex" : cellIndex])
//        guard let sender = gestureRecognizer as? WKLongPressGestureRecognizer else {
//            return
//        }
//        if sender.state == UIGestureRecognizerState.began {
//            print("Touch down")
//        } else if sender.state == UIGestureRecognizerState.ended {
//            print("Touch up")
//        }
//        
//    }
    
    @IBAction func flashClickedLong(_ sender: Any) {
        //NotificationCenter.default.post(name: Notification.Name("flashClicked"), object: ["cellIndex" : cellIndex])
    }
    
}
