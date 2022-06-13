//
//  WeeColorInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 5/3/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class WeeColorInterfaceController: WKInterfaceController {

    @IBOutlet var tableWee: WKInterfaceTable!
    var titles : [String] = []
    var colors : [String] = []
    var color : String?
    var weeController : WeeInterfaceController!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Color")
        
        let dict = context as? [String:Any]
        color = dict!["color"] as? String
        weeController = dict!["Controller"] as? WeeInterfaceController
        titles = ["Clear","Yellow","Dark Yellow", "Orange", "Red"]
        colors = [Constants.Colors.clear, Constants.Colors.yellow, Constants.Colors.darkYellow, Constants.Colors.orange, Constants.Colors.red]
        
        loadTableData()
    }
    
    func loadTableData() {
        self.tableWee.setNumberOfRows(titles.count, withRowType: "PooList")
        for (nameIndex, name) in titles.enumerated() {
            let row = tableWee.rowController(at: nameIndex) as! PooList
            row.lblTitle.setText(name)
            row.pooColor.setBackgroundColor(UIColor(hex: colors[nameIndex]))
            
            if (color!=="Lightyellow" && name=="Yellow") {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }else if (color! == name) {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        for (nameIndex, name) in titles.enumerated() {
            let row = tableWee.rowController(at: nameIndex) as! PooList
            if rowIndex == nameIndex {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                weeController.color = name
                if name == "Dark Yellow"{
                    weeController.color = "Yellow"
                }else if name == "Yellow"{
                    weeController.color = "Lightyellow"
                }
            }
            else {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                row.lblTitle.setTextColor(UIColor.white)
            }
        }
        pop()
    }

}
