//
//  MainFeatureCell.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-03-31.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import UIKit

class MainFeatureCell: UITableViewCell {

    @IBOutlet weak var featureImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
