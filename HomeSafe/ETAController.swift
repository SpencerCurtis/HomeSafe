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
    
    let db = CKContainer.default().publicCloudDatabase
    
    var currentETA: EstimatedTimeOfArrival? {
        return arrayOfETAs.last
    }
    
    var arrayOfETAs: [EstimatedTimeOfArrival] {
        let request: NSFetchRequest<EstimatedTimeOfArrival> = EstimatedTimeOfArrival.fetchRequest()
        
        do {
            let ETAs = try Stack.context.fetch(request)
            return ETAs
        } catch {
            return []
        }
    }
    
    let publicDatabate = CKContainer.default().publicCloudDatabase
    
    
    func createETA(_ ETATime: Date, latitude: Double, longitude: Double, name: String, canceledETA: Bool, inDanger: Bool) {
        let recordID = UUID().uuidString
        if let currentUser = UserController.sharedController.currentUser, let phoneNumber = currentUser.phoneNumber, let _ = currentUser.uuid {
            let eta = EstimatedTimeOfArrival(eta: ETATime, latitude: latitude, longitude: longitude, userName: name, id: recordID, recordID: recordID)
            self.saveToPersistentStorage()
            let record = CKRecord(recordType: "ETA", recordID: CKRecordID(recordName: recordID))
            record.setValue(ETATime, forKey: "ETA")
            record.setValue(latitude, forKey: "latitude")
            record.setValue(longitude, forKey: "longitude")
            record.setValue(name, forKey: "name")
            record.setValue(0, forKey: "homeSafe")
            record.setValue(0, forKey: "inDanger")
            record.setValue(0, forKey: "canceledETA")
            record.setValue(recordID, forKey: "id")
            record.setValue(phoneNumber, forKey: "userPhoneNumber")
            
            let contacts = ContactsController.sharedController.selectedGuardians
            var followerPhoneNumbers: [String] = []
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "contactQueue", attributes: [])
            for contact in contacts {
                group.enter()
                followerPhoneNumbers.append(contact.phoneNumber ?? "")
                group.leave()
            }
            
            group.notify(queue: queue, execute: {
                record.setValue(followerPhoneNumbers, forKey: "followers")
            })
            
            
            
            
            publicDatabate.save(record, completionHandler: { (record, error) in
                if record != nil {
                    CloudKitController.sharedController.setCurrentETA(currentUser, etaID: eta.recordID!)
                    CloudKitController.sharedController.notifySelectedUsersOfNewETA(ContactsController.sharedController.selectedGuardians, currentUser: currentUser)
                } else {
                    if let error = error { print(error.localizedDescription) }
                }
            }) 
        }
    }
    
    func removeETAs() {
        for ETA in arrayOfETAs {
            ETA.managedObjectContext?.delete(ETA)
            saveToPersistentStorage()
            if let id = ETA.id {
                publicDatabate.delete(withRecordID: CKRecordID(recordName: id), completionHandler: { (id, error) in
                })
            }
        }
    }
    
    func inDanger(_ eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "inDanger")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.add(operation)
            self.removeETAs()
            
            //            self.resetChangedFields(eta)
        }
        db.add(operation)
        eta.inDanger = true
        saveToPersistentStorage()
        
    }
    
    
    func cancelETA(_ eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "canceledETA")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.add(operation)
            //            self.resetChangedFields(eta)
            
        }
        db.add(operation)
        eta.canceledETA = true
        removeETAs()
        saveToPersistentStorage()
    }
    
    func homeSafely(_ eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(true, forKey: "homeSafe")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.add(operation)
            print("homeSafely")
            self.resetChangedFields(eta)
        }
        db.add(operation)
        eta.homeSafe = true
        removeETAs()
        
        saveToPersistentStorage()
    }
    
    
    
    func resetChangedFields(_ eta: EstimatedTimeOfArrival) {
        let predicate = NSPredicate(format: "id = %@", eta.id!)
        let query = CKQuery(recordType: "ETA", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record) in
            record.setValue(0, forKey: "inDanger")
            record.setValue(0, forKey: "canceledETA")
            record.setValue(0, forKey: "homeSafe")
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            self.db.add(operation)
        }
        db.add(operation)
    }
    
    
    func saveToPersistentStorage() {
        
        do {
            try Stack.context.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
    
    
    
 }
