//
//  CurrentUser+CoreDataProperties.swift
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

extension CurrentUser {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var uuid: String?

}
