//
//  CloudKitController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

class CloudKitController {
    
    static let sharedController = CloudKitController()
    
    
    func loadETAForUser(user: User) {
        let predicate = NSPredicate(format: "\(user.phoneNumber)")
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        var ETA: EstimatedTimeOfArrival?
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            let eta = record["ETA"] as! NSDate
            let latitude = record["latitude"] as! Double
            let longitude = record["longitude"] as! Double
            let name = record["name"] as! String
            let id = String(record.recordID)
            
            
            ETA = EstimatedTimeOfArrival(eta: eta, latitude: latitude, longitude: longitude, userName: name, id: id)
        }
        operation.queryCompletionBlock = { (cursor, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error == nil {
                    if ETA != nil {
                        ETAController.sharedController.saveToPersistentStorage()
                    }
                }
            })
        }
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
    }
    
    
    func setupSubscription(eta: EstimatedTimeOfArrival, user: User) {
        let predicate = NSPredicate(format: "canceledETA = \(eta.canceledETA), recordName = \(eta.id)")
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnce)
        
        let info = CKNotificationInfo()
        info.alertBody = "\(user.name) will be home around \(eta.eta)"
        
        subscription.notificationInfo = info
        
        let db = CKContainer.defaultContainer().publicCloudDatabase
        
        db.saveSubscription(subscription) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
        
        
        
    }
    
    
    
    
}