//
//  WeeInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 5/3/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class WeeInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableWee: WKInterfaceTable!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var loaderView: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    var titles      : [String] = []
    var weeData     : ActivityList?
    var weeInfo     : [String:Any]?
    var color       : String?
    var size        : String?
    var selectedBabyIndex        : Int?
    var sendToActivityInterface  : Bool = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setTitle("Wee")
        weeData     = context as? ActivityList
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        self.weeInfo = ((babyList[self.selectedBabyIndex!])["wee_info"]) as? [String : Any]
        print(self.weeInfo!)

        if(weeInfo!.count>0 && (weeInfo!["wee"] != nil) ) {
            color       = (weeData?.color!)?.firstUppercased
            size        = weeData?.volume!.firstUppercased
        }
        else {
            color       = "Yellow"
            size        = "Medium"
        }
    }
    
    override func willActivate() {
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        titles      = [color , size] as! [String]
        loadTableData()
        self.stopLoader()
    }
    
    func loadTableData() {
        self.tableWee.setNumberOfRows(titles.count, withRowType: "Wee")
        for (nameIndex, name) in titles.enumerated() {
            let row = tableWee.rowController(at: nameIndex) as! Wee
            row.lblTile.setText(name)
            if (name=="Lightyellow") {
                row.lblTile.setText("Yellow")
            }else if (name=="Yellow"){
                row.lblTile.setText("Dark Yellow")
            }
            if nameIndex != 0 {
                row.weeColor.setBackgroundColor(UIColor.clear)
            }else {
                row.weeColor.setBackgroundColor(UIColor(hex: getWeeColor(color: color!)))
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 0 {
            let context = ["color":color!, "Controller" : self] as [String : Any]
            pushController(withName:  Constants.Controllers.Wee_Color, context: context)
        }
        else if rowIndex == 1 {
            let type = ["type" : "Size", "Controller" : self, "Size" : size!] as [String : Any]
            pushController(withName:  Constants.Controllers.Wee_Type_List, context: type)
        }
    }
    
    func getWeeColor(color : String) -> String {
        switch color {
        case "Red"          : return Constants.Colors.red
        case "Orange"       : return Constants.Colors.orange
        case "Yellow"  : return Constants.Colors.darkYellow
        case "Lightyellow"  : return Constants.Colors.yellow
        case "Clear"        : return Constants.Colors.white
        default             : return ""
        }
    }
    
    @IBAction func saveClicked() {
        callSaveWebservice()
    }
    
    func callSaveWebservice(){
        
        var selectedColor = color!
        if (color!=="Darkyellow") {
            selectedColor = "yellow"
        } else if (color!=="yellow"){
            selectedColor = "lightyellow"
        }
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = "wee"
        paramsDict["type"] = "wee"
        paramsDict["color"] = selectedColor
        paramsDict["volume"] = size!
        paramsDict["time"] = Constants.getDate(date: Date())
        paramsDict["unit"] = "time"
        paramsDict["value"] = 1
        paramsDict["notes"] = ""
        
       self.showLoader()
        WebserviceHelper.sharedInstance.callPostDataWithMethod(methodName: Constants.URLs.addBabyActivity, requestDict: paramsDict, headerValue: [:], isHud: false, successBlock: { (success, response) in
            print(response)
            self.stopLoader()
            if (response["success"] as? Bool)!{
                var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                (babyList![selectedBIndex])["wee_info"] = response["info"]
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                UserDefaults.standard.synchronize()
                self.sendToActivityInterface = true
                self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_wee)
            }
            else {
                Alert.alertView(message: "failed!", controller: self)
            }
        }, errorBlock: { (error) in
            print(error)
        })
    }
    
}
extension WeeInterfaceController {
    func showLoader() {
        self.setLoader(hidden: false)
        loader.setImageNamed("loader")
        loader.startAnimatingWithImages(in: NSRange(location: 1,
                                                    length: 8), duration: 0.8, repeatCount: -1)
    }
    func stopLoader() {
        self.loader.stopAnimating()
        self.setLoader(hidden: true)
    }
    
    private func setLoader(hidden:Bool) {
        self.loaderView.setHidden(hidden)
        self.group.setHidden(!hidden)
    }
}
class Wee : NSObject {
    @IBOutlet var btnColor: WKInterfaceButton!
    @IBOutlet var weeColor: WKInterfaceGroup!
    @IBOutlet var lblTile: WKInterfaceLabel!
}
