//
//  ResultViewController.swift
//  EyeBot
//
//  Created by christopher paul perkins on 5/13/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit
import RealmSwift

class ResultViewController: UIViewController {
    let widthScreen = UIScreen.main.bounds.width
    let heightScreen = UIScreen.main.bounds.height
    var prediction:Prediction? = nil
    
    var image:UIImage? = nil
    
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
            
            let loc = (heightScreen - 130 - widthScreen) / 2
            
            // Logo at the top of the view
            let logo = UIImage(imageLiteralResourceName: "Eye Exclamation")
            let logoView = UIImageView(image: logo)
            logoView.frame = CGRect(x: widthScreen / 2 - 75 / 2, y: 25,
                                     width: 75, height: 75)
            
            // Label for user clarity
            let foundLabel = UILabel(frame: CGRect(x: 10, y: 100 + loc,
                                                   width: self.widthScreen - 20, height: 20))
            
            // Default: use "a" rather than "an".
            foundLabel.text = "I think I found a..."
            
            // If the string of the predicted image starts with a vowel, replace "a" with "an"
            for vowel in ["a", "e", "i", "o", "u"] {
                if (prediction?.mostProbable.label.lowercased().hasPrefix(vowel))! {
                    foundLabel.text = "I think I found an..."
                    break
                }
            }
            foundLabel.font = foundLabel.font.withSize(20)
            foundLabel.textAlignment = NSTextAlignment.center
            foundLabel.textColor = UIColor.white
            
            // Label to display the top prediction
            let topPrediction = UILabel(frame: CGRect(x: 10, y: 130 + loc,
                                                      width: self.widthScreen - 20, height: 30))
            topPrediction.text = prediction?.mostProbable.label as String?
            topPrediction.font = topPrediction.font.withSize(30)
            topPrediction.textAlignment = NSTextAlignment.center
            topPrediction.textColor = UIColor.white
            
            // Image for result
            let resultImage = UIImage(imageLiteralResourceName:
                                        (prediction?.mostProbable.label as String!))
            let resultImageView = UIImageView(image: resultImage)
            resultImageView.frame = CGRect(x: 40, y: 160 + loc,
                                     width: widthScreen - 80, height: widthScreen - 80)
            
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
            let wrongButton = UIButton(frame: CGRect(x:0, y: heightScreen - 50,
                                                     width: widthScreen / 2, height: 50))
            wrongButton.setTitle("Wrong", for: .normal)
            wrongButton.setTitleColor(UIColor.red, for: .normal)
            wrongButton.setTitleColor(UIColor.white, for: .highlighted)
            wrongButton.addTarget(self, action: #selector(wrongButtonPressed),
                                  for: .touchUpInside)
            
            // Button to denote our prediction is right
            let correctButton = UIButton(frame: CGRect(x:widthScreen / 2, y: heightScreen - 50,
                                                     width: widthScreen / 2, height: 50))
            correctButton.setTitle("Correct", for: .normal)
            correctButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255.0,
                                                blue: 1, alpha: 1), for: .normal)
            correctButton.setTitleColor(UIColor.white, for: .highlighted)
            correctButton.addTarget(self, action: #selector(correctButtonPressed),
                                  for: .touchUpInside)
            
            // Frame blur behind frame contents
            self.view.addSubview(resultsView)
            
            self.view.addSubview(logoView)
            self.view.addSubview(foundLabel)
            self.view.addSubview(topPrediction)
            self.view.addSubview(resultImageView)
            self.view.addSubview(horizontalBar)
            self.view.addSubview(verticalBar)
            self.view.addSubview(wrongButton)
            self.view.addSubview(correctButton)
            
            // Slide down results view
            UIView.animate(withDuration: 0.5, delay: 0.6, options: [],
                           animations: {
                            self.view.frame = CGRect(x: 0, y: 0, width: self.widthScreen,
                                                    height: self.heightScreen)
            }, completion: nil)
            
            self.loaded = true
        }
    }
    
    func wrongButtonPressed(sender: UIButton) {
        self.modalPresentationStyle = .overCurrentContext
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyBoard.instantiateViewController(withIdentifier: "wireSelectorViewController")
        let vc = nav.childViewControllers.first
        nav.view.backgroundColor = UIColor.clear
        nav.modalPresentationStyle = .overCurrentContext
        vc?.modalPresentationStyle = .overCurrentContext
        self.definesPresentationContext = true
        self.present(nav, animated: false, completion: nil)
    }
    
    func correctButtonPressed(sender: UIButton)
    {
        // Dropbox upload call goes here
        updateTrainingAndRealm(label: (self.prediction?.mostProbable.label)!)
        
        
        resultsViewClose()
    }
    
    // When the close button is tapped
    func resultsViewClose() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                       animations: {
                            self.view.frame = CGRect(x: 0, y: -self.heightScreen,
                                                    width: self.widthScreen,
                                                    height: self.heightScreen)
        }, completion: {(value:Bool) in self.dismiss(animated: false)})
        
        (presentingViewController as? ViewController)?.showEye()
    }
    
    func updateTrainingAndRealm(label: String) {
        if let storedPrediction = StoredPrediction(image: self.image!,
                                                   label: label,
                                                   probability: (self.prediction?.mostProbable.percent)!) {
            let realm = try! Realm()
            try! realm.write {
                realm.create(StoredPrediction.self, value: storedPrediction, update: false)
            }
            
            if label != "Unknown" {
                // Save to realm and show popover
                EinsteinManager.shared.trainDataset("1002973", image: (storedPrediction.image)!, label: label)
            }
        } else {
            print("Error creating stored prediction and saving to Realm....")
        }
    }
    
}
