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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class CloudKitController {
    
    static let sharedController = CloudKitController()
    
    let db = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //    func checkForPrivateUserData(completion: () -> Void) {
    //
    //
    //        privateDatabase.addOperation(op)
    //    }
    //
    
    func fetchUserForPhoneNumber(_ phoneNumber: String, completion: @escaping (_ otherUser: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records, error) in
            guard records?.count > 0 else { print("No users were found with phone number \(phoneNumber)")
                completion(nil); return }
            if let records = records {
                print(records.count)
                for record in records {
                    let user = User(record: record)
                    ContactsController.sharedController.saveToPersistentStorage()
                    
                    
                    if let currentETAID = record.value(forKey: "currentETAID") as? String {
                        UserDefaults.standard.setValue(currentETAID, forKey: "currentETAID")
                    }
                    completion(user)
                    
                    
                }
                
            }
        }
    }
    
    func fetchUsersInformationWithPhoneNumber(_ phoneNumber: String, completion: @escaping (_ otherUser: User?) -> Void) {
        let predicate = NSPredicate(format: "phoneNum = %@", phoneNumber)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records, error) in
            guard records?.count > 0 else { print("No users were found with phone number \(phoneNumber)")
                completion(nil); return }
            if let records = records {
                print(records.count)
                for record in records {
                    let user = User(record: record)
                    if let currentETAID = record.value(forKey: "currentETAID") as? String {
                        UserDefaults.standard.setValue(currentETAID, forKey: "currentETAID")
                    }
                    completion(user)
                }
                
            }
        }
    }
    
    func logInUser(_ phoneNumber: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        let predicate1 = NSPredicate(format: "phoneNum == %@", phoneNumber)
        let predicate2 = NSPredicate(format: "password == %@", password)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        let query = CKQuery(recordType: "User", predicate: compoundPredicate)
        
        // Perhaps change the public User record so it doesn't have their password and make the private db query work.
        self.db.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error { completion(false); print(error.localizedDescription) }
            
            guard let records = records else { print("No records were found matching your phone number and/or password. Try again."); completion(false); return }
            if let record = records.last {
                UserController.sharedController.createCurrentUserFromFetchedData(record)
                completion(true)
            }
        }
    }
    
    func fetchSubscriptions(_ completion: (() -> Void)? = nil) {
        self.db.fetchAllSubscriptions { (subscriptions, error) in
            if let error = error { print(error.localizedDescription); return }
            completion?()
        }
    }
    
    
    // This should be implemented as soon as an account (user) is made on the signup screen. It will set-up a subscription to check if any other user has added them as a contact (potential watcher)
    
    func subscribeToUsersAddingCurrentUserToContactList(_ currentUser: CurrentUser, completion: @escaping () -> Void) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let subscription = CKSubscription(recordType: "contacts", predicate: predicate, options: .firesOnRecordUpdate)
            
            let info = CKNotificationInfo()
            info.alertBody = "You have been added as someone's contact"
            info.shouldSendContentAvailable = true
            subscription.notificationInfo = info
            
            self.db.save(subscription, completionHandler: { (subscription, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion()
                } else {
                    print("Successfully subscribed to current user's contacts record")
                    completion()
                }
            })
        }
    }
    
    
    
    
    
    
    func subscribeToUsersAddingCurrentUserToNewETA(_ currentUser: CurrentUser, completion: @escaping () -> Void) {
        if let uuid = currentUser.uuid {
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let subscription = CKSubscription(recordType: "userNewETA", predicate: predicate, options: .firesOnRecordUpdate)
            
            let info = CKNotificationInfo()
            info.alertBody = "Someone has begun an ETA and wants to you be their watcher."
            info.shouldSendContentAvailable = true
            subscription.notificationInfo = info
            
            self.db.save(subscription, completionHandler: { (subscription, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Successfully subscribed to current user's userNewETA record")
                    completion()
                }
            })
        }
    }
    
    
    func checkForNewContacts(_ currentUser: CurrentUser, completion: @escaping (_ users: [User]?) -> Void) {
        if let uuid = currentUser.uuid {
            let group = DispatchGroup()
            let predicate = NSPredicate(format: "userUUID = %@", uuid)
            let query = CKQuery(recordType: "contacts", predicate: predicate)
            var users: [User] = []
            var counter = 0
            
            self.db.perform(query, inZoneWith: nil, completionHandler: { (records, errors) in
                guard let records = records else { completion(nil); return }
                for record in records {
                    let contacts = record.value(forKey: "contacts") as! [String]
                    for contact in contacts {
                        group.enter()
                        
                        self.fetchUsersInformationWithPhoneNumber(contact, completion: { (user) in
                            if let user = user {
                                //
                                //                            let notification = UILocalNotification()
                                //                            notification.alertBody = "\(user.name!) has added you as a contact."
                                //                            notification.alertTitle = "You have been added as a contact"
                                //                            notification.fireDate = NSDate()
                                //                            UIApplication.sharedApplication().scheduleLocalNotification(notification)
                                
                                users.append(user)
                                group.leave()
                                counter -= 1
                                
                                
                            }
                            
                        })
                    }
                    
                    group.notify(queue: DispatchQueue.main, execute: {
                        completion(users)
                    })
                    
                    
                }
                
            })
            
        }
    }
    
    // Make an alert that will call this function when the user gets a notification saying they've been added as _'s contact.
    // Call this function if they want to add the contact back.
    
    func addCurrentUserToOtherUsersContactList(_ currentUser: CurrentUser, phoneNumber: String, completion: @escaping (_ success: Bool) -> Void) {
        var tempContactsArray: [String] = []
        fetchUserForPhoneNumber(phoneNumber) { (otherUser) in
            if otherUser == nil {
                completion(false)
            }
            if let otherUser = otherUser, let uuid = otherUser.uuid, let phoneNumber = currentUser.phoneNumber {
                tempContactsArray.append(phoneNumber)
                self.fetchContactsForUserUUID(uuid, completion: { (contactsRecord) in
                    
                    let _ = ContactsController.sharedController.createUserFromFetchedRecord(contactsRecord)
                    UserController.sharedController.saveToPersistentStorage()
                    let contacts = contactsRecord.value(forKey: "contacts") as? [String]
                    if let contacts = contacts {
                        tempContactsArray = contacts
                    }
                    
                    contactsRecord.setObject(tempContactsArray as CKRecordValue?, forKey: "contacts")
                    let op = CKModifyRecordsOperation(recordsToSave: [contactsRecord], recordIDsToDelete: nil)
                    op.perRecordCompletionBlock = { (record, error) in
                        if let error = error {
                            print(error.localizedDescription); completion(false); return
                        } else {
                            
                            print("Success")
                        }
                    }
                    
                    op.completionBlock = { () in
                        completion(true)
                    }
                    self.db.add(op)
                    
                })
            }
        }
    }
    
    
    func fetchContactsForUserUUID(_ uuid: String, completion: @escaping (_ contactsRecord: CKRecord) -> Void) {
        let predicate = NSPredicate(format: "userUUID == %@", uuid)
        let query = CKQuery(recordType: "contacts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            completion(record)
        }
        self.db.add(operation)
    }
    
    func addUsersToContactList(_ currentUser: CurrentUser, phoneNumbers: [String], completion: @escaping (_ success: Bool) -> Void ) {
        let group = DispatchGroup()
        
        for phoneNumber in phoneNumbers {
            
            group.enter()
            var contactsNotInICloud: [String] = []
            self.fetchUserForPhoneNumber(phoneNumber, completion: { (otherUser) in
                guard let otherUser = otherUser else {
                    print("User with phone number: \(phoneNumber) is not in the HomeSafe database")
                    contactsNotInICloud.append(phoneNumber)
                    UserDefaults.standard.set(contactsNotInICloud, forKey: "contactsForSMS")
                    if contactsNotInICloud.count != 0 {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "noContactFound"), object: nil)
                    }
                    group.leave()
                    completion(false)
                    return
                }
                
                let predicate = NSPredicate(format: "userUUID = %@", otherUser.uuid!)
                let query = CKQuery(recordType: "contacts", predicate: predicate)
                self.db.perform(query, inZoneWith: nil, completionHandler: { (records, errors) in
                    guard let records = records else { completion(false); return }
                    var contactArray: [String] = []
                    print(records.count)
                    for record in records {
                        let contacts = record.value(forKey: "contacts") as? [String] ?? []
                        for contact in contacts {
                            contactArray.append(contact)
                        }
                        
                        contactArray.append(currentUser.phoneNumber!)
                        record.setValue(contactArray, forKey: "contacts")
                        
                        self.db.save(record, completionHandler: { (record, error) in
                            
                            if let error = error { print(error.localizedDescription); return }
                            
                            print("success")
                            group.leave()
                            
                        })
                    }
                })
            })
            group.notify(queue: DispatchQueue.main) {
                completion(true)
            }
        }
    }
    
    // General subscription by user to check if said user has made a new ETA.
    // Not sure if we need this though if the user is going to select the users to notify.
    
    func setupSubscriptionForUser(_ user: User) {
        let predicate = NSPredicate(format: "userPhoneNumber = %@", user.phoneNumber!)
        
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .firesOnRecordCreation)
        let info = CKNotificationInfo()
        info.alertBody = "\(user.name!) has begun a new ETA"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        //        let record = CKRecord(recordType: "ETA")
        self.db.save(subscription, completionHandler: { (subscription, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
            }
        })
    }
    
    func checkForNewETA(_ currentUser: CurrentUser, completion: @escaping () -> Void) {
        let ETAPredicate = NSPredicate(format: "userUUID = %@", currentUser.uuid!)
        let ETAQuery = CKQuery(recordType: "userNewETA", predicate: ETAPredicate)
        
        var phoneNumberArray: [String] = []
        
        self.db.perform(ETAQuery, inZoneWith: nil) { (records, errors) in
            guard let records = records else { completion(); return }
            for record in records {
                
                print(record)
                let contactsArray = record.value(forKey: "newETA") as? [String] ?? []
                for contact in contactsArray {
                    self.fetchUsersInformationWithPhoneNumber(contact, completion: { (otherUser) in
                        guard let otherUser = otherUser else { return }
                        phoneNumberArray.append(otherUser.phoneNumber!)
                        
                        UserDefaults.standard.setValue(phoneNumberArray, forKey: "phoneNumberArrayForETA")
                        record.setValue([], forKey: "newETA") // May need to change the value here
                        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                        operation.perRecordCompletionBlock = { (record, error) in
                            
                            if let error = error { print(error.localizedDescription); return }
                            
                            print("Record's newETA value has been changed back to nothing.")
                            completion()
                        }
                        self.db.add(operation)
                    })
                }
            }
        }
    }
    
    
    
    
    func fetchETAAndSubscribe(_ phoneNumber: String) {
        
        fetchUsersInformationWithPhoneNumber(phoneNumber) { (otherUser) in
            if otherUser != nil {
                
                let currentETAID = UserDefaults.standard.value(forKey: "currentETAID") as! String
                let predicate = NSPredicate(format: "id = %@", currentETAID)
                
                let query = CKQuery(recordType: "ETA", predicate: predicate)
                let op = CKQueryOperation(query: query)
                op.recordFetchedBlock = { (record) in
                    
                    let etaTime = record.value(forKey: "ETA") as! Date
                    let latitude = record.value(forKey: "latitude") as! Double
                    let longitude = record.value(forKey: "longitude") as! Double
                    let userName = record.value(forKey: "name") as! String
                    let id = record.value(forKey: "id") as! String
                    let recordID = record.recordID.recordName
                    let eta = EstimatedTimeOfArrival(eta: etaTime, latitude: latitude, longitude: longitude, userName: userName, id: id, recordID: recordID)
                    if let currentUser = UserController.sharedController.currentUser {
                        self.ETASubscriptions(eta, phoneNumber: currentUser.phoneNumber!, completion: {
                            print("You have been successfully subscribed to the ETA")
                        })
                    }
                    
                }
                self.db.add(op)
            }
        }
    }
    
    
    
    func setCurrentETA(_ currentUser: CurrentUser, etaID: String) {
        let predicate = NSPredicate(format: "uuid = %@", currentUser.uuid!)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let op = CKQueryOperation(query: query)
        op.recordFetchedBlock = { (record) in
            record.setValue(etaID, forKey: "currentETAID")
            
            let saveOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.add(saveOp)
        }
        db.add(op)
    }
    
    func notifySelectedUsersOfNewETA(_ users: [User], currentUser: CurrentUser) {
        for user in users {
            if let uuid = user.uuid, let phoneNumber = currentUser.phoneNumber {
                let predicate = NSPredicate(format: "userUUID = %@", uuid)
                let query = CKQuery(recordType: "userNewETA", predicate: predicate)
                let operation = CKQueryOperation(query: query)
                operation.recordFetchedBlock = { (record) in
                    var phoneNumbers = record.value(forKey: "newETA") as? [String] ?? []
                    phoneNumbers.append(phoneNumber)
                    record.setValue(phoneNumbers, forKey: "newETA")
                    let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                    op.perRecordCompletionBlock = { (record, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Successfully sent to \(user.name!)!")
                        }
                    }
                    self.db.add(op)
                }
                self.db.add(operation)
            }
            
        }
    }
    
    
    func loadETAForUser(_ user: User, completion: @escaping (_ eta: EstimatedTimeOfArrival) -> Void) {
        let predicate = NSPredicate(format: "id = %@", user.uuid!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        var eta: EstimatedTimeOfArrival?
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            let etaTime = record["ETA"] as! Date
            let latitude = record["latitude"] as! Double
            let longitude = record["longitude"] as! Double
            let name = record["name"] as! String
            let id = record["id"] as! String
            
            eta = EstimatedTimeOfArrival(eta: etaTime, latitude: latitude, longitude: longitude, userName: name, id: id, recordID: record.recordID.recordName)
        }
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async(execute: { () -> Void in
                if error == nil {
                    if let eta = eta {
                        ETAController.sharedController.saveToPersistentStorage()
                        completion(eta)
                    }
                }
            })
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    // TODO: Implement this.
    func setupSubscriptionForETA(_ eta: EstimatedTimeOfArrival, phoneNumber: String) {
        
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let subscription = CKSubscription(recordType: "ETA", predicate: predicate, options: .firesOnRecordUpdate)
        
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            
            
            let info = CKNotificationInfo()
            info.desiredKeys = ["canceledETA", "homeSafe", "inDanger"]
            info.shouldSendContentAvailable = true
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            if let etaDate = record.value(forKey: "ETA") as? Date {
                let etaString = formatter.string(from: etaDate)
                
                info.alertBody = "Your friend will be home around \(etaString)"
                
                subscription.notificationInfo = info
                UserDefaults.standard.setValue(subscription.subscriptionID, forKey: "ownSubscription")
                
                self.db.save(subscription, completionHandler: { (result, error) in
                    if let error = error { print(error.localizedDescription) }
                })
            }
        }
        db.add(operation)
    }
    
    func subscribeToCanceledETAChanges(_ eta: EstimatedTimeOfArrival, phoneNumber: String, completion: @escaping () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "canceledETA = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .firesOnRecordUpdate)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["canceledETA"]
        info.alertBody = "\(eta.userName!) has canceled their ETA"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        self.db.save(subscription, completionHandler: { (subscription, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to canceledETA changes")
                completion()
            }
        })
    }
    
    func subscribeToHomeSafeETAChanges(_ eta: EstimatedTimeOfArrival, phoneNumber: String, completion: @escaping () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "homeSafe = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .firesOnRecordUpdate)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["homeSafe"]
        info.alertBody = "\(eta.userName!) has arrived at their safe location."
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        self.db.save(subscription, completionHandler: { (subscription, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to homeSafe ETA changes")
                completion()
            }
        })
    }
    
    func subscribeToInDangerETAChanges(_ eta: EstimatedTimeOfArrival, phoneNumber: String, completion: @escaping () -> Void) {
        let predicate = NSPredicate(format: "followers CONTAINS %@", phoneNumber)
        let predicate2 = NSPredicate(format: "inDanger = %d", 1)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let subscription = CKSubscription(recordType: "ETA", predicate: combinedPredicate, options: .firesOnRecordUpdate)
        
        let info = CKNotificationInfo()
        info.desiredKeys = ["inDanger"]
        info.alertBody = "\(eta.userName!) is in danger! Please make contact"
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        self.db.save(subscription, completionHandler: { (subscription, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                print("Sucessfully subscribed to inDanger ETA changes")
                UserDefaults.standard.setValue(subscription?.subscriptionID, forKey: "inDangerSubscriptionID")
                completion()
            }
        })
    }
    
    func ETASubscriptions(_ eta: EstimatedTimeOfArrival, phoneNumber: String, completion: @escaping () -> Void) {
        subscribeToCanceledETAChanges(eta, phoneNumber: phoneNumber) {
            self.subscribeToHomeSafeETAChanges(eta, phoneNumber: phoneNumber, completion: {
                self.subscribeToInDangerETAChanges(eta, phoneNumber: phoneNumber, completion: {
                    completion()
                })
            })
        }
    }
    
    
}
