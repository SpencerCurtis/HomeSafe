//
//  EstimatedTimeOfArrival.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/18/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData


extension EstimatedTimeOfArrival {

    convenience init(eta: Date, latitude: Double, longitude: Double, userName: String, homeSafe: Bool = false, inDanger: Bool = false, canceledETA: Bool = false, id: String, recordID: String, context: NSManagedObjectContext = Stack.context) {
        let entity = NSEntityDescription.entity(forEntityName: "EstimatedTimeOfArrival", in: context)
        
        self.init(entity: entity!, insertInto: context)
        
        self.eta = eta as NSDate?
        self.latitude = latitude as NSNumber?
        self.longitude = longitude as NSNumber?
        self.userName = userName
        self.homeSafe = homeSafe as NSNumber?
        self.id = id
        self.canceledETA = canceledETA as NSNumber?
        self.inDanger = inDanger as NSNumber?
        self.recordID = recordID
    }
}
