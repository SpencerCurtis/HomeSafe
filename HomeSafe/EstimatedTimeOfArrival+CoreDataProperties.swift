//
//  EstimatedTimeOfArrival+CoreDataProperties.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/20/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension EstimatedTimeOfArrival {

    @NSManaged var canceledETA: NSNumber?
    @NSManaged var eta: Date?
    @NSManaged var homeSafe: NSNumber?
    @NSManaged var id: String?
    @NSManaged var inDanger: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var userName: String?
    @NSManaged var recordID: String?

}
