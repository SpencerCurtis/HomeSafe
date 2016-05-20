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
    
    let db = CKContainer.defaultContainer().publicCloudDatabase
    
    func fetchUserForPhoneNumber(phoneNumber: String) -> User? {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        var user: User? = nil
        
        operation.recordFetchedBlock = { (record) in
            let name = record.valueForKey("name") as? String
            let phoneNum = record.valueForKey("phoneNum") as? String
            let safeLocation = record.valueForKey("safeLocation") as? CLLocation
            if let name = name, phoneNum = phoneNum, safeLocation = safeLocation {
            user = User(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNum)
            }
        }
        return user
        
    }
    
    
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
            let id = record["id"] as! String
            
            
            ETA = EstimatedTimeOfArrival(eta: eta, latitude: latitude, longitude: longitude, userName: name, id: id, recordID: String(record.recordID))
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
    
    func setupSubscriptionForETA(eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "canceledETA = %d", 1)
        let predicate2 = NSPredicate(format: "id = %@", eta.id!)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnRecordUpdate)
        
        let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: eta.recordID!))
        let info = CKNotificationInfo()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        if let eta = record.valueForKey("ETA") as? NSDate {
            let etaString = formatter.stringFromDate(eta)
            
            info.alertBody = "Your friend will be home around \(etaString)"
        }
        subscription.notificationInfo = info
        
        
        db.saveSubscription(subscription) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
    }
    
    
    
    
    func subscribeToUsersAddingSelfToContactList(currentUser: CurrentUser) {
        let predicate = NSPredicate(format: "contacts", true)
        let subscription = CKSubscription(recordType: "User", predicate: predicate, options: .FiresOnRecordUpdate)
        let record = CKRecord(recordType: "User", recordID: CKRecordID(recordName: currentUser.uuid!))
        let otherUserPhoneNumberArray = record.valueForKey("contacts") as! [String]
        var otherUser: User? = nil
        if let newestPhoneNumber = otherUserPhoneNumberArray.last {
        otherUser = fetchUserForPhoneNumber(newestPhoneNumber)
        }
        
        let info = CKNotificationInfo()
        info.alertBody = "\(otherUser?.name) has added you as a contact."
        
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    
    
    
    
    // General subscription by user
    func setupSubscriptionForUser(user: User) {
        let predicate = NSPredicate(format: "userPhoneNumber = %@", user.phoneNumber!)
        
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnRecordCreation)
        let record = CKRecord(recordType: "ETA")
        let info =
        
        
    }
    
    
    //    func setupSubscription(eta: EstimatedTimeOfArrival, user: User) {
    //        let predicate = NSPredicate(format: "canceledETA = \(eta.canceledETA), recordName = \(eta.id)")
    //        //        let predicate2 = NSPredicate
    //        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnce)
    //
    //        let info = CKNotificationInfo()
    //        info.alertBody = "\(user.name) will be home around \(eta.eta)"
    //
    //        subscription.notificationInfo = info
    //
    //        let db = CKContainer.defaultContainer().publicCloudDatabase
    //
    //        db.saveSubscription(subscription) { (result, error) in
    //            if error != nil {
    //                print(error?.localizedDescription)
    //            }
    //        }
    //        
    //    }
    
    
    
    
}