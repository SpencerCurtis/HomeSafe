//
//  Stack.swift
//  CapstoneReminder
//
//  Created by Spencer Curtis on 3/23/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

class Stack {
    
    static let sharedStack = Stack()
    
    lazy var managedObjectContext: NSManagedObjectContext = Stack.setUpMainContext()
    
    static func setUpMainContext() -> NSManagedObjectContext {
        let bundle = NSBundle.mainBundle()
        guard let model = NSManagedObjectModel.mergedModelFromBundles([bundle])
            else { fatalError("model not found") }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil,
                                                                   URL: storeURL(), options: nil)
        let context = NSManagedObjectContext(
            concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    static func storeURL () -> NSURL? {
        let documentsDirectory: NSURL? = try? NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
        
        return documentsDirectory?.URLByAppendingPathComponent("db.sqlite")
    }
    
}