//
//  WelcomePageViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class StatsPageViewController : UIViewController {
    @IBOutlet weak var label: UILabel!
    
    var viewModel: StatsViewModel? {
        didSet {
            if let vm = viewModel {
                self.label.text = self.label.text?.replacingOccurrences(of: "...", with: vm.formattedNumberOfCalls)
                UIView.animate(withDuration: 1.75, animations: {
                    self.label.alpha = 1
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
