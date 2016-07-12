//
//  ContactsController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import CloudKit



class ContactsController {
    
    static let sharedController = ContactsController()
    
    var selectedGuardians: [User] = []
    
    var contacts: [User] {
        let request = NSFetchRequest(entityName: "User")
        
        do {
            let contacts = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [User]
            return contacts
        } catch {
            return []
        }
    }
    
    var filteredContacts: [User] {
        
        let set = Set<User>(contacts)
        return Array(set)
    }
    
    
    func createUserFromFetchedRecord(record: CKRecord) {
        _ = User(record: record)
        self.saveToPersistentStorage()
    }
    
    func saveContact(contact: User) {
        saveToPersistentStorage()
    }
    func removeContact(contact: User) {
        contact.managedObjectContext?.deleteObject(contact)
        saveToPersistentStorage()
    }
    
    
    func convertContactsToUsers(contacts: [CNContact], completion: () -> Void) {
        var userArray: [User] = []
        
        for contact in contacts {
            if contact.phoneNumbers != [] {
                let name = contact.givenName + " " + contact.familyName
                let value = contact.phoneNumbers.first?.value as! CNPhoneNumber
                let string = value.stringValue
                let phoneNumber = plainPhoneNumber(string)
                var latitude: Double = 0.0
                var longitude: Double = 0.0
                var location: CLLocation?
                let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "User", predicate: predicate)
                publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                    if let records = records {
                        for record in records {
                            let phoneNum = record.valueForKey("phoneNum") as? String
                            if phoneNum == phoneNumber {
                                location = record.valueForKey("safeLocation") as? CLLocation
                                if let location = location {
                                    latitude = location.coordinate.latitude
                                    longitude = location.coordinate.longitude
                                    let newUserContact = User(name: name, latitude: latitude, longitude: longitude, phoneNumber: phoneNumber)
                                    userArray.append(newUserContact)
                                    self.saveToPersistentStorage()
                                    completion()
                                }
                            }
                        }
                    }
                })
            } else {
                //                NotificationController.sharedController.simpleAlert(", message: <#T##String#>)
            }
        }
    }
    
    
    func plainPhoneNumber(string: String) -> String {
        let filter = NSCharacterSet.alphanumericCharacterSet()
        let result = String(string.utf16.filter { filter.characterIsMember($0) }.map { Character(UnicodeScalar($0)) })
        
        return result
    }
    
    
    func saveToPersistentStorage() {
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
}

