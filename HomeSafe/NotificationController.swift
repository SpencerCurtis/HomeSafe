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
    
    func scheduleLocalNotification(_ user: User, ETA: EstimatedTimeOfArrival) {
        let notification = UILocalNotification()
        notification.fireDate = ETA.eta as Date?
        notification.alertTitle = "\(user.name) is not in their safe location yet."
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func cancelLocalNotification(_ eta: EstimatedTimeOfArrival) {
        guard let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications else { return }
        for notification in scheduledNotifications {
            if notification.fireDate == eta.eta {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }
    
    func simpleAlert(_ title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = Colors.sharedColors.exoticGreen
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        return alert
        //        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    
}
