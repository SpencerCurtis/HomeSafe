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
    
    var currentETA: EstimatedTimeOfArrival?
    
    var arrayOfETAs: [EstimatedTimeOfArrival] {
        let request = NSFetchRequest(entityName: "EstimatedTimeOfArrival")
        
        do {
            let ETAs = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [EstimatedTimeOfArrival]
            return ETAs
        } catch {
            return []
        }
    }
    
    let publicDatabate = CKContainer.defaultContainer().publicCloudDatabase
    
    
    func createETA(ETATime: NSDate, latitude: Double, longitude: Double, name: String, canceledETA: Bool, inDanger: Bool) {
        let uuid = NSUUID().UUIDString
        let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: uuid))
        record.setValue(ETATime, forKey: "ETA")
        record.setValue(latitude, forKey: "latitude")
        record.setValue(longitude, forKey: "longitude")
        record.setValue(name, forKey: "name")
        record.setValue(false, forKey: "homeSafe")
        record.setValue(false, forKey: "inDanger")
        record.setValue(canceledETA, forKey: "canceledETA")
        record.setValue(uuid, forKey: "id")
        
        
        
        
        publicDatabate.saveRecord(record) { (record, error) in
            if let record = record {
                let eta = EstimatedTimeOfArrival(eta: ETATime, latitude: latitude, longitude: longitude, userName: name, id: uuid, recordID: String(record.recordID))
                self.currentETA = eta
                self.saveToPersistentStorage()
                CloudKitController.sharedController.setupSubscriptionForUser(eta)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func removeETA(ETA: EstimatedTimeOfArrival) {
        ETA.managedObjectContext?.deleteObject(ETA)
        if let id = ETA.id {
            saveToPersistentStorage()
            publicDatabate.deleteRecordWithID(CKRecordID(recordName: id), completionHandler: { (id, error) in
            })
        }
    }
    
    func inDanger(eta: EstimatedTimeOfArrival) {
        let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: eta.id!))
        record.setValue(true, forKey: "inDanger")
        eta.inDanger = true
        saveToPersistentStorage()
    }
    
    func cancelETA(eta: EstimatedTimeOfArrival) {
        let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: eta.id!))
        record.setValue(true, forKey: "canceledETA")
        eta.canceledETA = true
        saveToPersistentStorage()
    }
    
    func homeSafely(eta: EstimatedTimeOfArrival) {
        let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: eta.id!))
        record.setValue(true, forKey: "homeSafe")
        eta.homeSafe = true
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