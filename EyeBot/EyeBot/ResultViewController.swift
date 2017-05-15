//
//  ResultViewController.swift
//  EyeBot
//
//  Created by christopher paul perkins on 5/13/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    let widthScreen = UIScreen.main.bounds.width
    let heightScreen = UIScreen.main.bounds.height
    
    var loaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !loaded {
            super.viewWillAppear(true)
            
            // Blur behind our window
            let resultsView = UIVisualEffectView(effect:
                UIBlurEffect(style: UIBlurEffectStyle.dark))
            resultsView.frame = CGRect(x: 0,
                                       y: -heightScreen, width: widthScreen,
                                       height: heightScreen)
            resultsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            resultsView.layer.opacity = 1
            resultsView.tag = 100
            
            let image = UIImage(imageLiteralResourceName: "Ethernet Cable")
            let imageView = UIImageView(image: image)
            
            // Label to display the top prediction
            let topPrediction = UILabel(frame: CGRect(x: 0, y: 100,
                                                      width: self.widthScreen, height: 50))
            topPrediction.text = "..."
            topPrediction.textAlignment = NSTextAlignment.center
            topPrediction.textColor = UIColor.white
            
            // Dividing bar (just for aesthetics)
            let horizontalBar = UIView(frame: CGRect(x: 0, y: heightScreen - 50,
                                                     width: widthScreen, height: 1))
            horizontalBar.backgroundColor = UIColor.white
            horizontalBar.layer.opacity = 0.25
            
            // Button to close our window
            let closeButton = UIButton(frame: CGRect(x: widthScreen / 2 - 150 / 2,
                                                     y: heightScreen - 40,
                                                     width: 150, height: 30))
            closeButton.setTitle("Close Window",for: .normal)
            closeButton.setTitleColor(UIColor(red: 0.0, green:122.0/255.0,
                                              blue:1.0, alpha:1.0), for: .normal)
            closeButton.setTitleColor(UIColor.white, for: .highlighted)
            closeButton.addTarget(self, action: #selector(resultsViewButtonClose),
                                  for: .touchUpInside)
            
            resultsView.addSubview(imageView)
            resultsView.addSubview(topPrediction)
            resultsView.addSubview(horizontalBar)
            resultsView.addSubview(closeButton)
            
            // Frame blur behind frame
            self.view.addSubview(resultsView)
            
            // Slide down results view
            UIView.animate(withDuration: 0.5, delay: 0.6, options: [],
                           animations: {
                            resultsView.frame = CGRect(x: 0, y: 0, width: self.widthScreen,
                                                       height: self.heightScreen)
            }, completion: nil)
            
            self.loaded = true
        }
    }
    
    // When the close button is tapped
    func resultsViewButtonClose(sender: UIButton!) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                       animations: {
                        if let resultVC = self.view.viewWithTag(100) {
                            resultVC.frame = CGRect(x: 0, y: -self.heightScreen,
                                                    width: self.widthScreen,
                                                    height: self.heightScreen)
                        }
        }, completion: {(value:Bool) in self.dismiss(animated: false)})
    }
    
}
