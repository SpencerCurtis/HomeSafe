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


extension CurrentUser {

    convenience init(name: String, latitude: Double, longitude: Double, phoneNumber: String, uuid: String, context: NSManagedObjectContext = Stack.context) {
        
        self.init(entity: CurrentUser.entity(), insertInto: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.latitude = latitude as NSNumber?
        self.longitude = longitude as NSNumber?
        self.uuid = uuid
    }
    
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = Stack.context) {
        guard let name = record.value(forKey: "name") as? String, let phoneNumber = record.value(forKey: "phoneNum") as? String, let safeLocation = record.value(forKey: "safeLocation") as? CLLocation else { return nil }
        
        self.init(entity: CurrentUser.entity(), insertInto: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.latitude = safeLocation.coordinate.latitude as NSNumber?
        self.longitude = safeLocation.coordinate.latitude as NSNumber?
        self.uuid = record.recordID.recordName
    }


}
