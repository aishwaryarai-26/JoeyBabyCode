//
//  ReOrderInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class ReOrderInterfaceController: WKInterfaceController {

    @IBOutlet var tableReOrder: WKInterfaceTable!
    var titles : [String] = []
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        titles = ["Feed", "Poo", "Wee", "Pump", "Sleep", "Medical"]
        setTitle("Re-Order")
        loadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func loadTableData() {
        self.tableReOrder.setNumberOfRows(titles.count, withRowType: "ReOrderTable")
        for (nameIndex, name) in titles.enumerated() {
            let row = tableReOrder.rowController(at: nameIndex) as! ReOrderTable
            
            row.lblTitle.setText(name)
        }
    }

}

class ReOrderTable : NSObject {
    @IBOutlet var lblTitle: WKInterfaceLabel!
}
