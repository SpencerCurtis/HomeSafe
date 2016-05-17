//
//  User.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreLocation

class User {
    
    var name: String
    var safeLocation: CLLocation
    var phoneNumber: String
    
    init(name: String, safeLocation: CLLocation, phoneNumber: String) {
        
        self.name = name
        self.safeLocation = safeLocation
        self.phoneNumber = phoneNumber
    }
    
    
    // CloudKit Initializer?
    
    
}