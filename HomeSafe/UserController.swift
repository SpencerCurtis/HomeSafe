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

class UserController {
    
    static let sharedController = UserController()
    
    func createUser(name: String, safeLocation: CLLocation, phoneNumber: String) {
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        let record = CKRecord(recordType: "User")
        record.setValue(name, forKey: "name")
        record.setValue(safeLocation, forKey: "safeLocation")
        record.setValue(phoneNumber, forKey: "phoneNum")
        publicDatabase.saveRecord(record) { (record, error) in
            
        }
    }
    
    
    
    
    
}
