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
    
    let name: String
    let safeLocation: CLLocation
    let phoneNumber: Int
    
    init(name: String, safeLocation: CLLocation, phoneNumber: Int) {
        
        self.name = name
        self.safeLocation = safeLocation
        self.phoneNumber = phoneNumber
    }
    
    
    // CloudKit Initializer?
    
    
}