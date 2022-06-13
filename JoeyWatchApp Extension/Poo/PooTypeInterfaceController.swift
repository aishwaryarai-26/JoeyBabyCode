//
//  PooTypeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class PooTypeInterfaceController: WKInterfaceController {

    @IBOutlet var tablePooType: WKInterfaceTable!
    var titles : [String] = []
    var controller : PooInterfaceController!
    var type : String?
    var size : String?
    var texture : String?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let dict = context as? [String:Any]
        type = dict!["type"] as? String
        controller = dict!["Controller"] as? PooInterfaceController
        self.setTitle(type)
        
        if type == "Size" {
            titles = ["Large", "Medium", "Small"]
            size = dict!["Size"] as? String
        }else{
            titles = ["Hard", "Soft", "Runny", "Mushy", "Loose", "Diarrhea", "Mucus"]
            texture = dict!["Texture"] as? String
        }
        loadTableData()
    }
    
    func loadTableData() {
        
        tablePooType.setNumberOfRows(titles.count, withRowType: "PooType")
        for (nameIndex, name) in titles.enumerated() {
            
            let row = tablePooType.rowController(at: nameIndex) as! PooType
            row.lblTitle.setText(name)
            if type == "Size" {
                if size! == name {
                    row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                    row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }
            }else {
                if texture! == name {
                    row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                    row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        for (nameIndex, name) in titles.enumerated() {
            let row = tablePooType.rowController(at: nameIndex) as! PooType
            if rowIndex == nameIndex {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.poo))
                row.lblTitle.setTextColor(UIColor(hex: Constants.Colors.labelColor))
                if type == "Size"{
                    controller.size  = name
                }else{
                    controller.texture = name
                }
            }else {
                row.bgColor.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                row.lblTitle.setTextColor(UIColor.white)
            }
        }
        pop()
    }
}

class PooType : NSObject {
    @IBOutlet var lblTitle : WKInterfaceLabel!
    @IBOutlet var bgColor: WKInterfaceGroup!
}
