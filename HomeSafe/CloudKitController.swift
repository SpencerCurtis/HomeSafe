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
import UIKit

class CloudKitController {
    
    static let sharedController = CloudKitController()
    
    
<<<<<<< HEAD
    var tempContactsArray: [String] = []
    
    func fetchUserForPhoneNumber(phoneNumber: String, completion: (otherUser: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        db.performQuery(query, inZoneWithID: nil) { (results, error) in
            if let record = results?.first {
                let name = record.valueForKey("name") as? String
                let phoneNum = record.valueForKey("phoneNum") as? String
                let safeLocation = record.valueForKey("safeLocation") as? CLLocation
                let uuid = record.recordID.recordName
                if let name = name, phoneNum = phoneNum, safeLocation = safeLocation {
                    
                    let user = User(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNum, uuid: uuid)
                    
                    completion(otherUser: user)
                    
                }
            }
        }
        
        
        
    }
    
    // This should be implemented as soon as an account (user) is made on the signup screen. It will set-up a subscription to check if any other user has added them as a contact (potential watcher)
    
    func subscribeToUsersAddingCurrentUserToContactList(currentUser: CurrentUser) {
        
        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
        //        let predicate2 = NSPredicate(value: <#T##Bool#>)
        //        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "User", predicate: predicate, options: .FiresOnRecordUpdate)
        
        let info = CKNotificationInfo()
        info.alertBody = "New Contact"
        subscription.notificationInfo = info
        
        self.db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("Successfully subscribed")
            }
        }
        
    }
    
    func checkForNewContacts(currentUser: CurrentUser) {
        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        db.addOperation(operation)
        operation.recordFetchedBlock = { (record) in
            let contacts = record.valueForKey("contacts") as! [String]
            for contact in contacts {
                self.fetchUserForPhoneNumber(contact, completion: { (user) in
                    
                    if let user = user {
                        let notification = UILocalNotification()
                        notification.alertBody = "\(user.name!) has added you as a contact."
                        notification.alertTitle = "You have been added as a contact"
                        notification.fireDate = NSDate()
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        
                    }
                    
                })
            }
        }
        
    }
    
    func addCurrentUserToOtherUsersContactList(currentUser: CurrentUser, phoneNumber: String) {
        fetchUserForPhoneNumber(phoneNumber) { (otherUser) in
            if let otherUser = otherUser {
                self.tempContactsArray.append(currentUser.phoneNumber!)
                self.db.fetchRecordWithID(CKRecordID(recordName: otherUser.uuid!), completionHandler: { (record, error) in
                    if let record = record {
                        record.setValue(self.tempContactsArray, forKey: "contacts")
                        self.db.saveRecord(record, completionHandler: { (record, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            } else {
                                print("Success")
                            }
                        })
                    }
                })
            }
        }
=======
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
>>>>>>> parent of 847ba23... Merge remote-tracking branch 'origin/master' into map
    }
    
    func setupSubscription(eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "canceledETA = %d", 1)
        let predicate2 = NSPredicate(format: "id = %@", eta.id!)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnRecordUpdate)
        
        let info = CKNotificationInfo()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        if let eta = eta.eta {
            let etaString = formatter.stringFromDate(eta)
        
        info.alertBody = "Your friend will be home around \(etaString)"
        }
        subscription.notificationInfo = info
<<<<<<< HEAD
        NSUserDefaults.standardUserDefaults().setValue(subscription.subscriptionID, forKey: "ownSubscription")
=======
        
        let db = CKContainer.defaultContainer().publicCloudDatabase
>>>>>>> parent of 847ba23... Merge remote-tracking branch 'origin/master' into map
        
        db.saveSubscription(subscription) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
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