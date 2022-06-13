//
//  Alert.swift
//  JoeyWatchApp Extension
//
//  Created by Webwerks on 7/31/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import Foundation
import UIKit
import WatchKit
struct Alert {
    static func alertView(message : String, controller : WKInterfaceController){
        let ok = WKAlertAction(title: "Ok", style: .default, handler: {})
        controller.presentAlert(withTitle: "Joey", message: message, preferredStyle: .alert, actions: [ok])
    }
}
