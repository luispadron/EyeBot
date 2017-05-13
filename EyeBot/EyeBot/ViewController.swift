//
//  ViewController.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, AVCapturePhotoCaptureDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    let stillImageOutput = AVCapturePhotoOutput()
    
    let captureButton = UIButton(type: .custom)
    let settingsButton = UIButton(type: .custom)
    let flashButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                             mediaType: AVMediaTypeVideo,
                                                                             position: AVCaptureDevicePosition.unspecified) {
            
            for device in deviceDescoverySession.devices {
                if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                        captureDevice = device
                        if captureDevice != nil {
                            beginSession()
                        }
                        else {
                            let alertTitle = "There was an issue loading the camera"
                            let alertController = UIAlertController(
                                title: nil,
                                message: alertTitle,
                                preferredStyle: UIAlertControllerStyle.alert
                            )
                            
                            let discardChangesAction = UIAlertAction(
                                title: "Try Again",
                                style: UIAlertActionStyle.destructive) { (action) in
                                    self.loadData()
                                    self.dismiss(animated: true, completion: nil)}
                            
                            
                            let continueEditing = UIAlertAction(
                                title: "OK",
                                style: UIAlertActionStyle.destructive) { (action) in }
                            
                            alertController.addAction(discardChangesAction)
                            alertController.addAction(continueEditing)
                            
                            present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadData() {
        viewDidLoad()
    }
    
    func testAction(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: self.view)
        let myCaptureButtonArea = CGRect(x: captureButton.frame.origin.x, y: captureButton.frame.origin.y, width: captureButton.frame.width, height: captureButton.frame.height)
        let myFlashButtonArea = CGRect(x: flashButton.frame.origin.x, y: flashButton.frame.origin.y, width: flashButton.frame.width, height: flashButton.frame.height)
        let mySettingsButtonArea = CGRect(x: settingsButton.frame.origin.x, y: settingsButton.frame.origin.y, width: settingsButton.frame.width, height: settingsButton.frame.height)
        if myCaptureButtonArea.contains(touchPoint) {
            print ("Capture Button Tapped")
        } else if myFlashButtonArea.contains(touchPoint) {
            print ("Flash Button Tapped")
        } else if mySettingsButtonArea.contains(touchPoint) {
            print ("Settings Button Tapped")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let device = captureDevice {
            do { try captureDevice!.lockForConfiguration() }
            catch let error1 as NSError { print(error1) }
            
            device.focusMode = AVCaptureFocusMode.autoFocus
            device.exposureMode = AVCaptureExposureMode.autoExpose
            
            device.unlockForConfiguration()
        }
        super.touchesBegan(touches, with: event)
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do { try captureDevice!.lockForConfiguration() }
            catch let error1 as NSError { print(error1) }
            
            device.focusMode = .locked
            device.unlockForConfiguration()
        }
    }
    
    func beginSession() {
        configureDevice()
        var err : NSError? = nil
        
        var deviceInput: AVCaptureDeviceInput!
        do { deviceInput = try AVCaptureDeviceInput(device: captureDevice) }
        catch let error as NSError {
            err = error
            deviceInput = nil
        };
        
        captureSession.addInput(deviceInput)
        
        if err != nil {
            print("error: \(String(describing: err?.localizedDescription))")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(testAction(touch:)))
        touchRecognizer.numberOfTapsRequired = 1
        touchRecognizer.delegate = self
        self.view.addGestureRecognizer(touchRecognizer)
        
        addSettingsButton()
        addFlashButton()
        addCaptureButton()
    }
    
    func addSettingsButton() {
        settingsButton.frame = CGRect(x: 10, y: 20, width: 30, height: 30)
        settingsButton.clipsToBounds = true
        settingsButton.setImage(#imageLiteral(resourceName: "settingsButton"), for: .normal)
        previewLayer?.addSublayer(self.settingsButton.layer)
    }
    
    func addFlashButton() {
        flashButton.frame = CGRect(x: 375, y: 25, width: 30, height: 30)
        flashButton.clipsToBounds = true
        flashButton.setImage(#imageLiteral(resourceName: "flashButton"), for: .normal)
        previewLayer?.addSublayer(self.flashButton.layer)
    }
    
    func addCaptureButton() {
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        captureButton.frame = CGRect(x: widthScreen/2, y: heightScreen-50, width: 75, height: 75)
        captureButton.center = CGPoint(x: widthScreen/2, y: heightScreen-50)
        captureButton.clipsToBounds = true
        captureButton.setImage(#imageLiteral(resourceName: "captureButton"), for: .normal)
        previewLayer?.addSublayer(self.captureButton.layer)
    }
}

