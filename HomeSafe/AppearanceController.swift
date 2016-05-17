//
//  AppearanceController.swift
//  HomeSafe
//
//  Created by admin on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class AppearanceController {
    
    var color = Colors()
    
    static func initializeAppearance() {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.184, green: 0.835, blue: 0.400, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().barStyle = UIBarStyle.Default
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        
        
    }
}
