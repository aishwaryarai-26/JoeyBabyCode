//
//  TimeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/25/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class TimeInterfaceController: WKInterfaceController, WKCrownDelegate {

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
    var controller : SleepInterfaceController!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Time")
        
        let dict    = context as? [String:Any]        
        controller  = dict!["Controller"] as? SleepInterfaceController
        hrs         = controller.hours!
        mins        = controller.minutes!
        format      = controller.timeFormat!
        
//        lblHrs.setText(String(describing: hrs))
//        lblMins.setText(String(describing: mins))
//        lblFormat.setText(format)
        lblHrs.setText(String(format: "%02d", hrs))
        lblMins.setText(String(format: "%02d", mins))
        lblFormat.setText(String(format: "%@", format))

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
                lblFormat.setText("AM")
                format = "AM"
                controller.timeFormat = format
                controller.hours = hrs
            }else {
                lblFormat.setText("PM")
                format = "PM"
                controller.timeFormat = format
                controller.hours = hrs+12
            }
        }
    }
    
    @IBAction func hoursClicked() {
        hrsActive = true
        minsActive = false
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblHrs.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblMins.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblFormat.setTextColor((UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func MinutesClicked() {
        hrsActive = false
        minsActive = true
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblHrs.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblMins.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblFormat.setTextColor((UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func formatClicked() {
        hrsActive = false
        minsActive = false
        grpHrs.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMins.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpFormat.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        
        self.lblHrs.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblMins.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblFormat.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
    }
    
    func setHrs(rotationalDelta : Double){
        if hrs >= 0 && hrs <= 12 {
            if rotationalDelta > 0 && hrs < 12{
                hrs += 1
            }
            else if rotationalDelta < 0 && hrs > 0{
                hrs -= 1
            }
            //lblHrs.setText(String(describing: hrs))
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
