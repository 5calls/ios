//
//  IssueDetailCell.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssueDetailCell : UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var issueTextView: UITextView!

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
