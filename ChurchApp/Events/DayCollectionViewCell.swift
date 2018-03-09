//
//  DayCollectionViewCell.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/6/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var eventIndicator: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventIndicator.layer.cornerRadius = 5
        eventIndicator.layer.masksToBounds = true
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setNeedsDisplay()
        self.setNeedsLayout()
        self.numberLabel.textColor = nil
        self.numberLabel.text = nil
        self.eventIndicator.backgroundColor = nil
    }
}
