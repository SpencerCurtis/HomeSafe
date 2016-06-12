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
    
    let db = CKContainer.defaultContainer().publicCloudDatabase
    
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
        let recordID = NSUUID().UUIDString
        if let currentUser = UserController.sharedController.currentUser, phoneNumber = currentUser.phoneNumber, uuid = currentUser.uuid {
            let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: recordID))
            record.setValue(ETATime, forKey: "ETA")
            record.setValue(latitude, forKey: "latitude")
            record.setValue(longitude, forKey: "longitude")
            record.setValue(name, forKey: "name")
            record.setValue(false, forKey: "homeSafe")
            record.setValue(false, forKey: "inDanger")
            record.setValue(false, forKey: "canceledETA")
            record.setValue(recordID, forKey: "id")
            record.setValue(phoneNumber, forKey: "userPhoneNumber")
            let contacts = ContactsController.sharedController.selectedGuardians
            var followerPhoneNumbers: [String] = []
            let group = dispatch_group_create()
            let queue = dispatch_queue_create("contactQueue", nil)
            for contact in contacts {
                dispatch_group_enter(group)
                followerPhoneNumbers.append(contact.phoneNumber!)
                dispatch_group_leave(group)
            }
            
            dispatch_group_notify(group, queue, { 
                record.setValue(followerPhoneNumbers, forKey: "followers")
            })
            
            
            
            
            publicDatabate.saveRecord(record) { (record, error) in
                if let record = record {
                    let eta = EstimatedTimeOfArrival(eta: ETATime, latitude: latitude, longitude: longitude, userName: name, id: recordID, recordID: recordID)
                    self.currentETA = eta
                    print(self.currentETA)
                    CloudKitController.sharedController.setCurrentETA(currentUser, etaID: eta.recordID!)
                    self.saveToPersistentStorage()
                    CloudKitController.sharedController.notifySelectedUsersOfNewETA(ContactsController.sharedController.selectedGuardians, currentUser: currentUser)
                } else {
                    print(error?.localizedDescription)
                }
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
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "inDanger")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.addOperation(operation)
            //            self.resetChangedFields(eta)
        }
        db.addOperation(operation)
        eta.inDanger = true
        saveToPersistentStorage()
        
    }
    
    
    func cancelETA(eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "canceledETA")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.addOperation(operation)
            //            self.resetChangedFields(eta)
            
        }
        db.addOperation(operation)
        eta.canceledETA = true
        saveToPersistentStorage()
    }
    
    func homeSafely(eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "homeSafe")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.addOperation(operation)
            print("homeSafely")
            self.resetChangedFields(eta)
        }
        db.addOperation(operation)
        eta.homeSafe = true
        saveToPersistentStorage()
    }
    
    
    
    func resetChangedFields(eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(false, forKey: "inDanger")
            record.setValue(false, forKey: "canceledETA")
            record.setValue(false, forKey: "homeSafe")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.addOperation(operation)
        }
        db.addOperation(operation)
    }
    
    
    func saveToPersistentStorage() {
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
    
    
    
 }