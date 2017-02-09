//
//  WelcomePageViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Crashlytics

protocol FinalPage {
    var didFinishBlock: ((Void) -> Void)? { get set }
}

class StatsPageViewController : UIViewController, FinalPage {
    
    var didFinishBlock: ((Void) -> Void)?
    
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
        
        Answers.logCustomEvent(withName:"Screen: Stats Welcome")
        if viewModel == nil {
            label.alpha = 0
            loadStats()
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
