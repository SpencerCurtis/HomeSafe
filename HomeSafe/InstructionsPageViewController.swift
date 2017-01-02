//
//  InstructionsPageViewController.swift
//  HomeSafe
//
//  Created by admin on 5/26/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class InstructionsPageViewController: UIPageViewController {
    
    let firstInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstViewController")
    let secondInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "secondViewController")
    let thirdInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "thirdViewController")
    let fourthInstructionalPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "fourthViewController")
    
    var firstRun: Bool {
        return UserDefaults.standard.bool(forKey: "firstRun")
    }
    
    var orderOfAppearance: [UIViewController] {
        return [firstInstructionalPage, secondInstructionalPage, thirdInstructionalPage, fourthInstructionalPage]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        if let firstViewController = orderOfAppearance.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func newInstructionalViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)ViewController")
    }
    
}

extension InstructionsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderOfAppearance.index(of: viewController) else {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderOfAppearance.index(of: viewController) else {
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
