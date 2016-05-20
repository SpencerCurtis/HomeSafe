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
    
    func fetchUserForPhoneNumber(phoneNumber: String, completion: (user: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            let name = record.valueForKey("name") as? String
            let phoneNum = record.valueForKey("phoneNum") as? String
            let safeLocation = record.valueForKey("safeLocation") as? CLLocation
            let uuid = record.valueForKey("id") as? String
            if let name = name, phoneNum = phoneNum, safeLocation = safeLocation, uuid = uuid {
                let user = User(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNum, uuid: uuid)
                completion(user: user)
            }
        }
        
    }
    
    // This should be implemented as soon as an account (user) is made on the signup screen. It will set-up a subscription to check if any other user has added them as a contact (potential watcher)
    
    func subscribeToUsersAddingCurrentUserToContactList(currentUser: CurrentUser) {
        let predicate = NSPredicate(format: "contacts", true)
        let subscription = CKSubscription(recordType: "User", predicate: predicate, options: .FiresOnRecordUpdate)
        let record = CKRecord(recordType: "User", recordID: CKRecordID(recordName: currentUser.uuid!))
        let otherUserPhoneNumberArray = record.valueForKey("contacts") as! [String]
        if let newestPhoneNumber = otherUserPhoneNumberArray.last {
            fetchUserForPhoneNumber(newestPhoneNumber, completion: { (user) in
                let info = CKNotificationInfo()
                if let user = user {
                    info.alertBody = "\(user.name) has added you as a contact."
                    subscription.notificationInfo = info
                    self.db.saveSubscription(subscription) { (subscription, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                }
                
            })
        }
        
        
        
    }
    
    func addCurrentUserToOtherUsersContactList(currentUser: CurrentUser, phoneNumber: String) {
        fetchUserForPhoneNumber(phoneNumber) { (user) in
            if let otherUser = user {
                let record = CKRecord(recordType: "User", recordID: CKRecordID(recordName: otherUser.uuid!))
                record.setValue(currentUser.phoneNumber, forKey: "contacts")
                self.db.saveRecord(record, completionHandler: { (record, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                })
                
            }
            
            
        }
        
        
    }
    
    
    // This is to subscribe to a specific ETA.
    
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
    
    // General subscription by user to check if said user has made a new ETA.
    
    func setupSubscriptionForUser(user: User) {
        let predicate = NSPredicate(format: "userPhoneNumber = %@", user.phoneNumber!)
        
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnRecordCreation)
        //        let record = CKRecord(recordType: "ETA")
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
                // Handle the crap out of the error, like send an alert or something.
            } else {
                
            }
        }
        
        
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
    
    
}