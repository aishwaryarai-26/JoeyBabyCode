//
//  ReminderListingTableViewCell.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/21/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit

class ReminderListingTableViewCell: NSObject {

    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblTimeReminder: WKInterfaceLabel!
    @IBOutlet var lblTypeReminder: WKInterfaceLabel?
    @IBOutlet var switchOnOffReminder: WKInterfaceSwitch?
    var cellIndex : Int = 0
    
    @IBAction func reminderSwitchToggled(_ sender : WKInterfaceSwitch) {
        print(reminderSwitchToggled)
        //NotificationCenter.default.post(name: Notification.Name("switchToggled"), object: ["cellIndex" : cellIndex])
    }

}
