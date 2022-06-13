//
//  DateAndTimeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/24/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class DateAndTimeInterfaceController: WKInterfaceController, WKCrownDelegate {


    @IBOutlet var lblday: WKInterfaceLabel!
    @IBOutlet var lblMonth: WKInterfaceLabel!
    @IBOutlet var lblYear: WKInterfaceLabel!
    
    @IBOutlet var grpDate: WKInterfaceGroup!
    @IBOutlet var grpMonth: WKInterfaceGroup!
    @IBOutlet var grpYear: WKInterfaceGroup!
    
    var dateActive = true
    var monthActive = false
    var yearActive = false
    
    var date = 1
    var month = 0
    var year = 2018
    
    var months : [String] = []
    var numberOfDays = 30
    
    var controller : SleepInterfaceController!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Date")
        
        let dict = context as? [String:Any]
        controller = dict!["Controller"] as? SleepInterfaceController
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        grpDate.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        grpYear.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMonth.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
    }

    override func willActivate() {
        super.willActivate()
        crownSequencer.delegate = self
        crownSequencer.focus()
        date    = controller.date!
        month   = (controller.month! - 1)
        year    = controller.year!
        
        lblday.setText(String(format: "%02d", date))
        lblMonth.setText(String(format: "%@", months[month]))
        lblYear.setText(String(format: "%d", year))
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if dateActive {
            setDate(rotationalDelta: rotationalDelta)
        }
        else if monthActive {
            setMonth(rotationalDelta: rotationalDelta)
        }
        else if yearActive {
            setYear(rotationalDelta: rotationalDelta)
        }
    }
    
    @IBAction func dateClicked() {
        dateActive = true
        monthActive = false
        yearActive = false
        grpDate.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        grpYear.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMonth.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblday.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblMonth.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblYear.setTextColor((UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func monthClicked() {
        dateActive = false
        monthActive = true
        yearActive = false
        grpDate.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMonth.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        grpYear.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        
        self.lblday.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblMonth.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
        self.lblYear.setTextColor((UIColor(hex: Constants.Colors.white)))
    }
    
    @IBAction func yearClicked() {
        dateActive = false
        monthActive = false
        yearActive = true
        grpDate.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpMonth.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
        grpYear.setBackgroundColor(UIColor(hex: Constants.Colors.skyBlue))
        
        self.lblday.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblMonth.setTextColor((UIColor(hex: Constants.Colors.white)))
        self.lblYear.setTextColor((UIColor(hex: Constants.Colors.labelColor)))
    }
    
    func setDate(rotationalDelta: Double) {
        numberOfDaysInMonth()
        if date >= 1 && date <= numberOfDays {
            print(date)
            if rotationalDelta>0 && date < numberOfDays{
                date += 1
            }
            else if  rotationalDelta<0 && date > 1 {
                date -= 1
            }
            
            //lblday.setText(String(describing: date))
            lblday.setText(String(format: "%02d", date))
        }
        controller.date = date
    }
    
    func setMonth(rotationalDelta: Double){
        
        if month >= 0 && month <= 11 {
            if rotationalDelta>0 && month<11{
                month += 1
            }
            else if  rotationalDelta<0 && month>0 {
                month -= 1
            }
            
            print(months[month])
            //lblMonth.setText(months[month])
            lblMonth.setText(String(format: "%@", months[month]))

            numberOfDaysInMonth()
            
            if (numberOfDays == 30 && date == 31) {
                date = 30
                //lblday.setText(String(describing:date))
                lblday.setText(String(format: "%02d", date))
            }
            if (month == 1 && (date == 31 || date == 30)) {
                date = isLeapYear(year) ? 29 : 28
                //lblday.setText(String(describing:date))
                lblday.setText(String(format: "%02d", date))
            }
            controller.month = month+1
        }
        
    }
    
    func numberOfDaysInMonth(){
        switch month {
        case 1: numberOfDays = isLeapYear(year) ? 29 : 28
            break
        case 3: numberOfDays = 30; break
        case 5: numberOfDays = 30; break
        case 8: numberOfDays = 30; break
        case 10: numberOfDays = 30; break
        default : numberOfDays = 31;
            break
        }
    }
    
    func setYear(rotationalDelta: Double){
        if rotationalDelta > 0 {
            year += 1
        }
        else {
            year -= 1
        }
        //lblYear.setText(String(describing: year))
        lblYear.setText(String(format: "%d", year))

        controller.year = year
    }
    
    func isLeapYear(_ year: Int) -> Bool {
        let isLeapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
        return isLeapYear
    }
    
    func changeTextColor(sender:WKInterfaceButton, txt:String, txtColor:UIColor)  {
        let attString = NSMutableAttributedString(string: txt)
        attString.setAttributes([NSAttributedStringKey.foregroundColor: txtColor], range: NSMakeRange(0, attString.length))
        sender.setAttributedTitle(attString)
    }
    
}
