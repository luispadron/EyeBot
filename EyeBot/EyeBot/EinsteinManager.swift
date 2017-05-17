//
//  EinsteinManager.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation
import Alamofire

/// The EinsteinManager handles all the API calls to the Einstein image prediction service
/// It is a light wrapper over SalesforceEinsteinVision
open class EinsteinManager {
    /// The singleton for the manager
    open static let shared = EinsteinManager()
    
    /// General Image ID for classifying
    open static let generalImageId = "GeneralImageClassifier"
    
    /// The message string which will determine an invalid access token
    open static var invalidTokenMessage = "Invalid access token"
    
    /// The header for the post request when predicting an image
    open static var predictHeaders: HTTPHeaders = [
        "Cache-Control" : "no-cache",
        "Content-Type"  : "multipart/form-data"
    ]
    
    /// The headers for the post request when training an image
    open static var trainHeaders: HTTPHeaders = [
        "Cache-Control" : "no-cache",
        "Content-Type"  : "multipar/form-data"
    ]
    
    /// The API Url endpoint which the manager will interact with when predicting an image
    open static var predictUrl: String = "https://api.metamind.io/v1/vision/predict/"
    
    /// The API Url endpoint which the manager will interact with when training an image
    open static var trainUrl: String = "https://api.metamind.io/v1/vision/train/"
    
    /// The JWT token that is grabbed from the Einstein authorization page
    open var token: String? {
        didSet {
            // Update the predict header to include the authorization
            if let token = self.token {
                EinsteinManager.predictHeaders["Authorization"] = "Bearer \(token)"
                EinsteinManager.trainHeaders["Authorization"] = "Bearer \(token)"
            }
        }
    }
    
    private lazy var activityView: ActivityView = {
        let view = ActivityView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }()
    
    /// Typealias for the completion of a prediction call
    public typealias PredictionCompletion = (Prediction?, PredictionError?) -> Void
    
    /// Predicts an image with a specific modelID, completion will return a prediction or prediction error if something
    /// goes wrong
    open func predictImage(_ img: UIImage, withModelId modelId: String, completion: @escaping PredictionCompletion) {
        guard let imgData = UIImageJPEGRepresentation(img, 70) else {
            fatalError("Error converting image to png representation: \(img)")
        }
        
        let base64String = imgData.base64EncodedString()
        
        guard let base64ImgData = base64String.data(using: .utf8, allowLossyConversion: false),
            let modelIdData = modelId.data(using: .utf8, allowLossyConversion: false)
            else {
                fatalError("Error converting either modelID or img to data")
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.predictImage(base64ImgData, modelIdData: modelIdData, completion: completion)
        }
    }
    
    /// Private helper method to predict the image, happens in the background thread
    private func predictImage(_ base64Img: Data, modelIdData: Data, completion: @escaping PredictionCompletion) {
        // Start activity indicator
        DispatchQueue.main.async {
            self.toggleActivityIndicator()
        }
        
        Alamofire.upload(
            multipartFormData:
            { (multipartFormData) in
                // Create the form data and append it
                multipartFormData.append(base64Img,
                                         withName: "sampleBase64Content",
                                         mimeType: "text/plain")
                multipartFormData.append(modelIdData,
                                         withName: "modelId",
                                         mimeType: "text/plain")
        },
            usingThreshold: UInt64(),
            to: EinsteinManager.predictUrl,
            method: .post,
            headers: EinsteinManager.predictHeaders)
        { (uploadResult) in
            // collect the JSON and return the result
            self.collectJSON(fromResult: uploadResult, completion: completion)
        }
    }
    
    /// Collects the JSON and creates the appropriate Prediction model
    private func collectJSON(fromResult result: SessionManager.MultipartFormDataEncodingResult,
                             completion: PredictionCompletion?) {
        
        switch result {
            
        case .success(let response, _, _):
            response.responseJSON
                { (jsonResponse) in
                    guard let json = jsonResponse.result.value as? [String : Any] else {
                        print("Received no JSON which is convertable to [String: Any] in prediction response")
                        return
                    }
                    
                    var error: PredictionError? = nil
                    if let msg = json["message"] as? String, msg == EinsteinManager.invalidTokenMessage {
                        error = PredictionError(message: "Invalid access token was returned from the server\n" +
                            "Make sure token given to manager is correct.\n" +
                            "Current token is: \(String(describing: self.token))")
                    }
                    
                    DispatchQueue.main.async {
                        // Stop activity indicator
                        self.toggleActivityIndicator()
                        // Call the completion and send it the prediction
                        completion?(Prediction(withJSON: json), error)
                    }
            }
            
        case .failure(let error):
            print("Error collecting result from prediction, error: \(error)")
        }

    }
    
    
    /// Trains a specifc data set with the specified image
    open func trainDataset(_ datasetId: String, image: UIImage, label: String) {
        guard let imgData = UIImageJPEGRepresentation(image, 0.50) else {
            fatalError("Error converting image to png representation: \(image)")
        }
        
        let base64String = imgData.base64EncodedString()
        
        guard let base64ImgData = base64String.data(using: .utf8, allowLossyConversion: false),
            let datasetData = datasetId.data(using: .utf8, allowLossyConversion: false),
            let labelData = label.data(using: .utf8, allowLossyConversion: false)
        else {
            fatalError("Error converting either modelID, image or label to data")
        }
        
        DispatchQueue.global(qos: .background).async {
            self.trainDataset(dataSetData: datasetData, imageData: base64ImgData, labelData: labelData)
        }
    }
    
    /// The private function for training a dataset, happens in a background thread
    private func trainDataset(dataSetData: Data, imageData: Data, labelData: Data) {
        Alamofire.upload(
            multipartFormData:
            { (multipartFormData) in
                // Create the form data and append it
                multipartFormData.append(dataSetData,
                                         withName: "datasetId",
                                         mimeType: "text/plain")
                multipartFormData.append(imageData,
                                         withName: "sampleBase64Content",
                                         mimeType: "text/plain")
                multipartFormData.append(labelData,
                                         withName: "name",
                                         mimeType: "text/plain")
        },
            usingThreshold: UInt64(),
            to: EinsteinManager.trainUrl,
            method: .post,
            headers: EinsteinManager.trainHeaders)
        { (uploadResult) in
            switch uploadResult {
                
            case .success(let response, _, _):
                response.responseJSON { (JSONResponse) in
                    guard let json = JSONResponse.result.value as? [String : Any] else {
                        print("Error converting json to [String: Any]")
                        return
                    }
                    print("Success with training image with dataset id: " +
                        "\(String(describing: String(data: dataSetData, encoding: .utf8)))")
                    if let msg = json["message"] as? String {
                        print("Message: \(msg)")
                    }
                }

            case .failure(let error):
                print("Error training data model with dataset id: " +
                    "\(String(describing: String(data: dataSetData, encoding: .utf8)))" +
                    "\nError: \(error)")
            }
        }
    }
    
    /// Toggles the activity indicator view
    private func toggleActivityIndicator() {
        guard let window = UIApplication.shared.keyWindow else {
            print("Unable to get window for application")
            return
        }
        
        if !window.subviews.contains(self.activityView) {
            window.addSubview(self.activityView)
            self.activityView.center = window.center
        }
        
        if self.activityView.isAnimating {
            self.activityView.stop()
        } else {
            self.activityView.start()
        }
        
    }
}
