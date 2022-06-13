//
//  WeeTypeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 5/3/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class WeeTypeInterfaceController: WKInterfaceController {

    @IBOutlet var tableWeeType: WKInterfaceTable!
    var titles : [String] = []
    var controller : WeeInterfaceController!
    var type : String?
    var size : String?
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Size")
        
        let dict = context as? [String:Any]
        type = dict!["type"] as? String
        controller = dict!["Controller"] as? WeeInterfaceController
        if type == "Size" {
            titles = ["Large", "Medium", "Small"]
            size = dict!["Size"] as? String
        }
        loadTableData()
    }
    
    func loadTableData() {
        tableWeeType.setNumberOfRows(titles.count, withRowType: "PooType")
        for (nameIndex, name) in titles.enumerated() {
            let row = tableWeeType.rowController(at: nameIndex) as! PooType
            row.lblTitle.setText(name)
            if type == "Size" {
                if size! == name {
                    row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.wee))
                    row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        for (nameIndex, name) in titles.enumerated() {
            let row = tableWeeType.rowController(at: nameIndex) as! PooType
            if rowIndex == nameIndex {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.wee))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                if type == "Size"{
                    controller.size  = name
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
