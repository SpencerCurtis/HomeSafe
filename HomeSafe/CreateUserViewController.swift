//
//  CreateUserViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import CoreLocation

class CreateUserViewController: UIViewController {
    
    static let sharedController = CreateUserViewController()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var safeLocationLabel: UILabel!
    
    var selectedSafeLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.safeLocationLabel.text = LocationController.sharedController.address
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createUserButtonTapped(sender: AnyObject) {
        if let name = nameTextField.text, phoneNumber = phoneNumberTextField.text, safeLocation = LocationController.sharedController.selectedSafeLocation {
            UserController.sharedController.createUser(name, safeLocation: safeLocation, phoneNumber: phoneNumber, completion: {
                if let currentUser = UserController.sharedController.currentUser {
                    CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToContactList(currentUser, completion: {
                        CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToNewETA(currentUser, completion: {
                        })
                    })
                    
                }
            })
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
