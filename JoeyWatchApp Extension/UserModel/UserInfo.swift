//
//  UserInfo.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/25/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import Foundation

class UserInfo {
    
    var user_id                 : Int?
    var user_name               : String?
    var user_email              : String?
    var email_confirm_check     : Bool?
    var access_token            : String?
    var baby_list               : [Dictionary<String,Any>]?
    
    init(dict : [String:Any]) {
        self.user_id        = dict["user_id"] as? Int ?? 0
        self.user_name      = dict["user_name"] as? String ?? ""
        self.user_email     = dict["user_email"] as? String ?? ""
        self.email_confirm_check    = dict["email_confirm_check"] as? Bool ?? false
        self.access_token    = dict["access_token"] as? String ?? ""
        
        if (dict["baby_list"] != nil) {
            self.baby_list = dict["baby_list"] as? [Dictionary<String, Any>]
        } else {
            self.baby_list = [Dictionary<String, Any>]()
        }
    }
    
}
