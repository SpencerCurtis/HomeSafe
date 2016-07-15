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
    
    func plainPhoneNumber(string: String) -> String {
        let filter = NSCharacterSet.alphanumericCharacterSet()
        let result = String(string.utf16.filter{filter.characterIsMember($0)}.map{Character(UnicodeScalar($0))})
        
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

