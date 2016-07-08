//
//  UserController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation
import CoreData

class UserController {
    
    static let sharedController = UserController()
    
    var selectedArray: [CNContact] = []
    
    var currentUser: CurrentUser? {
        let request = NSFetchRequest(entityName: "CurrentUser")
        
        do {
            let currentUsers = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [CurrentUser]
            return currentUsers.first
        } catch {
            return nil
        }
    }
    
    func createUserFromFetchedData(name: String, safeLocation: CLLocation, phoneNumber: String, uuid: String) {
        _ = User(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
        saveToPersistentStorage()
    }
    
    func createCurrentUserFromFetchedData(record: CKRecord) {
        _ = CurrentUser(record: record)
        saveToPersistentStorage()
    }
    
    func signOutCurrentUser() {
        let moc = Stack.sharedStack.managedObjectContext
        if let currentUser = currentUser {
            moc.deleteObject(currentUser)
            saveToPersistentStorage()
        }
    }
    
    func createUser(name: String, password: String, safeLocation: CLLocation, phoneNumber: String, completion: () -> Void) {
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        let uuid = NSUUID().UUIDString
        let userRecord = CKRecord(recordType: "User", recordID: CKRecordID(recordName: uuid))
        userRecord.setValue(name, forKey: "name")
        userRecord.setValue(safeLocation, forKey: "safeLocation")
        userRecord.setValue(phoneNumber, forKey: "phoneNum")
        userRecord.setValue(uuid, forKey: "uuid")
        userRecord.setValue(password, forKey: "password")
        
        let contactsRecord = CKRecord(recordType: "contacts")
        contactsRecord.setValue(uuid, forKey: "userUUID")
        
        let newETARecord = CKRecord(recordType: "userNewETA")
        newETARecord.setValue(uuid, forKey: "userUUID")
        
        let notificationsRecord = CKRecord(recordType: "notifications")
        notificationsRecord.setValue(false, forKey: "contacts")
        notificationsRecord.setValue(false, forKey: "userNewETA")
        notificationsRecord.setValue(uuid, forKey: "uuid")
        
        
        privateDatabase.saveRecord(userRecord, completionHandler: { (record, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("Successfully saved user's data to the private database.")
            }
        })
        
        publicDatabase.saveRecord(userRecord) { (record, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                _ = CurrentUser(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
                UserController.sharedController.saveToPersistentStorage()
                publicDatabase.saveRecord(contactsRecord, completionHandler: { (record, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        publicDatabase.saveRecord(newETARecord, completionHandler: { (record, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            } else {
                                publicDatabase.saveRecord(notificationsRecord, completionHandler: { (record, error) in
                                    if error != nil {
                                        print(error?.localizedDescription)
                                    } else {
                                        completion()
                                    }
                                })
                            }
                            
                        })
                    }
                })
            }
        }
    }
    
    
    
    func saveToPersistentStorage() {
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
    
}





