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
import UserNotifications

class NotificationController {
    
    static let sharedController = NotificationController()
    
    func scheduleNotificationRequestFor(user: User, eta: EstimatedTimeOfArrival) {
        
        guard let id = eta.id else { return }
        
        let identifier = id
        
        let content = UNMutableNotificationContent()
        
        content.title = "\(user.name) is not in their safe location yet."
        content.body = ""
        content.sound = UNNotificationSound.default()
        
        guard let etaInSeconds = eta.eta?.timeIntervalSinceNow else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: etaInSeconds, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error { print(error.localizedDescription) }
        }

    }
    
    func cancelNotificationRequestFor(eta: EstimatedTimeOfArrival) {
        guard let id = eta.id else { print("Could not cancel notification request because the ETA has no ID"); return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
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
