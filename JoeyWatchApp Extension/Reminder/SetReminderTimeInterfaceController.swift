//
//  SetReminderTimeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 7/11/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class SetReminderTimeInterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet var lblHrs: WKInterfaceLabel!
    @IBOutlet var lblMins: WKInterfaceLabel!
    @IBOutlet var lblFormat: WKInterfaceLabel!
    
    @IBOutlet var grpHrs: WKInterfaceGroup!
    @IBOutlet var grpMins: WKInterfaceGroup!
    @IBOutlet var grpFormat: WKInterfaceGroup!
    
    var hrsActive = true
    var minsActive = false
    
    var hrs = 1
    var mins = 0
    var format = "AM"
    var controller : AddReminderInterfaceController!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Time")
        
        let dict    = context as? [String:Any]
        controller  = dict!["controller"] as? AddReminderInterfaceController
        hrs         = controller.hours!
        mins        = controller.minutes!
        format      = controller.timeFormat!
        
        if (hrs>12) {
            hrs = hrs-12
        }
        lblHrs.setText(String(format: "%02d", hrs))
        lblMins.setText(String(format: "%02d", mins))
        lblFormat.setText(String(format: "%@", format))
        
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.labelColor))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
    }
    
    override func willActivate() {
        super.willActivate()
        crownSequencer.delegate = self
        crownSequencer.focus()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if hrsActive {
            setHrs(rotationalDelta: rotationalDelta)
            if format == "AM" {
                controller.hours = hrs
            }else {
                controller.hours = hrs+12
            }
        }
        else if minsActive {
            setMins(rotationalDelta: rotationalDelta)
            controller.minutes = mins
        }
        else {
            if rotationalDelta > 0 {
                lblFormat.setText("PM")
                format = "PM"
                controller.timeFormat = format
                controller.hours = hrs+12
            }else {
                lblFormat.setText("AM")
                format = "AM"
                controller.timeFormat = format
                controller.hours = hrs
            }
        }
    }
    
    @IBAction func hoursClicked() {
        hrsActive = true
        minsActive = false
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.labelColor))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
    }
    
    @IBAction func MinutesClicked() {
        hrsActive = false
        minsActive = true
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.labelColor))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
    }
    
    @IBAction func formatClicked() {
        hrsActive = false
        minsActive = false
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.labelColor))
    }
    
    func setHrs(rotationalDelta : Double){
        if hrs >= 0 && hrs <= 12 {
            if rotationalDelta > 0 && hrs < 12{
                hrs += 1
            }
            else if rotationalDelta < 0 && hrs > 0{
                hrs -= 1
            }
            lblHrs.setText(String(format: "%02d", hrs))
        }
    }
    
    func setMins(rotationalDelta : Double){
        if mins >= 0 && mins <= 59 {
            if rotationalDelta > 0 && mins < 59{
                mins += 1
            }
            if rotationalDelta < 0 && mins > 1{
                mins -= 1
            }
            lblMins.setText(String(format: "%02d", mins))
        }
    }
    
}
