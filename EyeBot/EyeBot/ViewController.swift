//
//  ViewController.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class ViewController: UIViewController {
    
    let captureButton = UIButton(type: .custom)
    let settingsButton = UIButton(type: .custom)
    let flashButton = UIButton(type: .custom)
    let touchButton = UIButton(type: .custom)
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    var hasPreparedCamera = false
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasPreparedCamera {
            prepareCamera()
            hasPreparedCamera = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                  mediaType: AVMediaTypeVideo,
                                                                  position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            let button = UIButton(type: .system)
            button.center = self.view.center
            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            let touchRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(actionButtonsPressed(touch:)))
            
            touchRecognizer.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(touchRecognizer)

            addSettingsButton()
            addFlashButton()
            addCaptureButton()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.EyeBot.EyeBot")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    func actionButtonsPressed(touch: UITapGestureRecognizer) {
        // If the results screen is open, do not accept input.
        if let _ = self.view.viewWithTag(100) {
        }
        else {
            let touchPoint = touch.location(in: self.view)
            let myCaptureButtonArea = CGRect(x: captureButton.frame.origin.x,
                                             y: captureButton.frame.origin.y,
                                             width: captureButton.frame.width,
                                             height: captureButton.frame.height)
            
            let myFlashButtonArea = CGRect(x: flashButton.frame.origin.x,
                                           y: flashButton.frame.origin.y,
                                           width: flashButton.frame.width,
                                           height: flashButton.frame.height)
            
            let mySettingsButtonArea = CGRect(x: settingsButton.frame.origin.x,
                                              y: settingsButton.frame.origin.y,
                                              width: settingsButton.frame.width,
                                              height: settingsButton.frame.height)
            
            if myCaptureButtonArea.contains(touchPoint) {
                takePhoto = true
            } else if myFlashButtonArea.contains(touchPoint) {
                if let device = captureDevice {
                    do {
                        try device.lockForConfiguration()
                        if device.isTorchActive {
                            device.torchMode = AVCaptureTorchMode.off
                        } else {
                            device.torchMode = AVCaptureTorchMode.on
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                } 
            }
            else if mySettingsButtonArea.contains(touchPoint) {
                self.settingsButtonWasPressed(button: self.settingsButton)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let myCaptureButtonArea = CGRect(x: captureButton.frame.origin.x,
                                         y: captureButton.frame.origin.y,
                                         width: captureButton.frame.width,
                                         height: captureButton.frame.height)
        
        let screenSize = UIScreen.main.bounds.size
        
        if let touchPoint = touches.first {
            
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = touchPoint.location(in: self.view).x / screenSize.width
            
            let focusPoint = CGPoint(x: x,
                                     y: y)
            
            if !myCaptureButtonArea.contains((touches.first?.location(in: self.view))!) {
                if let device = captureDevice {
                    
                    do {
                        try device.lockForConfiguration()
                        touchButton.frame = CGRect(x: touchPoint.location(in: self.view).x, y: touchPoint.location(in: self.view).y, width: 15, height: 15)
                        touchButton.setImage(#imageLiteral(resourceName: "touchButton"), for: .normal)
                        previewLayer.addSublayer(self.touchButton.layer)
                        device.focusPointOfInterest = focusPoint
                        device.focusMode = .autoFocus
                        device.exposurePointOfInterest = focusPoint
                        device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                        device.unlockForConfiguration()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let timeWhen = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: timeWhen, execute: {
            self.touchButton.layer.removeFromSuperlayer()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let timeWhen = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: timeWhen, execute: {
            self.touchButton.layer.removeFromSuperlayer()
        })
    }

    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0,
                                   y: 0,
                                   width: CVPixelBufferGetWidth(pixelBuffer),
                                   height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                
                return UIImage(cgImage: image,
                               scale: UIScreen.main.scale,
                               orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    // MARK: Views
    
    func addSettingsButton() {
        settingsButton.frame = CGRect(x: 20, y: 20, width: 30, height: 30)
        settingsButton.clipsToBounds = true
        settingsButton.setImage(#imageLiteral(resourceName: "settingsButton"), for: .normal)
        previewLayer?.addSublayer(self.settingsButton.layer)
    }
    
    func addFlashButton() {
        let widthScreen = UIScreen.main.bounds.width
        flashButton.frame = CGRect(x: widthScreen - 60,
                                   y: 20, width: 30, height: 30)
        flashButton.clipsToBounds = true
        flashButton.setImage(#imageLiteral(resourceName: "flashButton"), for: .normal)
        previewLayer?.addSublayer(self.flashButton.layer)
    }
    
    func addCaptureButton() {
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        
        // Set below the screen (for animating later)
        captureButton.frame = CGRect(x: widthScreen/2, y: heightScreen + 38, width: 75, height: 75)
        captureButton.center = CGPoint(x: widthScreen / 2, y: heightScreen + 38)
        captureButton.clipsToBounds = true
        captureButton.setImage(#imageLiteral(resourceName: "captureButton"), for: .normal)
        previewLayer?.addSublayer(self.captureButton.layer)
        
        // Animate to slide into the screen
        UIView.animate(withDuration: 0.4, delay: 0.5, options: [], animations: {
            self.captureButton.frame = CGRect(x: widthScreen / 2, y: heightScreen - 50,
                                         width: 75, height: 75)
            self.captureButton.center = CGPoint(x: widthScreen/2, y: heightScreen - 50)
        }, completion: nil)
    }
    
    // MARK: Actions
    
    func settingsButtonWasPressed(button: UIButton) {
        let storyBoard = UIStoryboard(name: "Predictions", bundle: nil)
        let nav = storyBoard.instantiateViewController(withIdentifier: "predictionsNavController")
        let vc = nav.childViewControllers.first
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .overCurrentContext
        vc?.modalPresentationStyle = .overCurrentContext
        vc?.modalTransitionStyle = .crossDissolve
        self.definesPresentationContext = true
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    func showResultPopover(prediction: Prediction) {
        self.modalPresentationStyle = .overCurrentContext
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyBoard.instantiateViewController(withIdentifier: "resultViewController")
        let vc = nav.childViewControllers.first
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .overCurrentContext
        vc?.modalPresentationStyle = .overCurrentContext
        vc?.modalTransitionStyle = .crossDissolve
        self.definesPresentationContext = true
        self.present(nav, animated: false, completion: nil)
        
        let widthScreen = UIScreen.main.bounds.width
        let heightScreen = UIScreen.main.bounds.height
        
        // Hide the capture button
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [],
                       animations: {
                            self.captureButton.frame = CGRect(x:widthScreen / 2,
                                                              y: heightScreen + 38,
                                                              width: 75, height: 75)
                            self.captureButton.center = CGPoint(x: widthScreen / 2,
                                                                y: heightScreen + 38)
                        }, completion: nil)
    }
    
    fileprivate func makePrediction(forImage image: UIImage) {
        // Disable button while predicting
        self.captureButton.isEnabled = false
        // Make prediction
        EinsteinManager.shared.predictImage(image,
                                            withModelId: "2KRSUDVHTRUGGC7AX5RAVS4LE4",
                                            completion:
        { (prediction, error) in
            guard let pred = prediction else {
                if let err = error {
                    print("Error getting image prediction: \(err.message)")
                }
                return
            }
            
            // Save to realm and show popover
            
            if let storedPrediction = StoredPrediction(image: image,
                                                       label: pred.mostProbable.label,
                                                       probability: pred.mostProbable.percent) {
                let realm = try! Realm()
                try! realm.write {
                    realm.create(StoredPrediction.self, value: storedPrediction, update: false)
                }
            } else {
                print("Error creating stored prediction and saving to Realm....")
            }
            
            // Enable button again
            self.captureButton.isEnabled = true
            
            // Show results VC
            self.showResultPopover(prediction: pred)
        })

    }
}

// MARK: Delegation for AVCaptureVideo

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                makePrediction(forImage: image)
                
                // Save the image to Realm
            }
        }
    }
    
    
}
