//
//  FirstInstructionalViewController.swift
//  HomeSafe
//
//  Created by admin on 5/26/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class FirstInstructionalViewController: UIViewController {
    
    @IBOutlet weak var homeSafeImageView: UIImageView!
    @IBOutlet weak var homeSafeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppearanceController.sharedController.gradientBackgroundForViewController(self)
        animateViews()
        
        UIView.animate(withDuration: 3, animations: {
            self.homeSafeImageView.alpha = 1.0
            self.homeSafeLabel.alpha = 1.0
        }) 
        // Do any additional setup after loading the view.
    }
    
    
    func animateViews() {
        UIView.animate(withDuration: 2, delay: 0.5, options: [.curveEaseOut], animations: {
            self.homeSafeImageView.center.y = self.homeSafeImageView.center.y - 125
            }, completion: nil)
       
        
    }
    
}
