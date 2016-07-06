//
//  CurrentUser.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/18/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


class CurrentUser: NSManagedObject {

    convenience init(name: String, latitude: Double, longitude: Double, phoneNumber: String, uuid: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        let entity = NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
    }
    
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let name = record.valueForKey("name") as? String, phoneNumber = record.valueForKey("phoneNum") as? String, safeLocation = record.valueForKey("safeLocation") as? CLLocation else { return nil }
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.latitude = safeLocation.coordinate.latitude
        self.longitude = safeLocation.coordinate.latitude
        self.uuid = record.recordID.recordName
    }


}
