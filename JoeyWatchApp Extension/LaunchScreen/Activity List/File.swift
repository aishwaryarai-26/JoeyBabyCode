//
//  File.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/25/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import Foundation

class ActivityList {
    var attribute_name      : String?
    var attribute_value     : String?
    var baby_id             : Int?
    var color               : String?
    var created_at          : String?
    var date                : String?
    var diff                : String?
    var duration            : String?
    var id                  : Int?
    var medicine            : String?
    var minute_ago          : String?
    var movement            : String?
    var name                : String?
    var notes               : String?
    //var photo_url                : String?
    //var photo_url2                : String?
    //var photo_url3                : String?
    var reminder_check      : Int?
    var symptom             : String?
    var texture             : String?
    var time                : String?
    var type                : String?
    var unit                : String?
    var updated_at          : String?
    var value               : Int?
    //var value_end_at               : Int?
    //var value_start_at               : Int?
    var volume              : String?
    var wakeup_date         : String?
    var wakeup_minute_ago   : String?
    var wakeup_time         : String?

    init(dict : [String:Any]) {
        self.attribute_name     = dict["attribute_name"] as? String ?? ""
        self.attribute_value    = dict["attribute_value"] as? String ?? ""
        self.baby_id            = dict["baby_id"] as? Int ?? 0
        self.color              = dict["color"] as? String ?? ""
        self.created_at         = dict["created_at"] as? String ?? ""
        self.date               = dict["date"] as? String ?? ""
        self.diff               = dict["diff"] as? String ?? ""
        self.duration           = dict["duration"] as? String ?? ""
        self.id                 = dict["id"] as? Int ?? 0
        self.medicine           = dict["medicine"] as? String ?? ""
        self.minute_ago         = dict["minute_ago"] as? String ?? ""
        self.movement           = dict["movement"] as? String ?? ""
        self.name               = dict["name"] as? String ?? ""
        self.notes              = dict["notes"] as? String ?? ""
        self.reminder_check     = dict["reminder_check"] as? Int ?? 0
        self.symptom            = dict["symptom"] as? String ?? ""
        self.texture            = dict["texture"] as? String ?? ""
        self.time               = dict["time"] as? String ?? ""
        self.type               = dict["type"] as? String ?? ""
        self.unit               = dict["unit"] as? String ?? ""
        self.updated_at         = dict["updated_at"] as? String ?? ""
        self.value              = dict["value"] as? Int ?? 0
        self.volume             = dict["volume"] as? String ?? ""
        self.wakeup_date        = dict["wakeup_date"] as? String ?? ""
        self.wakeup_minute_ago  = dict["wakeup_minute_ago"] as? String ?? ""
        self.wakeup_time        = dict["wakeup_time"] as? String ?? ""

    }
}
