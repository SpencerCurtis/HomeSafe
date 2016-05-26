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
    
    let db = CKContainer.defaultContainer().publicCloudDatabase
    
    var tempContactsArray: [String] = []
    
    func fetchUserForPhoneNumber(phoneNumber: String, completion: (otherUser: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        db.addOperation(operation)
        operation.recordFetchedBlock = { (record) in
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
    
    // This should be implemented as soon as an account (user) is made on the signup screen. It will set-up a subscription to check if any other user has added them as a contact (potential watcher)
    
    func subscribeToUsersAddingCurrentUserToContactList(currentUser: CurrentUser, completion: () -> Void) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let subscription = CKSubscription(recordType: "contacts", predicate: predicate, options: .FiresOnRecordUpdate)
            
            let info = CKNotificationInfo()
            info.alertBody = "You have been added as someone's contact"
            info.shouldSendContentAvailable = true
            subscription.notificationInfo = info
            
            self.db.saveSubscription(subscription) { (subscription, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("Successfully subscribed to current user's contacts record")
                    completion()
                }
            }
        }
    }
    
    
    
    
    
    
    func subscribeToUsersAddingCurrentUserToNewETA(currentUser: CurrentUser, completion: () -> Void) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let subscription = CKSubscription(recordType: "userNewETA", predicate: predicate, options: .FiresOnRecordUpdate)
            
            let info = CKNotificationInfo()
            info.alertBody = "Someone has begun an ETA and wants to you be their watcher."
            info.shouldSendContentAvailable = true
            subscription.notificationInfo = info
            
            self.db.saveSubscription(subscription) { (subscription, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("Successfully subscribed to current user's userNewETA record")
                    completion()
                }
            }
        }
    }
    
    
    func checkForNewContacts(currentUser: CurrentUser) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "uuid = %@", uuid)
            let query = CKQuery(recordType: "contacts", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
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
            db.addOperation(operation)
        }
    }
    
    // Make an alert that will call this function when the user gets a notification saying they've been added as _'s contact.
    // Call this function if they want to add the contact back.
    
    func addCurrentUserToOtherUsersContactList(currentUser: CurrentUser, phoneNumber: String) {
        fetchUserForPhoneNumber(phoneNumber) { (otherUser) in
            if let otherUser = otherUser, uuid = otherUser.uuid ,phoneNumber = currentUser.phoneNumber {
                self.tempContactsArray.append(phoneNumber)
                self.db.fetchRecordWithID(CKRecordID(recordName: uuid), completionHandler: { (record, error) in
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
    }
    
    func addUsersToContactList(currentUser: CurrentUser, users: [User]) {
        for user in users {
            self.fetchUserForPhoneNumber(user.phoneNumber!, completion: { (otherUser) in
                if let otherUser = otherUser {
                    let predicate = NSPredicate(format: "uuid = %@", otherUser.uuid!)
                    let query = CKQuery(recordType: "contacts", predicate: predicate)
                    let operation = CKQueryOperation(query: query)
                    var contactArray: [String] = []
                    operation.recordFetchedBlock = { (record) in
                        let contacts = record.valueForKey("contacts") as! [String]
                        for contact in contacts {
                            contactArray.append(contact)
                        }
        
                        contactArray.append(currentUser.phoneNumber!)
                        record.setValue(contactArray, forKey: "contacts")
                        
                        let saveOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                        saveOperation.savePolicy = .ChangedKeys
                    }
                }
            })
        }
    }
    
    // THIS IS A TEST FUNCTION
    func addPhoneNumber(currentUser: CurrentUser) {
        let predicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
        let query = CKQuery(recordType: "contacts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            var contacts: [String] = []
            let newContacts = record.valueForKey("contacts") as! [String]
            for contact in newContacts {
                contacts.append(contact)
            }
            contacts.append(currentUser.phoneNumber!)
            record.setValue(contacts, forKey: "contacts")
            self.db.saveRecord(record, completionHandler: { (record, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("success")
                }
            })
        }
        db.addOperation(operation)
    }
    
    // General subscription by user to check if said user has made a new ETA.
    // Not sure if we need this though if the user is going to select the users to notify.
    
    func setupSubscriptionForUser(user: User) {
        let predicate = NSPredicate(format: "userPhoneNumber = %@", user.phoneNumber!)
        
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnRecordCreation)
        let info = CKNotificationInfo()
        info.alertBody = "\(user.name!) has begun a new ETA"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        //        let record = CKRecord(recordType: "ETA")
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
                // Handle the crap out of the error, like send an alert or something.
            } else {
                
            }
        }
    }
    
    func checkForNewNotifications(currentUser: CurrentUser) {
        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
        let query = CKQuery(recordType: "notifications", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            let contacts = record.valueForKey("contacts") as! Int
            let userNewETA = record.valueForKeyPath("userNewETA") as! Int
            if contacts == 1 {
                
                let contactsPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
                let contactsQuery = CKQuery(recordType: "contacts", predicate: contactsPredicate)
                let contactsOperation = CKQueryOperation(query: contactsQuery)
                contactsOperation.recordFetchedBlock = { (record) in
                    var nameArray: [String] = []
                    let contactsArray = record.valueForKey("contacts") as! [String]
                    for contact in contactsArray {
                        self.fetchUserForPhoneNumber(contact, completion: { (otherUser) in
                            if let otherUser = otherUser {
                                nameArray.append(otherUser.name!)
                            }
                        })
                    }
                    NSUserDefaults.standardUserDefaults().setValue(nameArray, forKey: "nameArrayForContacts")
                }
                self.db.addOperation(contactsOperation)
                record.setValue(0, forKey: "contacts")
                let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                self.db.addOperation(operation)
            }
            
            if userNewETA == 1 {
                let ETAPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
                let ETAQuery = CKQuery(recordType: "userNewETA", predicate: ETAPredicate)
                let ETAOperation = CKQueryOperation(query: ETAQuery)
                ETAOperation.recordFetchedBlock = { (record) in
                    var nameArray: [String] = []
                    let contactsArray = record.valueForKey("contacts") as! [String]
                    for contact in contactsArray {
                        self.fetchUserForPhoneNumber(contact, completion: { (otherUser) in
                            if let otherUser = otherUser {
                                nameArray.append(otherUser.name!)
                            }
                        })
                    }
                    NSUserDefaults.standardUserDefaults().setValue(nameArray, forKey: "nameArrayForETA")
                }
                self.db.addOperation(ETAOperation)
                record.setValue(0, forKey: "userNewETA")
                let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                self.db.addOperation(operation)

                
                
                
            }
            
        }
    }
    
    
    func notifySelectedUsersOfNewETA(users: [User], currentUser: CurrentUser) {
        for user in users {
            if let uuid = user.uuid, phoneNumber = currentUser.phoneNumber {
                let predicate = NSPredicate(format: "uuid = %@", uuid)
                let query = CKQuery(recordType: "userNewETA", predicate: predicate)
                let operation = CKQueryOperation(query: query)
                operation.recordFetchedBlock = { (record) in
                    record.setValue(phoneNumber, forKey: "newETA")
                    self.db.saveRecord(record, completionHandler: { (record, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else {
                            print("\(user.name!) has been notified successfully")
                        }
                    })
                }
                db.addOperation(operation)
            }
        }
    }
    
    
    func loadETAForUser(user: User, completion: (eta: EstimatedTimeOfArrival) -> Void) {
        let predicate = NSPredicate(format: "id = %@", user.uuid!)
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
                    if let eta = ETA {
                        print(eta.userName)
                        ETAController.sharedController.saveToPersistentStorage()
                        completion(eta: eta)
                    }
                }
            })
        }
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
    }
    
    func setupSubscriptionForETA(eta: EstimatedTimeOfArrival) {
        
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .FiresOnRecordUpdate)
        
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            
            
            let info = CKNotificationInfo()
            info.desiredKeys = ["canceledETA", "homeSafe", "inDanger"]
            info.shouldSendContentAvailable = true
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            if let etaDate = record.valueForKey("ETA") as? NSDate {
                let etaString = formatter.stringFromDate(etaDate)
                
                info.alertBody = "Your friend will be home around \(etaString)"
                
                subscription.notificationInfo = info
                NSUserDefaults.standardUserDefaults().setValue(subscription.subscriptionID, forKey: "ownSubscription")
                
                self.db.saveSubscription(subscription) { (result, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        self.ETASubscriptions(eta, completion: {
                            print("Successfully subscribed to \(eta.userName)'s ETA")
                            
                        })
                        
                    }
                }
            }
        }
        db.addOperation(operation)
    }
    
    func subscribeToCanceledETAChanges(eta: EstimatedTimeOfArrival, completion: () -> Void) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let predicate2 = NSPredicate(format: "canceledETA = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnce)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["canceledETA"]
        info.alertBody = "\(eta.userName!) has canceled their ETA"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to canceledETA changes")
                completion()
            }
        }
    }
    
    func subscribeToHomeSafeETAChanges(eta: EstimatedTimeOfArrival, completion: () -> Void) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let predicate2 = NSPredicate(format: "homeSafe = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnce)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["homeSafe"]
        info.alertBody = "\(eta.userName!) has arrived at their safe location."
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to homeSafe ETA changes")
                completion()
            }
        }
    }
    
    func subscribeToInDangerETAChanges(eta: EstimatedTimeOfArrival, completion: () -> Void) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let predicate2 = NSPredicate(format: "inDanger = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnce)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["inDanger"]
        info.alertBody = "\(eta.userName!) is in danger! Please make contact"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        db.saveSubscription(subscription) { (subscription, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to inDanger ETA changes")
                completion()
            }
        }
    }
    
    func ETASubscriptions(eta: EstimatedTimeOfArrival, completion: () -> Void) {
        subscribeToCanceledETAChanges(eta) {
            self.subscribeToHomeSafeETAChanges(eta, completion: {
                self.subscribeToInDangerETAChanges(eta, completion: {
                    completion()
                })
            })
        }
    }
    
    
}