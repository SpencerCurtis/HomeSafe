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
    
    @IBOutlet weak var selectSafePlaceButton: UIButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var safeLocationLabel: UILabel!
    
    var selectedSafeLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccountLabel.center.x = self.view.frame.width - 570
        nameTextField.center.x = self.view.frame.width - 570
        phoneNumberTextField.center.x = self.view.frame.width - 570
        selectSafePlaceButton.center.x = self.view.frame.width - 570


        bounceAnimation()
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
            CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToContactList(currentUser)
            }
        })
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func bounceAnimation() {
        UIView.animateWithDuration(2.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 8, options: [], animations: ({
            self.createAccountLabel.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(2.5, delay: 0.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 8, options: [], animations: ({
            self.nameTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(2.5, delay: 1.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 8, options: [], animations: ({
            self.phoneNumberTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(2.5, delay: 1.4, usingSpringWithDamping: 1.0, initialSpringVelocity: 8, options: [], animations: ({
            self.selectSafePlaceButton.center.x = self.view.frame.width / 2
        }), completion: nil)
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
