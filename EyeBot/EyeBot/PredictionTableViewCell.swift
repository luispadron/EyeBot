//
//  PredictionTableViewCell.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class PredictionTableViewCell: UITableViewCell {

    @IBOutlet weak var predictionImageView: UIImageView!
    
    @IBOutlet weak var predictionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
