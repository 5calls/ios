//
//  ViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Crashlytics

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var pageContainer: UIView!
    
    var completionBlock = {}
    
    lazy var pageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageController
    }()
    
    let numberOfPages = 2
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logCustomEvent(withName:"Screen: Welcome")
        loadPages()
    }

    private func loadPages() {
        pageContainer.backgroundColor = .white
        addChildViewController(pageController)
        pageContainer.addSubview(pageController.view)
        
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            pageController.view.leftAnchor.constraint(equalTo: pageContainer.leftAnchor),
            pageController.view.rightAnchor.constraint(equalTo: pageContainer.rightAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor),
            ])
        pageController.didMove(toParentViewController: self)
        pageController.dataSource = self
        pageController.setViewControllers([viewController(atIndex: 0)], direction: .forward, animated: false, completion: nil)
    }
}

extension WelcomeViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag + 1
        guard index < numberOfPages else { return nil }
        return self.viewController(atIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag - 1
        guard index >= 0 else { return nil }
        return self.viewController(atIndex: index)
    }
    
    func viewController(atIndex index: Int) -> UIViewController {
        guard let storyboard = self.storyboard else { fatalError() }
        let page = storyboard.instantiateViewController(withIdentifier: "Page\(index + 1)")
        page.view.tag = index
        
        if var finalPage = page as? FinalPage {
            finalPage.didFinishBlock = completionBlock
        }
        
        return page
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return numberOfPages
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

