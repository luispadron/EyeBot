//
//  ResultViewController.swift
//  EyeBot
//
//  Created by christopher paul perkins on 5/13/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        let widthFrame:CGFloat = widthScreen
        let heightFrame:CGFloat = heightScreen
        
        // Blur behind our window
        let resultsView = UIVisualEffectView(effect:
            UIBlurEffect(style: UIBlurEffectStyle.dark))
        resultsView.frame = CGRect(x: widthScreen / 2 - widthFrame / 2,
                                   y: -heightFrame, width: widthFrame,
                                   height: heightFrame)
        resultsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        resultsView.layer.opacity = 1
        resultsView.tag = 100
        
        let image = UIImage(imageLiteralResourceName: "Ethernet Cable")
        let imageView = UIImageView(image: image)
        
        // Label to display the top prediction
        let topPrediction = UILabel(frame: CGRect(x: widthFrame / 2 - widthFrame / 2, y: 100,
                                                  width: widthFrame, height: 50))
        topPrediction.text = "..."
        topPrediction.textAlignment = NSTextAlignment.center
        topPrediction.textColor = UIColor.white
        
        // Dividing bar (just for aesthetics)
        let horizontalBar = UIView(frame: CGRect(x: 0, y: heightFrame - 50,
                                                 width: widthFrame, height: 1))
        horizontalBar.backgroundColor = UIColor.white
        horizontalBar.layer.opacity = 0.25
        
        // Button to close our window
        let closeButton = UIButton(frame: CGRect(x: widthFrame / 2 - 150 / 2, y: heightFrame - 40,
                                                 width: 150, height: 30))
        closeButton.setTitle("Close Window",for: .normal)
        closeButton.setTitleColor(UIColor(red: 0.0, green:122.0/255.0, blue:1.0, alpha:1.0), for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .highlighted)
        closeButton.addTarget(self, action: #selector(resultsViewButtonClose), for: .touchUpInside)
        
        resultsView.addSubview(imageView)
        resultsView.addSubview(topPrediction)
        resultsView.addSubview(horizontalBar)
        resultsView.addSubview(closeButton)
        
        // Frame blur behind frame
        self.view.addSubview(resultsView)
        
        // Slide down results view, hide capture button
        UIView.animate(withDuration: 0.5, delay: 0.6, options: [],
                       animations: {
                        resultsView.frame = CGRect(x: widthScreen / 2 - widthFrame / 2,
                                                   y: heightScreen - heightFrame,
                                                   width: widthFrame, height: heightFrame)
        }, completion: nil)
    }
    
    // When the close button is tapped
    func resultsViewButtonClose(sender: UIButton!) {
        
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        let widthFrame:CGFloat = widthScreen
        let heightFrame:CGFloat = heightScreen
        
        if let viewWithTag = self.view.viewWithTag(100) {
            // Hide the results view
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                           animations: {
                                viewWithTag.frame = CGRect(x: widthScreen / 2 - widthFrame / 2,
                                                           y: -heightFrame,
                                                           width: widthFrame, height: heightFrame)
                            },
                           completion: {(value:Bool) in viewWithTag.removeFromSuperview()})
        }
    }
    
}
