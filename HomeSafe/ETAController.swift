//
//  ETAController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CloudKit

class ETAController {
    
    static let sharedController = ETAController()
    
    var ArrayOfETAs: [EstimatedTimeOfArrival]?
    
    let publicDatabate = CKContainer.defaultContainer().publicCloudDatabase
    let record = CKRecord(recordType: "ETA")

    
    func createETA(ETATime: NSDate, destination: CLLocation, name: String) {
        record.setValue(ETATime, forKey: "ETA")
        record.setValue(destination, forKey: "destinationLocation")
        record.setValue(name, forKey: "name")
        publicDatabate.saveRecord(record) { (record, error) in
            
        }
    }
    
    func removeETA(ETA: EstimatedTimeOfArrival) {
        
    }
    
}