//
//  SetReminderRepeatInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 7/11/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class SetReminderRepeatInterfaceController: WKInterfaceController {
    
    @IBOutlet var repeatListTbl: WKInterfaceTable!
    
    var addReminderController : AddReminderInterfaceController!
    var contextData : [String: Any]? = [:]
    var dayList = [String]()
    var repeatListArr = [String]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Repeat")
        // Configure interface objects here.
        self.contextData = context as? [String:Any]
        self.addReminderController = self.contextData!["controller"] as! AddReminderInterfaceController
        self.dayList = ["everyday","weekdays","weekends","monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.repeatListArr.removeAll()
        self.loadTableData()
    }
    
    func loadTableData() {
        self.repeatListTbl.setNumberOfRows(self.dayList.count, withRowType: "repeatListCell")
        for (nameIndex, name) in (self.dayList.enumerated()) {
            let row = self.repeatListTbl.rowController(at: nameIndex) as! repeatListCell
            row.lblTitle.setText(name.capitalized)
            row.mainGroup.setBackgroundColor(UIColor(hex: Constants.Colors.brownBg))
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        for (nameIndex, name) in self.dayList.enumerated() {
            print(name)
            let row = self.repeatListTbl.rowController(at: nameIndex) as! repeatListCell
            if rowIndex == nameIndex {
                row.mainGroup.setBackgroundColor(UIColor(hex: Constants.Colors.black))
                if(!self.repeatListArr.contains(name)){
                    self.repeatListArr.append(name)
                    self.addReminderController.repeatValue = ""
                    self.addReminderController.repeatValue = self.repeatListArr.joined(separator: ",")
                }
            }
        }
    }
    
}

class repeatListCell : NSObject {
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var lblTitle: WKInterfaceLabel!
}
