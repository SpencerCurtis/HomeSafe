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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let contacts = try Stack.sharedStack.managedObjectContext.fetch(request) as! [User]
            return contacts
        } catch {
            return []
        }
    }
    
    func createUserFromFetchedRecord(_ record: CKRecord) {
        _ = User(record: record)
        self.saveToPersistentStorage()
    }
    
    func saveContact(_ contact: User) {
        saveToPersistentStorage()
    }
    func removeContact(_ contact: User) {
        contact.managedObjectContext?.delete(contact)
        saveToPersistentStorage()
    }
    
    func plainPhoneNumber(_ string: String) -> String {
        let filter = CharacterSet.alphanumerics
        let result = String(string.utf16.filter{filter.contains(UnicodeScalar($0)!)}.map{Character(UnicodeScalar($0)!)})
        
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

