//
//  Constants.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import Foundation
import WatchKit

struct Constants {
    struct Colors {
        static let yellow       = "FFE088"
        static let brown        = "BE822B"
        static let darkBrown    = "482C00"
        static let green        = "9E9F60"
        static let black        = "433934"
        static let red          = "FF7C64"
        static let white        = "FFFFFF"
        static let peach        = "F4D3D6"
        static let lightGray    = "202021"
        static let skyBlue      = "C7D6DF"
        static let feed         = "F5E99F"
        static let poo          = "DEC6BA"
        static let wee          = "CBDBAB"
        static let pump         = "FFCA9B"
        static let sleep        = "C7D6DF"
        static let medical      = "F4D3D6"
        static let labelColor   = "9F8A84"
        static let clear        = "FFFFFF"
        static let darkYellow   = "ECCB7B"
        static let orange       = "FF9C5F"
        static let brownBg      = "8D8082"
        
    }
    
    struct URLs {    
        static let BaseURL                  = "http://google.com"
        static let userlogin                = "api/login"
        static let getActivityList          = "api/getActivityList"
        static let updateUserDeviceToken    = "api/updateUserDeviceToken"
        static let addBabyActivity          = "api/addBabyActivity"
        static let editBabyActivity         = "api/editBabyActivity"
        static let getActivityReminderList  = "api/getActivityReminderList"
        static let addActivityReminder      = "api/addActivityReminder"
        static let deleteActivityReminder   = "api/deleteActivityReminder"
    }
    struct Images {
        //Activity listing
        static let activity_feed        = "icon_watch_activity_feed"
        static let activity_wee         = "icon_watch_activity_wee"
        static let activity_sleep       = "icon_watch_activity_sleep"
        static let activity_medical     = "icon_watch_activity_medical"
        static let activity_poo         = "icon_watch_activity_poo"
        static let activity_pump        = "icon_watch_activity_pump"
        //Saved Screen
        static let saved_feed           = "icon_activity_feed"
        static let saved_poo            = "icon_activity_poo"
        static let saved_pump           = "icon_activity_pump"
        static let saved_medicine       = "icon_activity_med"
        static let saved_sleep          = "icon_activity_sleep"
        static let saved_wee            = "icon_activity_wee"
    }
    struct Controllers {
        //Others
        static let Baby_Select              = "BabySelectorInterfaceController"
        static let Saved_Screen             = "SavedInterfaceController"
        //Activity
        static let Activity_List            = "ActivityInterfaceController"
        //Settings
        static let Setting_Reorder          = "ReOrderInterfaceController"
        static let Setting                  = "SettingsInterfaceController"
        //Feed
        static let Feed_Type                = "FeedTypeInterfaceController"
        static let Feed_Serving_Unit        = "ServingUnitInterfaceController"
        static let Volume                   = "FeedValumeInterfaceController"
        static let Feed_Nursing_Timer       = "FeedNursingTimerInterfaceController"
        static let New_FeedInterfaceController = "New_FeedInterfaceController"
        //Sleep
        static let Sleep                    = "SleepInterfaceController"
        static let Sleep_Set_Date           = "DateAndTimeInterfaceController"
        static let Sleep_Set_Time           = "TimeInterfaceController"
        //Poo
        static let Poo                      = "PooInterfaceController"
        static let Poo_Color_List           = "PooListInterfaceController"
        static let Poo_Type_List            = "PooTypeInterfaceController"
        //Wee
        static let Wee                      = "WeeInterfaceController"
        static let Wee_Color                = "WeeColorInterfaceController"
        static let Wee_Type_List            = "WeeTypeInterfaceController"
        //Pump
        static let Pump                     = "PumpInterfaceController"
        static let Pump_Set_Timer           = "KeypadInterfaceController"
        static let Pump_Set_Volume          = "PumpVolumeInterfaceController"
        //Medicine
        static let Medicine                 = "MedicineInterfaceController"
        static let Medicine_Type            = "MedicineTypeInterfaceController"
        static let Medicine_Set_Temperature = "SetTemperatureInterfaceController"
        static let Medicine_Dosage          = "DosageInterfaceController"
        static let Medicine_Dose_Volume     = "DoseVolumeInterfaceController"
        //Reminder
        static let Reminder                 = "ReminderInterfaceController"
        static let Add_Reminder             = "AddReminderInterfaceController"
        static let Reminder_Set_Time        = "SetReminderTimeInterfaceController"
        static let Reminder_Set_Repeat      = "SetReminderRepeatInterfaceController"

    }
    
    static func getDisplayAmount(value: Int) -> String {
        return "\(value)"
    }
    
    static func getDate(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E d MMM, yyyy hh:mm a"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let dateStr = dateFormatter.string(from: date)
        print("\(dateStr)")
        return dateStr
    }
    
}

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
