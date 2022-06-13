//
//  PooInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class PooInterfaceController: WKInterfaceController {

    @IBOutlet var tablePoo: WKInterfaceTable!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var LoadingView: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceImage!
    var titles      : [String] = []
    var pooData     : ActivityList?
    var pooInfo      : [String:Any]?

    var color       : String?
    var size        : String?
    var texture     : String?
    var selectedBabyIndex     : Int?
    var sendToActivityInterface     : Bool          = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Poo")
        
        pooData     = context as? ActivityList
        
        self.selectedBabyIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as! [[String:Any]]
        self.pooInfo = ((babyList[self.selectedBabyIndex!])["poo_info"]) as? [String : Any]
        print(self.pooInfo!)

        if(pooInfo!.count>0 && (pooInfo!["poo"] != nil) ) {
            color       = (pooData?.color!)?.firstUppercased
            size        = pooData?.volume!.firstUppercased
            texture     = pooData?.texture!.firstUppercased
        }
        else {
            color       = "Brown"
            size        = "Medium"
            texture     = "Soft"
        }
        
    }

    override func willActivate() {
        super.willActivate()
        if (self.sendToActivityInterface == true) {
            pop()
            return
        }
        titles = [color , size, texture] as! [String]
        loadTableData()
    }
    
    func loadTableData() {
        
        self.tablePoo.setNumberOfRows(titles.count, withRowType: "Poo")
        for (nameIndex, name) in titles.enumerated() {
            let row = tablePoo.rowController(at: nameIndex) as! Poo
            row.lblTile.setText(name)
            if nameIndex != 0 {
                row.pooColor.setBackgroundColor(UIColor.clear)
            }else {
                row.pooColor.setBackgroundColor(UIColor(hex: getPooColor(color: color!)))
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 0 {
            let context = ["color":color!, "Controller" : self] as [String : Any]
            pushController(withName:  Constants.Controllers.Poo_Color_List, context: context)
        }else if rowIndex == 1 {
            let type = ["type" : "Size", "Controller" : self, "Size" : size!] as [String : Any]
            pushController(withName:  Constants.Controllers.Poo_Type_List, context: type)
        }else {
            let type = ["type" : "Texture", "Controller" : self, "Texture" : texture!] as [String : Any]
            pushController(withName: Constants.Controllers.Poo_Type_List, context: type)
        }
    }
    
    @IBAction func saveClicked() {
        callSaveWebservice()
        print("saveClicked")
    }
    
    func getPooColor(color : String) -> String {
        switch color {
        case "Green"        : return Constants.Colors.green
        case "Black"        : return Constants.Colors.black
        case "Red"          : return Constants.Colors.red
        case "Brown"        : return Constants.Colors.brown
        case "Dark Brown"   : return Constants.Colors.darkBrown
        case "Yellow"       : return Constants.Colors.yellow
        case "White"        : return Constants.Colors.white
        default             : return ""
        }
    }
    
    func callSaveWebservice(){
        
        // Get Baby Details
        let babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
        let selectedBIndex = UserDefaults.standard.integer(forKey: "wk_selectedBaby_index")
        let babydetails = babyList![selectedBIndex]
        // Set Request Parameters
        var paramsDict = [String:Any]()
        paramsDict["user_id"] = UserDefaults.standard.integer(forKey: "wk_user_id")
        paramsDict["baby_id"] = babydetails["id"]
        paramsDict["name"] = "poo"
        paramsDict["type"] = "poo"
        paramsDict["color"] = color!.lowercased()
        paramsDict["texture"] = texture!.lowercased()
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
                // Get Baby Details
                var babyList = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "wk_baby_list") as! Data)) as? [[String:Any]]
                (babyList![selectedBIndex])["poo_info"] = response["info"]
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: babyList!), forKey: "wk_baby_list")
                UserDefaults.standard.synchronize()
                self.sendToActivityInterface = true
                self.pushController(withName: Constants.Controllers.Saved_Screen, context: Constants.Images.saved_poo)
                
            }else {
                print("failed !")
            }
            
        }, errorBlock: { (error) in
            print(error)
        })
    }
    
}
//MARK: - Loader
extension PooInterfaceController {
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
        self.LoadingView.setHidden(hidden)
        self.group.setHidden(!hidden)
    }
}
class Poo : NSObject {
    @IBOutlet var btnColor: WKInterfaceButton!
    @IBOutlet var pooColor: WKInterfaceGroup!
    @IBOutlet var lblTile: WKInterfaceLabel!
}
