//
//  ServiceUnitInterfaceController.swift
//  IwatchDemo Extension
//
//  Created by webwerks on 4/18/18.
//  Copyright © 2018 webwerks. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ServingUnitInterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var serviceTableView: WKInterfaceTable!
    var session : WCSession!
    var arrSolidList  : NSArray = []
    var newFeedController : New_FeedInterfaceController!
    var contextData : [String: Any]? = [:]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Serving Unit")
        arrSolidList = ["gm","oz","tbsp","tspn","cups"]
        contextData = context as? [String: Any]
        
        if (contextData!["type"] as! String) == "SolidInterface"{
            newFeedController = contextData!["Controller"] as! New_FeedInterfaceController
        }
        loadTableData()
    }

    override func willActivate() {
        super.willActivate()
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    
    func loadTableData() {
        self.serviceTableView.setNumberOfRows(arrSolidList.count, withRowType: "ServiceTableCell")
        for (nameIndex, name) in arrSolidList.enumerated() {
            let row = serviceTableView.rowController(at: nameIndex) as! ServiceTableCell
            row.labelSolidName.setText(name as? String)
            
            let currentUnit = newFeedController.unit
            if (name as? String == currentUnit) {
                //Set Background Color of row
                row.mainGroup.setBackgroundColor(UIColor(hex: Constants.Colors.feed))
                // Set title color of row
                row.labelSolidName.setTextColor(UIColor(hex: Constants.Colors.labelColor))
            }
        }
    }
    
    override func table(_: WKInterfaceTable, didSelectRowAt: Int){
        newFeedController.unit = arrSolidList[didSelectRowAt] as! String
        newFeedController.valueChanged_SolidsVolume = true
        pop()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void){
        print(message)
        
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?){
    }
}

class ServiceTableCell : NSObject {
    @IBOutlet var labelSolidName: WKInterfaceLabel!
    @IBOutlet var mainGroup: WKInterfaceGroup!

}
