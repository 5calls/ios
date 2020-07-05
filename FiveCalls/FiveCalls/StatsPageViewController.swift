//
//  WelcomePageViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

protocol FinalPage {
    var didFinishBlock: (() -> Void)? { get set }
}

class StatsPageViewController : UIViewController, FinalPage {
    
    var didFinishBlock: (() -> Void)?
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    @IBAction func getStartedTapped(_ sender: Any) {
        didFinishBlock?()
    }
    
    @IBOutlet weak var label: UILabel!
    
    var viewModel: StatsViewModel? {
        didSet {
            if let vm = viewModel {
                self.label.transform = self.label.transform.translatedBy(x: 0, y: 10)
                self.label.text = self.label.text?.replacingOccurrences(of: "...", with: vm.formattedNumberOfCalls)
                UIView.animate(withDuration: 1.25, animations: {
                    self.label.transform = .identity
                    self.label.alpha = 1
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Current.analytics.trackEvent("Screen: Stats Welcome")
        if viewModel == nil {
            label.alpha = 0
            loadStats()
        }
        
        // If iPhone 4S
        if UIScreen.main.bounds.size.height <= 480 {
            topMargin.constant = 0
            bottomMargin.constant = 0
            buttonHeight.constant = 44
        }
    }
    
    private func loadStats() {
        let operation = FetchStatsOperation()
        operation.completionBlock = { [weak self] in
            if let calls = operation.numberOfCalls {
                DispatchQueue.main.async {
                    self?.viewModel = StatsViewModel(numberOfCalls: calls)
                }
            }
        }
        OperationQueue.main.addOperation(operation)
    }
}
