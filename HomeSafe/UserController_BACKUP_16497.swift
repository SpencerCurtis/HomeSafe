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
    
    
    func createUser(name: String, safeLocation: CLLocation, phoneNumber: String) {
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        let record = CKRecord(recordType: "User")
        record.setValue(name, forKey: "name")
        record.setValue(safeLocation, forKey: "safeLocation")
        record.setValue(phoneNumber, forKey: "phoneNum")
        
        publicDatabase.saveRecord(record) { (record, error) in
            let currentUser = CurrentUser(name: name, latitude: safeLocation.coordinate.latitude, longitude: safeLocation.coordinate.longitude, phoneNumber: phoneNumber)
            UserController.sharedController.saveToPersistentStorage()
<<<<<<< HEAD
<<<<<<< HEAD
            completion()
=======
>>>>>>> parent of 847ba23... Merge remote-tracking branch 'origin/master' into map
=======
            CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToContactList(currentUser)
>>>>>>> a4c67bcd6a08bacff67e6f88011b5943403e05ea
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






