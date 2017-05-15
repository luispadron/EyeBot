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
    var prediction:Prediction? = nil
    
    
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
            resultsView.frame = CGRect(x: 0, y: 0, width: widthScreen, height: heightScreen)
            
            self.view.frame = CGRect(x: 0,
                                       y: -heightScreen, width: widthScreen,
                                       height: heightScreen)
            self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.layer.opacity = 1
            
            let loc = (heightScreen - 190 - widthScreen) / 2
            
            // Image for view
            let logo = UIImage(imageLiteralResourceName: "captureButton")
            let logoView = UIImageView(image: logo)
            logoView.frame = CGRect(x: widthScreen / 2 - 75 / 2, y: 25,
                                     width: 75, height: 75)
            
            // Label to display the top prediction
            let topPrediction = UILabel(frame: CGRect(x: 0, y: 75 + loc,
                                                      width: self.widthScreen, height: 50))
            topPrediction.text = "..."
            topPrediction.textAlignment = NSTextAlignment.center
            topPrediction.textColor = UIColor.white
            
            // Image for result
            let resultImage = UIImage(imageLiteralResourceName: "Ethernet Cable")
            let resultImageView = UIImageView(image: resultImage)
            resultImageView.frame = CGRect(x: 10, y: 100 + loc,
                                     width: widthScreen - 20, height: widthScreen - 20)
            
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
            
            // Frame blur behind frame contents
            self.view.addSubview(resultsView)
            
            self.view.addSubview(logoView)
            self.view.addSubview(topPrediction)
            self.view.addSubview(resultImageView)
            self.view.addSubview(horizontalBar)
            self.view.addSubview(closeButton)
            
            // Slide down results view
            UIView.animate(withDuration: 0.5, delay: 0.6, options: [],
                           animations: {
                            self.view.frame = CGRect(x: 0, y: 0, width: self.widthScreen,
                                                    height: self.heightScreen)
            }, completion: nil)
            
            self.loaded = true
        }
    }
    
    // When the close button is tapped
    func resultsViewButtonClose(sender: UIButton!) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                       animations: {
                            self.view.frame = CGRect(x: 0, y: -self.heightScreen,
                                                    width: self.widthScreen,
                                                    height: self.heightScreen)
        }, completion: {(value:Bool) in self.dismiss(animated: false)})
        
        (presentingViewController as? ViewController)?.showEye()
    }
    
}
