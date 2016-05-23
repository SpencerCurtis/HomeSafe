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
        
        publicDatabase.saveRecord(record) { (record, error) in
            let currentUser = CurrentUser(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber, uuid: uuid)
            UserController.sharedController.saveToPersistentStorage()
            completion()
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






