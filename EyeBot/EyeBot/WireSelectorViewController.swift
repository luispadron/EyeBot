//
//  wireSelectorViewController.swift
//  EyeBot
//
//  Created by christopher paul perkins on 5/16/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class WireSelectorViewController: UIViewController {
    let widthScreen = UIScreen.main.bounds.width
    let heightScreen = UIScreen.main.bounds.height
    var loaded = false
    
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
            
            // Logo for at the top of the window
            let logo = UIImage(imageLiteralResourceName: "captureButton")
            let logoView = UIImageView(image: logo)
            logoView.frame = CGRect(x: widthScreen / 2 - 75 / 2, y: 25,
                                    width: 75, height: 75)
            
            // Label for user clarity
            let describingLabel = UILabel(frame: CGRect(x: 10, y: 125,
                                                   width: self.widthScreen - 20, height: 30))
            describingLabel.text = "What item is this?"
            describingLabel.font = describingLabel.font.withSize(30)
            describingLabel.textAlignment = NSTextAlignment.center
            describingLabel.textColor = UIColor.white
            
            // Dividing bar (just for aesthetics)
            let horizontalBar = UIView(frame: CGRect(x: 0, y: heightScreen - 50,
                                                     width: widthScreen, height: 1))
            horizontalBar.backgroundColor = UIColor.white
            horizontalBar.layer.opacity = 0.25
            
            let verticalBar = UIView(frame: CGRect(x: widthScreen / 2, y: heightScreen - 50,
                                                   width: 1, height: 50))
            verticalBar.backgroundColor = UIColor.white
            verticalBar.layer.opacity = 0.25
            
            // Button to denote our prediction was wrong
            let dontKnowButton = UIButton(frame: CGRect(x:0, y: heightScreen - 50,
                                                     width: widthScreen / 2, height: 50))
            dontKnowButton.setTitle("I Don't Know", for: .normal)
            dontKnowButton.setTitleColor(UIColor.red, for: .normal)
            dontKnowButton.setTitleColor(UIColor.white, for: .highlighted)
            dontKnowButton.addTarget(self, action: #selector(dontKnowButtonPressed),
                                  for: .touchUpInside)
            
            // Button to denote our prediction is right
            let selectButton = UIButton(frame: CGRect(x:widthScreen / 2, y: heightScreen - 50,
                                                       width: widthScreen / 2, height: 50))
            selectButton.setTitle("Select", for: .normal)
            selectButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255.0,
                                                blue: 1, alpha: 1), for: .normal)
            selectButton.setTitleColor(UIColor.white, for: .highlighted)
            selectButton.addTarget(self, action: #selector(selectButtonPressed),
                                    for: .touchUpInside)
            
            // Frame blur behind frame contents
            self.view.addSubview(resultsView)
            
            self.view.addSubview(logoView)
            self.view.addSubview(describingLabel)
            self.view.addSubview(horizontalBar)
            self.view.addSubview(verticalBar)
            self.view.addSubview(dontKnowButton)
            self.view.addSubview(selectButton)
            
            // Slide down results view
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                           animations: {
                            self.view.frame = CGRect(x: 0, y: 0, width: self.widthScreen,
                                                     height: self.heightScreen)
            }, completion: nil)
            
            loaded = true
        }
    }
    
    func dontKnowButtonPressed(sender: UIButton) {
        wireSelectorViewClose()
    }
    
    func selectButtonPressed(sender: UIButton) {
        
    }
    
    func wireSelectorViewClose() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                       animations: {
                        self.view.frame = CGRect(x: 0, y: -self.heightScreen,
                                                 width: self.widthScreen,
                                                 height: self.heightScreen)
        }, completion: {(value:Bool) in self.dismiss(animated: false)})
        
        (presentingViewController as? ResultViewController)?.resultsViewClose()
    }
}
