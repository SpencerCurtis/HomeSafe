//
//  ContainerViewViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 6/13/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class ContainerViewViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
