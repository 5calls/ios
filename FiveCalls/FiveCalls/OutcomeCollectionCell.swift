//
//  OutcomeCollectionCell.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 7/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class OutcomeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var outcomeLabel: UILabel!

    static func cellHeight() -> CGFloat {
        return 40
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .fvc_lightBlueBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}
