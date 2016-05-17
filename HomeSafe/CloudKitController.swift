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
    
    
    func loadETAForUser() {
        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "\(user.phoneNumber)")
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        var ETA: EstimatedTimeOfArrival?
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            let eta = record["ETA"] as! NSDate
            let location = record["destinationLocation"] as! CLLocation
            let name = record["name"] as! String
            
            ETA = EstimatedTimeOfArrival(ETA: eta, destinationLocation: location, name: name)
        }
        operation.queryCompletionBlock = { (cursor, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error == nil {
                    if let eta = ETA {
                        ETAController.sharedController.ArrayOfETAs?.append(eta)
                    }
                }
            })
        }
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
    }
    
}