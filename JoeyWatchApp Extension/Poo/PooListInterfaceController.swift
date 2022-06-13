//
//  PooListInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class PooListInterfaceController: WKInterfaceController {

    @IBOutlet var tablePoo: WKInterfaceTable!
    var titles : [String] = []
    var colors : [String] = []
    var color : String?
    var pooController : PooInterfaceController!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Color")
        
        let dict = context as? [String:Any]
        color = dict!["color"] as? String
        pooController = dict!["Controller"] as? PooInterfaceController
        titles = ["Yellow", "Brown", "Dark Brown", "Green", "Black", "Red", "White"]
        colors = [Constants.Colors.yellow, Constants.Colors.brown, Constants.Colors.darkBrown, Constants.Colors.green, Constants.Colors.black, Constants.Colors.red, Constants.Colors.white]
        
        loadTableData()
    }

    func loadTableData() {
        self.tablePoo.setNumberOfRows(titles.count, withRowType: "PooList")
        for (nameIndex, name) in titles.enumerated() {
            let row = tablePoo.rowController(at: nameIndex) as! PooList
            row.lblTitle.setText(name)
            row.pooColor.setBackgroundColor(UIColor(hex: colors[nameIndex]))
            if color! == name {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        for (nameIndex, name) in titles.enumerated() {
            let row = tablePoo.rowController(at: nameIndex) as! PooList
            if rowIndex == nameIndex {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                pooController.color = name
            }
            else {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                row.lblTitle.setTextColor(UIColor.white)
            }
        }
        pop()
    }
}

class PooList : NSObject {
    @IBOutlet var pooColor: WKInterfaceGroup!
    @IBOutlet var lblTitle: WKInterfaceLabel!
    @IBOutlet var bgColor: WKInterfaceGroup!
    
}
