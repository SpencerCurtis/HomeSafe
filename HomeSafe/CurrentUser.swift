//
//  CurrentUser.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/18/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData


class CurrentUser: NSManagedObject {

    convenience init(name: String, latitude: Double, longitude: Double, phoneNumber: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        let entity = NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
    }

}
