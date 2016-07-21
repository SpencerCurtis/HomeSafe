//
//  SubscriptionController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 7/19/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

class SubscriptionController {
    
    
    static var subscriptions: [Subscription] {
        let request = NSFetchRequest(entityName: "Subscription")
        
        do {
            let subscriptions = try Stack.sharedStack.managedObjectContext.executeFetchRequest(request) as! [Subscription]
            return subscriptions
        } catch {
            return []
        }
    }
    
    
    static func createSubscription(id: String) {
        _ = Subscription(id: id)
        UserController.sharedController.saveToPersistentStorage()
    }
    
    static func deleteSubscriptions() {
        let moc = Stack.sharedStack.managedObjectContext
        for subscription in SubscriptionController.subscriptions {
            moc.deleteObject(subscription)
            UserController.sharedController.saveToPersistentStorage()
        }
    }
}