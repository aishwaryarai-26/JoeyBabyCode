//
//  BabySelectorInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation

class BabySelectorInterfaceController: WKInterfaceController {
    //MARK:- Outlets
    @IBOutlet var tableBabies : WKInterfaceTable!
    //MARK:- Variables
    private var user : UserInfo?
    private var babyList : [[String:Any]]?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle(Keys.babies)
        
        self.user       = context as? UserInfo
        self.babyList   = self.user?.baby_list
        loadTableData()
    }
}
extension BabySelectorInterfaceController {
    
    func loadTableData() {
        self.tableBabies.setNumberOfRows((self.babyList?.count)!, withRowType: Keys.babies)
        for (nameIndex, babyDict) in (self.babyList?.enumerated())! {
            let row = tableBabies.rowController(at: nameIndex) as! Babies
            let babyName = babyDict[Keys.name] as? String
            row.lblBabyName.setText(babyName)
            row.imgIconGroup.setBackgroundColor((UIColor(hex: Constants.Colors.feed)))
            let imgUrlStr = babyDict[Keys.photo_url] as? String
            row.imgBaby.setImageWithUrl(url: imgUrlStr!, scale: 1.0)
        }
    }
}
extension BabySelectorInterfaceController {
    
    override func table(_: WKInterfaceTable, didSelectRowAt: Int){
        
        UserDefaults.standard.set(didSelectRowAt , forKey: Keys.selected_baby)
        UserDefaults.standard.synchronize()
        let context = self.babyList![didSelectRowAt]
        let uID     = self.user?.user_id
        let aToken  = self.user?.access_token
        let dict : [String : Any] = [Keys.babiesDict    : context,
                                     Keys.user_id       : uID!,
                                     Keys.access_token  : aToken!]
        pushController(withName: Constants.Controllers.Activity_List, context: dict)
    }
    
}

public extension WKInterfaceImage {
    
    public func setImageWithUrl(url:String, scale: CGFloat = 1.0) {
        
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL) { data, response, error in
            if (data != nil && error == nil) {
                let image = UIImage(data: data!, scale: scale)
                DispatchQueue.main.async() {
                    self.setImage(image)
                }
            }
            }.resume()
    }
}
