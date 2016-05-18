//
//  EstimatedTimeOfArrival.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/18/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData


class EstimatedTimeOfArrival: NSManagedObject {

    convenience init(eta: NSDate, latitude: Double, longitude: Double, userName: String, homeSafe: Bool = false, inDanger: Bool = false, canceledETA: Bool = false, id: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        let entity = NSEntityDescription.entityForName("ETA", inManagedObjectContext: context)
        
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.eta = eta
        self.latitude = latitude
        self.longitude = longitude
        self.userName = userName
        self.homeSafe = homeSafe
        self.id = id
        self.canceledETA = canceledETA
        self.inDanger = inDanger
    }

}
