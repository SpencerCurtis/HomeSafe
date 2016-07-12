//
//  ManualPhoneNumberEntryViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 7/11/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class ManualPhoneNumberEntryViewController: UIViewController {
    
    @IBOutlet weak var addPhoneNumberButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppearanceController.sharedController.gradientBackgroundForViewController(self)
        AppearanceController.sharedController.setUpButtons([addPhoneNumberButton])
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func manualPhoneNumberButtonTapped(sender: AnyObject) {
        guard let phoneNumber = phoneNumberTextField.text, currentUser = UserController.sharedController.currentUser else { return; /* alert? */ }
        CloudKitController.sharedController.addUsersToContactList(currentUser, phoneNumbers: [phoneNumber], completion: { (success) in
            guard success == true else { return;  /* alert? */ }
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
