//
//  ContactsController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData



class ContactsController {
    
    static let sharedController = ContactsController()
    
    var contacts: [User] {
        let request = NSFetchRequest(entityName: "User")
        
        do {
            let contacts = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [User]
            return contacts
        } catch {
            return []
        }
    }
    
    func saveContact(contact: User) {
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