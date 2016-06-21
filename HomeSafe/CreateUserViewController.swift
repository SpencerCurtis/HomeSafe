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
        setupViews()
        hideTransparentNavigationBar()
        bounceAnimation()
    
    }
    
    func setupViews() {
        createAccountLabel.center.x = self.view.frame.width - 620
        nameTextField.center.x = self.view.frame.width - 620
        phoneNumberTextField.center.x = self.view.frame.width - 620
        selectSafePlaceButton.center.x = self.view.frame.width - 620
        
        selectSafePlaceButton.layer.cornerRadius = 5
        selectSafePlaceButton.layer.borderColor = UIColor.whiteColor().CGColor
        selectSafePlaceButton.layer.borderWidth = 0.2
        
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor.whiteColor().CGColor
        nameTextField.layer.borderWidth = 0.3
        
        phoneNumberTextField.layer.cornerRadius = 5
        phoneNumberTextField.layer.borderColor = UIColor.whiteColor().CGColor
        phoneNumberTextField.layer.borderWidth = 0.3
        
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        self.view.addSubview(backgroundView)

        self.view.sendSubviewToBack(backgroundView)
        
    }
    
    func hideTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.safeLocationLabel.text = LocationController.sharedController.address
            self.hideTransparentNavigationBar()
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
                    //                    CloudKitController.sharedController.fetchSubscriptions({
                    CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToContactList(currentUser, completion: {
                        CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToNewETA(currentUser, completion: {
                            
                        })
                    })
                    //                    })
                }
            })
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func bounceAnimation() {
        UIView.animateWithDuration(1.8, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.createAccountLabel.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(1.8, delay: 0.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.nameTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(1.8, delay: 1.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.phoneNumberTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        UIView.animateWithDuration(1.8, delay: 1.4, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
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
