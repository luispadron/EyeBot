//
//  PredictionDetailViewController.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class PredictionDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageToPresent: UIImage?
    var imageLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = imageLabel
        imageView.image = imageToPresent
    }

}
