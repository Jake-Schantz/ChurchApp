//
//  HeaderCollectionReusableView.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/7/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
}
