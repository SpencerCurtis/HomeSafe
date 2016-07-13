//
//  LoginViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 7/6/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppearanceController.sharedController.gradientBackgroundForViewController(self)
        setUpViews()
    }
    
    func setUpViews() {
        AppearanceController.sharedController.setUpTextFields([passwordTextField, phoneNumberTextField])
        AppearanceController.sharedController.setUpButtons([logInButton])
    }
    
    @IBAction func logInButtonTapped(sender: AnyObject) {
        guard let phoneNumber = phoneNumberTextField.text, password = passwordTextField.text else { return }
        CloudKitController.sharedController.logInUser(phoneNumber, password: password, completion: { (success) in
            print(success.boolValue)
            guard success == true else { let alert = NotificationController.sharedController.simpleAlert("Error", message: "No user was found with the phone number and password entered. Check the fields and try again."); dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            }) ; return}
            
            guard let contactTVC = self.storyboard?.instantiateViewControllerWithIdentifier("selectFollowersVC") else { return }
            CloudKitController.sharedController.fetchSubscriptions()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(contactTVC, animated: true, completion: nil)
            
            })
            
            
        })
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
