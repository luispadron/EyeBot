
//
//  ViewController.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        actionLaunchCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func actionLaunchCamera()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = true
        imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
        
        let historyButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(showHistory))
        
        imagePicker.navigationBar.isHidden = false
        imagePicker.navigationBar.tintColor = UIColor.white
        imagePicker.navigationBar.barStyle = UIBarStyle.blackTranslucent

        imagePicker.navigationItem.rightBarButtonItem = historyButton
  
        let screenBounds: CGSize = UIScreen.main.bounds.size
        
        let scale = screenBounds.height / screenBounds.width
        
        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
            
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showHistory() {
        print("Showing History")
    }

}

