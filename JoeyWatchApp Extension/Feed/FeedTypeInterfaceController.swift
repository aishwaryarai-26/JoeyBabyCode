//
//  FeedTypeInterfaceController.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/17/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit
import Foundation
import  WatchConnectivity

class FeedTypeInterfaceController: WKInterfaceController {
    var session : WCSession!
    
    @IBOutlet var feedTypeTableview: WKInterfaceTable!
    
    var newFeedController : New_FeedInterfaceController!
    
    var arrFeedTypeList  : [String] = []
    var context : ActivityList?
    var feed_type : String?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("FeedType")

        var dict : [String:Any] = [:]
        dict = context as! [String:Any]
        newFeedController = dict["Controller"] as! New_FeedInterfaceController
        self.context = dict["context"] as? ActivityList
        
        arrFeedTypeList = ["Breastmilk", "Formula", "Nursing", "Solids","Water","Juice"]
        feed_type = self.context?.type
        
    }

    override func willActivate() {
        super.willActivate()
       loadTableData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func loadTableData() {
        self.feedTypeTableview.setNumberOfRows(arrFeedTypeList.count, withRowType: "FeedTypeTableCell")
        for (nameIndex, name) in arrFeedTypeList.enumerated() {
            let row = feedTypeTableview.rowController(at: nameIndex) as! FeedTypeTableCell
            row.labelFeedType.setText(name)
            
            if (feed_type!).caseInsensitiveCompare(name) == .orderedSame {
                row.groupBGColor.setBackgroundColor(UIColor(hex: Constants.Colors.feed))
                row.labelFeedType.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }else {
                row.groupBGColor.setBackgroundColor(UIColor(hex: Constants.Colors.lightGray))
                row.labelFeedType.setTextColor(UIColor.white)
            }
            
            if ((name == "Nursing") && (feed_type! == "lboob" || feed_type! == "rboob" || feed_type! == "rboob+rboob")) {
                row.groupBGColor.setBackgroundColor(UIColor(hex: Constants.Colors.feed))
                row.labelFeedType.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }
            
        }
    }
    
    override func table(_: WKInterfaceTable, didSelectRowAt: Int){
        let typeName = self.arrFeedTypeList[didSelectRowAt] as String
        if (typeName == "Breastmilk") {
            newFeedController.feedType = "bbottle"
        }else if (typeName == "Nursing"){
            newFeedController.feedType = "lboob"
        }else {
            newFeedController.feedType = typeName.lowercased()
        }
        pop()
    }

}

class FeedTypeTableCell : NSObject {
    @IBOutlet var labelFeedType : WKInterfaceLabel!
    @IBOutlet var groupBGColor  : WKInterfaceGroup!
}
