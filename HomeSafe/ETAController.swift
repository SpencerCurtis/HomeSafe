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
import CoreData

class ETAController {
    
    static let sharedController = ETAController()
    
    
    var arrayOfETAs: [EstimatedTimeOfArrival] {
        let request = NSFetchRequest(entityName: "ETA")
        
        do {
            let ETAs = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [EstimatedTimeOfArrival]
            return ETAs
        } catch {
            return []
        }
    }
    
    
    
    let publicDatabate = CKContainer.defaultContainer().publicCloudDatabase
    let record = CKRecord(recordType: "ETA")
    
    
    func createETA(ETATime: NSDate, destination: CLLocation, name: String) {
        record.setValue(ETATime, forKey: "ETA")
        record.setValue(destination, forKey: "destinationLocation")
        record.setValue(name, forKey: "name")
        record.setValue(false, forKey: "homeSafe")
        publicDatabate.saveRecord(record) { (record, error) in
            
        }
    }
    
    func removeETA(ETA: EstimatedTimeOfArrival) {
        ETA.managedObjectContext?.deleteObject(ETA)
        saveToPersistentStorage()
    }
    
    func saveETA(ETA: EstimatedTimeOfArrival) {
        saveToPersistentStorage()
    }
    
    
    func saveToPersistentStorage() {
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
    
    
    
}