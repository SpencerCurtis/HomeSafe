//
//  NotificationController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import UIKit

class NotificationController {
    
    static let sharedController = NotificationController()
    
    func scheduleLocalNotification(user: User, ETA: EstimatedTimeOfArrival) {
        let notification = UILocalNotification()
        notification.fireDate = ETA.ETA
        notification.alertTitle = "\(user.name) is not in their safe location yet."
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}