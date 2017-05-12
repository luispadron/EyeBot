//
//  ViewController.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    let captureButton = UIButton(type: .custom)
    
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
    
    func captureButtonTapped(sender: UITapGestureRecognizer? = nil) {
        print("Capture Button Tapped")
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
        
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        
        captureButton.frame = CGRect(x: widthScreen/2, y: heightScreen-50, width: 75, height: 75)
        captureButton.center = CGPoint(x: widthScreen/2, y: heightScreen-50)
        captureButton.layer.cornerRadius = 1
        captureButton.clipsToBounds = true
        captureButton.setImage(#imageLiteral(resourceName: "captureButton"), for: .normal)
        let touchCaptureButton: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(captureButtonTapped))
        touchCaptureButton.numberOfTapsRequired = 1
        touchCaptureButton.delegate = self
        captureButton.addGestureRecognizer(touchCaptureButton)
        previewLayer?.addSublayer(self.captureButton.layer)
    }
}

