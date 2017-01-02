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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentUser")
        
        do {
            let currentUsers = try Stack.sharedStack.managedObjectContext.fetch(request) as! [CurrentUser]
            return currentUsers.first
        } catch {
            return nil
        }
    }
    
    func createUserFromFetchedData(_ name: String, safeLocation: CLLocation, phoneNumber: String, uuid: String) {
        _ = User(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
        saveToPersistentStorage()
    }
    
    func createCurrentUserFromFetchedData(_ record: CKRecord) {
        _ = CurrentUser(record: record)
        saveToPersistentStorage()
    }
    
    func signOutCurrentUser() {
        let moc = Stack.sharedStack.managedObjectContext
        if let currentUser = currentUser {
            moc.delete(currentUser)
            deleteAllContactsUponSigningOut()
            saveToPersistentStorage()
        }
    }
    
    func createUser(_ name: String, password: String, safeLocation: CLLocation, phoneNumber: String, completion: @escaping () -> Void) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let uuid = UUID().uuidString
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
        
        
        _ = CurrentUser(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
        UserController.sharedController.saveToPersistentStorage()
        let op = CKModifyRecordsOperation(recordsToSave: [userRecord, contactsRecord, newETARecord], recordIDsToDelete: nil)
        publicDatabase.add(op)
        op.perRecordCompletionBlock = { (record, error) in
            guard error == nil else { print("Error saving \(record.recordType): \(error?.localizedDescription)"); return }
        }
        op.completionBlock = {
            completion()
        }
    }
    
    func deleteAllContactsUponSigningOut() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try Stack.sharedStack.managedObjectContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
 
 
 
 
 
