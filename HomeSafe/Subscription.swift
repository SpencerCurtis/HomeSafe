//
//  Subscription.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 7/19/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData


class Subscription: NSManagedObject {
    
    
    convenience init?(id: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Subscription", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
    }
}
