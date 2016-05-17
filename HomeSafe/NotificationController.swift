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
        notification.fireDate = ETA.ETA
        notification.alertTitle = "\(user.name) is not in their safe location yet."
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func setupSubscription(eta: EstimatedTimeOfArrival, user: User) {
        let predicate = NSPredicate(format: "ETA")
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnce)
        
        let info = CKNotificationInfo()
        info.alertBody = "\(user.name) will be home around \(eta.ETA)"
        
        subscription.notificationInfo = info
        
        let db = CKContainer.defaultContainer().publicCloudDatabase
        
        db.saveSubscription(subscription) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
        
        
        
    }
    
}