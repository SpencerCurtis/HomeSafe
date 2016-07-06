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
    
    func checkForPrivateUserData(completion: () -> Void) {
        let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let op = CKQueryOperation(query: query)
        op.recordFetchedBlock = { (record) in
            let name = record.valueForKey("name") as! String
            let phoneNumber = record.valueForKey("phoneNum") as! String
            let safeLocation = record.valueForKey("safeLocation") as! CLLocation
            let uuid = record.valueForKey("uuid") as! String
            
            UserController.sharedController.createUserFromFetchedData(name, safeLocation: safeLocation, phoneNumber: phoneNumber, uuid: uuid)
            completion()
        }
        
        privateDatabase.addOperation(op)
    }
    
    func fetchUserForPhoneNumber(phoneNumber: String, completion: (otherUser: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        db.performQuery(query, inZoneWithID: nil) { (records, error) in
            guard records?.count > 0 else { print("No users were found with phone number \(phoneNumber)")
                completion(otherUser: nil); return }
            if let records = records {
                print(records.count)
                for record in records {
                    ContactsController.sharedController.createUserFromFetchedRecord(record)
                    
                    if let currentETAID = record.valueForKey("currentETAID") as? String {
                        NSUserDefaults.standardUserDefaults().setValue(currentETAID, forKey: "currentETAID")
                    }
                    
                }
                
            }
        }
    }
    
    func logInUser(phoneNumber: String, password: String, completion: (success: Bool) -> Void) {
        let predicate1 = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let predicate2 = NSPredicate(format: "password = %@", password)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        let query = CKQuery(recordType: "User", predicate: compoundPredicate)
        db.performQuery(query, inZoneWithID: nil) { (records, error) in
            guard error == nil else { completion(success: false); print(error?.localizedDescription); return }
            guard let records = records else { print("No records were found matching your phone number and/or password. Try again."); completion(success: false); return }
            if let record = records.last {
                UserController.sharedController.createCurrentUserFromFetchedData(record)
                completion(success: true)
            }
        }
    }
    
    func fetchSubscriptions(completion: () -> Void) {
        db.fetchAllSubscriptionsWithCompletionHandler { (subscriptions, error) in
            guard error == nil else { print(error?.localizedDescription); return }
            completion()
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
                    completion()
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
    
    
    func checkForNewContacts(currentUser: CurrentUser, completion: (users: [User]) -> Void) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let query = CKQuery(recordType: "contacts", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            var users: [User] = []
            let group = dispatch_group_create()
            operation.recordFetchedBlock = { (record) in
                let contacts = record.valueForKey("contactList") as! [String]
                for contact in contacts {
                    dispatch_group_enter(group)
                    self.fetchUserForPhoneNumber(contact, completion: { (user) in
                        if let user = user {
                            //
                            //                            let notification = UILocalNotification()
                            //                            notification.alertBody = "\(user.name!) has added you as a contact."
                            //                            notification.alertTitle = "You have been added as a contact"
                            //                            notification.fireDate = NSDate()
                            //                            UIApplication.sharedApplication().scheduleLocalNotification(notification)
                            
                            users.append(user)
                            dispatch_group_leave(group)
                            let queue = dispatch_queue_create("contacts", nil)
                            dispatch_group_notify(group, queue, {
                                completion(users: users)
                            })
                        }
                        
                    })
                }
            }
            
            db.addOperation(operation)
        }
        
    }
    
    // Make an alert that will call this function when the user gets a notification saying they've been added as _'s contact.
    // Call this function if they want to add the contact back.
    
    func addCurrentUserToOtherUsersContactList(currentUser: CurrentUser, phoneNumber: String, completion: (success: Bool) -> Void) {
        var tempContactsArray: [String] = []
        fetchUserForPhoneNumber(phoneNumber) { (otherUser) in
            if otherUser == nil {
                completion(success: false)
            }
            if let otherUser = otherUser, uuid = otherUser.uuid, phoneNumber = currentUser.phoneNumber {
                tempContactsArray.append(phoneNumber)
                self.fetchContactsForUserUUID(uuid, completion: { (contactsRecord) in
                    
                    let contacts = contactsRecord.valueForKey("contactList") as? [String]
                    if let contacts = contacts {
                        tempContactsArray = contacts
                    }
                    
                    contactsRecord.setObject(tempContactsArray, forKey: "contactList")
                    let op = CKModifyRecordsOperation(recordsToSave: [contactsRecord], recordIDsToDelete: nil)
                    op.perRecordCompletionBlock = { (record, error) in
                        guard error != nil else { print(error?.localizedDescription); completion(success: false); return }
                        print("Success")
                        completion(success: true)
                    }
                    self.db.addOperation(op)
                    
                })
            }
        }
    }
    
    
    func fetchContactsForUserUUID(uuid: String, completion: (contactsRecord: CKRecord) -> Void) {
        let predicate = NSPredicate(format: "userUUID == %@", uuid)
        let query = CKQuery(recordType: "contacts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            completion(contactsRecord: record)
        }
        self.db.addOperation(operation)
    }
    // DO I EVEN NEED THIS FUNCTION?
    
    func addUsersToContactList(currentUser: CurrentUser, phoneNumbers: [String], completion: () -> Void ) {
        for phoneNumber in phoneNumbers {
            self.fetchUserForPhoneNumber(phoneNumber, completion: { (otherUser) in
                if let otherUser = otherUser {
                    let predicate = NSPredicate(format: "uuid = %@", otherUser.uuid!)
                    let query = CKQuery(recordType: "contacts", predicate: predicate)
                    let operation = CKQueryOperation(query: query)
                    operation.recordFetchedBlock = { (record) in
                        var contactArray: [String] = []
                        let contacts = record.valueForKey("contactList") as! [String]
                        for contact in contacts {
                            contactArray.append(contact)
                        }
                        
                        contactArray.append(currentUser.phoneNumber!)
                        record.setValue(contactArray, forKey: "contactList")
                        
                        self.db.saveRecord(record, completionHandler: { (record, error) in
                            guard error == nil else { print(error?.localizedDescription); return }
                            
                            print("success")
                            completion()
                        })
                    }
                } else {
                    print("User with phone number: \(otherUser!.phoneNumber!) is not in the HomeSafe database")
                    completion()
                }
            })
        }
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
    
    func checkForNewETA(currentUser: CurrentUser, completion: () -> Void) {
        let ETAPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
        let ETAQuery = CKQuery(recordType: "userNewETA", predicate: ETAPredicate)
        let ETAOperation = CKQueryOperation(query: ETAQuery)
        ETAOperation.recordFetchedBlock = { (record) in
            print(record)
            var phoneNumberArray: [String] = []
            let contactsArray = record.valueForKey("newETA") as? [String]
            if let contactsArray = contactsArray {
                for contact in contactsArray {
                    self.fetchUserForPhoneNumber(contact, completion: { (otherUser) in
                        if let otherUser = otherUser {
                            phoneNumberArray.append(otherUser.phoneNumber!)
                            print(otherUser.phoneNumber!) // Remove later.
                            print(otherUser.name) // Remove later.
                            NSUserDefaults.standardUserDefaults().setValue(phoneNumberArray, forKey: "phoneNumberArrayForETA")
                            record.setValue([], forKey: "newETA") // May need to change the value here
                            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                            operation.perRecordCompletionBlock = { (record, error) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else {
                                    print("Record's newETA value has been changed back to nothing.")
                                    completion()
                                }
                            }
                            self.db.addOperation(operation)
                            
                            
                        }
                    })
                    
                    
                }
            }
        }
        self.db.addOperation(ETAOperation)
    }
    
    
    
    
    //    func checkForNewNotifications(currentUser: CurrentUser, completion: () -> Void) {
    //        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
    //        let query = CKQuery(recordType: "notifications", predicate: predicate)
    //        let operation = CKQueryOperation(query: query)
    //
    //        operation.recordFetchedBlock = { (record) in
    //            let contacts = record.valueForKey("contacts") as! Int
    //            let userNewETA = record.valueForKeyPath("userNewETA") as! Int
    //            if contacts == 1 {
    //
    //                let contactsPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
    //                let contactsQuery = CKQuery(recordType: "contacts", predicate: contactsPredicate)
    //                let contactsOperation = CKQueryOperation(query: contactsQuery)
    //                contactsOperation.recordFetchedBlock = { (record) in
    //                    var nameArray: [String] = []
    //                    let contactsArray = record.valueForKey("contacts") as! [String]
    //                    for contact in contactsArray {
    //                        self.fetchUserForPhoneNumber(contact, completion: { (otherUser) in
    //                            if let otherUser = otherUser {
    //                                nameArray.append(otherUser.name!)
    //                            }
    //                        })
    //                    }
    //
    //                    NSUserDefaults.standardUserDefaults().setValue(nameArray, forKey: "nameArrayForContacts")
    //                    completion()
    //                }
    //
    //                self.db.addOperation(contactsOperation)
    //                record.setValue(" ", forKey: "contacts") // May need to change the value here
    //                let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
    //                self.db.addOperation(operation)
    //            }
    //
    //            if userNewETA == 1 {
    //                let ETAPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
    //                let ETAQuery = CKQuery(recordType: "userNewETA", predicate: ETAPredicate)
    //                let ETAOperation = CKQueryOperation(query: ETAQuery)
    //                ETAOperation.recordFetchedBlock = { (record) in
    //                    var nameArray: [String] = []
    //                    let contactsArray = record.valueForKey("contacts") as! [String]
    //                    for contact in contactsArray {
    //                        self.fetchUserForPhoneNumber(contact, completion: { (otherUser) in
    //                            if let otherUser = otherUser {
    //                                nameArray.append(otherUser.name!)
    //                            }
    //                        })
    //                    }
    //
    //                    NSUserDefaults.standardUserDefaults().setValue(nameArray, forKey: "nameArrayForETA")
    //                    completion()
    //
    //                }
    //
    //                self.db.addOperation(ETAOperation)
    //                record.setValue(" ", forKey: "userNewETA") // May need to change the value here
    //                let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
    //                self.db.addOperation(operation)
    //            }
    //
    //        }
    //    }
    
    func fetchETAAndSubscribe(phoneNumber: String) {
        
        fetchUserForPhoneNumber(phoneNumber) { (otherUser) in
            if otherUser != nil {
                
                let currentETAID = NSUserDefaults.standardUserDefaults().valueForKey("currentETAID") as! String
                let predicate = NSPredicate(format: "id = %@", currentETAID)
                
                let query = CKQuery(recordType: "ETA", predicate: predicate)
                let op = CKQueryOperation(query: query)
                op.recordFetchedBlock = { (record) in
                    
                    let etaTime = record.valueForKey("ETA") as! NSDate
                    let latitude = record.valueForKey("latitude") as! Double
                    let longitude = record.valueForKey("longitude") as! Double
                    let userName = record.valueForKey("name") as! String
                    let id = record.valueForKey("id") as! String
                    let recordID = record.recordID.recordName
                    let eta = EstimatedTimeOfArrival(eta: etaTime, latitude: latitude, longitude: longitude, userName: userName, id: id, recordID: recordID)
                    if let currentUser = UserController.sharedController.currentUser {
                        self.ETASubscriptions(eta, phoneNumber: currentUser.phoneNumber!, completion: {
                            print("You have been successfully subscribed to the ETA")
                        })
                    }
                    
                }
                self.db.addOperation(op)
            }
        }
    }
    
    
    
    func setCurrentETA(currentUser: CurrentUser, etaID: String) {
        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let op = CKQueryOperation(query: query)
        op.recordFetchedBlock = { (record) in
            record.setValue(etaID, forKey: "currentETAID")
            
            let saveOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.addOperation(saveOp)
        }
        db.addOperation(op)
    }
    
    func notifySelectedUsersOfNewETA(users: [User], currentUser: CurrentUser) {
        for user in users {
            fetchUserForPhoneNumber(user.phoneNumber!, completion: { (otherUser) in
                if let uuid = otherUser!.uuid, phoneNumber = currentUser.phoneNumber {
                    let predicate = NSPredicate(format: "userUUID = %@", uuid)
                    let query = CKQuery(recordType: "userNewETA", predicate: predicate)
                    let operation = CKQueryOperation(query: query)
                    operation.recordFetchedBlock = { (record) in
                        var phoneNumbers = record.valueForKey("newETA") as? [String] ?? []
                        print(phoneNumbers)
                        phoneNumbers.append(phoneNumber)
                        print(phoneNumbers)
                        record.setValue(phoneNumbers, forKey: "newETA")
                        print(record)
                        let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                        op.perRecordCompletionBlock = { (record, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            } else {
                                print("Successfully sent to \(user.name!)!")
                            }
                        }
                        self.db.addOperation(op)
                    }
                    self.db.addOperation(operation)
                }
                
            })
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
    
    
    // TODO: Implement this.
    func setupSubscriptionForETA(eta: EstimatedTimeOfArrival, phoneNumber: String) {
        
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
                        
                        
                    }
                }
            }
        }
        db.addOperation(operation)
    }
    
    func subscribeToCanceledETAChanges(eta: EstimatedTimeOfArrival, phoneNumber: String, completion: () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "canceledETA = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnRecordUpdate)
        
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
    
    func subscribeToHomeSafeETAChanges(eta: EstimatedTimeOfArrival, phoneNumber: String, completion: () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "homeSafe = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnRecordUpdate)
        
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
    
    func subscribeToInDangerETAChanges(eta: EstimatedTimeOfArrival, phoneNumber: String, completion: () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "inDanger = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .FiresOnRecordUpdate)
        
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
                NSUserDefaults.standardUserDefaults().setValue(subscription?.subscriptionID, forKey: "inDangerSubscriptionID")
                completion()
            }
        }
    }
    
    func ETASubscriptions(eta: EstimatedTimeOfArrival, phoneNumber: String, completion: () -> Void) {
        subscribeToCanceledETAChanges(eta, phoneNumber: phoneNumber) {
            self.subscribeToHomeSafeETAChanges(eta, phoneNumber: phoneNumber, completion: {
                self.subscribeToInDangerETAChanges(eta, phoneNumber: phoneNumber, completion: {
                    completion()
                })
            })
        }
    }
    
    
}