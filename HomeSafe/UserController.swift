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
    
    
    func createUser(name: String, safeLocation: CLLocation, phoneNumber: String, completion: () -> Void) {
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        let uuid = NSUUID().UUIDString
        let record = CKRecord(recordType: "User", recordID: CKRecordID(recordName: uuid))
        record.setValue(name, forKey: "name")
        record.setValue(safeLocation, forKey: "safeLocation")
        record.setValue(phoneNumber, forKey: "phoneNum")
        record.setValue(uuid, forKey: "uuid")
        
        let contactsRecord = CKRecord(recordType: "Contacts")
        contactsRecord.setValue(uuid, forKey: "userUUID")
        
        let newETARecord = CKRecord(recordType: "userNewETA")
        newETARecord.setValue(uuid, forKey: "userUUID")
        
        let notificationsRecord = CKRecord(recordType: "notifications")
        notificationsRecord.setValue(false, forKey: "contacts")
        notificationsRecord.setValue(false, forKey: "userNewETA")
        notificationsRecord.setValue(uuid, forKey: "uuid")
        
        //        let recordsToSave = [record, contactsRecord, newETARecord]
        //        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        //        operation.savePolicy = .AllKeys
        //        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
        //            if error != nil {
        //                print(error?.localizedDescription)
        //            } else {
        //                print("Successfully saved all records")
        //                completion()
        //            }
        //            publicDatabase.addOperation(operation)
        publicDatabase.saveRecord(record) { (record, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let currentUser = CurrentUser(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
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







