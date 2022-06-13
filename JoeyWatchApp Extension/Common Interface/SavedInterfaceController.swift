//
//  SavedInterfaceController.swift
//  JoeyWatch Extension
//
//  Created by Neo on 4/16/18.
//  Copyright © 2018 Auxilia. All rights reserved.
//

import WatchKit
import Foundation


class SavedInterfaceController: WKInterfaceController {

    @IBOutlet var img: WKInterfaceImage!
    private var image1 : String!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        image1 = context as! String
    }
    override func willActivate() {
        img.setImageNamed(image1)
        if #available(iOS 10.0, *) {
            let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                self.pop()
            })
        } else {
            
        }
        
    }
}
