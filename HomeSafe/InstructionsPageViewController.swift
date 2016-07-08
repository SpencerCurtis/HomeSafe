//
//  InstructionsPageViewController.swift
//  HomeSafe
//
//  Created by admin on 5/26/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class InstructionsPageViewController: UIPageViewController {
    
    let firstInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("firstViewController")
    let secondInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("secondViewController")
    let thirdInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("thirdViewController")
    let fourthInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("fourthViewController")
    
    var firstRun: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("firstRun")
    }
    
    var orderOfAppearance: [UIViewController] {
        return [firstInstructionalPage, secondInstructionalPage, thirdInstructionalPage, fourthInstructionalPage]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        if let firstViewController = orderOfAppearance.first {
            setViewControllers([firstViewController], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    func newInstructionalViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("\(name)ViewController")
    }
    
}

extension InstructionsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderOfAppearance.indexOf(viewController) else {
            return nil
        }
        
        let priorIndex = viewControllerIndex - 1
        guard priorIndex >= 0 else {
            return nil
        }
        
        guard orderOfAppearance.count > priorIndex else {
            return nil
        }
        
        return orderOfAppearance[priorIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderOfAppearance.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderOfAppearanceCount = orderOfAppearance.count
        guard orderOfAppearanceCount != nextIndex else {
            return nil
        }
        
        guard orderOfAppearanceCount > nextIndex else {
            return nil
        }
        
        return orderOfAppearance[nextIndex]
    }
}
