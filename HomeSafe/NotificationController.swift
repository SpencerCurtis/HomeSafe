//
//  NotificationController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class NotificationController {
    
    static let sharedController = NotificationController()
    
    func scheduleLocalNotification(user: User, ETA: EstimatedTimeOfArrival) {
        let notification = UILocalNotification()
        notification.fireDate = ETA.eta
        notification.alertTitle = "\(user.name) is not in their safe location yet."
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func cancelLocalNotification(eta: EstimatedTimeOfArrival) {
        guard let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications else { return }
        for notification in scheduledNotifications {
            if notification.fireDate == eta.eta {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
        }
    }
    
    func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alert.addAction(dismissAction)
        alert.presentViewController(alert, animated: true) { 
            
        }
//        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController!.presentViewController(alert, animated: true, completion: nil)
    }
}