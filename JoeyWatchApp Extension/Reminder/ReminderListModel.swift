//
//  ReminderListModel.swift
//  JoeyWatch Extension
//
//  Created by webwerks on 5/21/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import Foundation

class ReminderListModel {
    
    var baby_id         : Int?
    var created_at      : String?
    var disabled_check  : Bool?
    var id              : Int?
    var name            : String?
    var recurrence      : String?
    var time            : String?
    var type            : String?
    var updated_at      : String?
    var user_id         : Int?

    init(dict : [String:Any]) {
        self.baby_id        = dict["baby_id"] as? Int ?? 0
        self.created_at     = dict["created_at"] as? String ?? ""
        self.disabled_check = dict["disabled_check"] as? Bool ?? false
        self.id             = dict["id"] as? Int ?? 0
        self.name           = dict["name"] as? String ?? ""
        self.recurrence     = dict["recurrence"] as? String ?? ""
        self.time           = dict["time"] as? String ?? ""
        self.type           = dict["type"] as? String ?? ""
        self.updated_at     = dict["updated_at"] as? String ?? ""
        self.user_id         = dict["user_id"] as? Int ?? 0
    }
    
}
