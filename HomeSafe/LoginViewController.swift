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
    
    @IBAction func logInButtonTapped(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: { () -> Void in
            let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            indicator.color = UIColor.white
            indicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
            indicator.center = CGPoint(x: self.view.center.x, y: 280)
            indicator.hidesWhenStopped = true
            
            
            self.view.addSubview(indicator)
            self.view.bringSubview(toFront: indicator)
            
            
            indicator.startAnimating()
            
            guard let phoneNumber = self.phoneNumberTextField.text, let password = self.passwordTextField.text else { return }
            CloudKitController.sharedController.logInUser(phoneNumber, password: password, completion: { (success) in
                print(success)
                guard success == true else { indicator.stopAnimating(); let alert = NotificationController.sharedController.simpleAlert("Error", message: "No user was found with the phone number and password entered. Check the fields and try again."); DispatchQueue.main.async(execute: { () -> Void in
                    self.present(alert, animated: true, completion: nil)
                }) ; return}
                
                guard let contactTVC = self.storyboard?.instantiateViewController(withIdentifier: "selectFollowersVC") else { return }
                CloudKitController.sharedController.fetchSubscriptions(nil)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.present(contactTVC, animated: true, completion: nil)
                    indicator.stopAnimating()
                    
                })
                
                
            })
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
