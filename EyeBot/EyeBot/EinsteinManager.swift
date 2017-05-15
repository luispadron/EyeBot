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
    public static let generalImageId = "GeneralImageClassifier"
    
    /// The message string which will determine an invalid access token
    public static var invalidTokenMessage = "Invalid access token"
    
    /// The header for the post request when predicting an image
    public var predictHeaders: HTTPHeaders = [
        "Cache-Control" : "no-cache",
        "Content-Type"  : "multipart/form-data"
    ]
    
    /// The API Url endpoint which the manager will interact with
    open var apiUrl: String = "https://api.metamind.io/v1/vision/predict/"
    
    /// The JWT token that is grabbed from the Einstein authorization page
    open var token: String? {
        didSet {
            // Update the predict header to include the authorization
            if let token = self.token {
                self.predictHeaders["Authorization"] = "Bearer \(token)"
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
    public func predictImage(_ img: UIImage, withModelId modelId: String, completion: @escaping PredictionCompletion) {
        guard let imgData = UIImageJPEGRepresentation(img, 70) else {
            fatalError("Error converting image to png representation: \(img)")
        }
        
        let base64String = imgData.base64EncodedString()
        
        guard let base64ImgData = base64String.data(using: .utf8, allowLossyConversion: false),
            let modelIdData = modelId.data(using: .utf8, allowLossyConversion: false)
        else {
            fatalError("Error converting either modelID or img to to data")
        }
        
        // Start activity indicator
        toggleActivityIndicator()
        
        Alamofire.upload(
            multipartFormData:
            { (multipartFormData) in
                // Create the form data and append it
                multipartFormData.append(base64ImgData,
                                         withName: "sampleBase64Content",
                                         mimeType: "text/plain")
                multipartFormData.append(modelIdData,
                                         withName: "modelId",
                                         mimeType: "text/plain")
            },
            usingThreshold: UInt64(),
            to: self.apiUrl,
            method: .post,
            headers: self.predictHeaders)
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
                
                // Stop activity indicator
                self.toggleActivityIndicator()
                // Call the completion and send it the prediction
                completion?(Prediction(withJSON: json), error)
            }
            
        case .failure(let error):
            print("Error collecting result from prediction, error: \(error)")
        }
    }
    
    
    /// Toggles the activity indicator view
    private func toggleActivityIndicator() {
        guard let window = UIApplication.shared.keyWindow else {
            print("Unable to get window for application")
            return
        }
        
        DispatchQueue.main.async {
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
}
