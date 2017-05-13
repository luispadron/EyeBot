//
//  EinsteinManager.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation
import Alamofire
import SalesforceEinsteinVision

/// Prediction struct, returned in a prediction call when using EinsteinManager
public struct Prediction {
    let mostProbable: Probability
    let leastProbable: Probability
    let allProbabilities: [Probability]
    
    init(probabilities: [Probability]) {
        
        let probs = probabilities.sorted {
            $0.probability ?? 0 > $1.probability ?? 0
        }
        self.mostProbable = probs.first!
        self.leastProbable = probs.last!
        self.allProbabilities = probabilities
    }
}

/// The EinsteinManager handles all the API calls to the Einstein image prediction service
/// It is a light wrapper over SalesforceEinsteinVision
open class EinsteinManager {
    /// The singleton for the manager
    open static let shared = EinsteinManager()
    
    /// General Image ID for classifying
    static let generalImageId = "GeneralImageClassifier"
    
    /// The API Url endpoint which the manager will interact with
    open var apiUrl: String = "https://api.metamind.io/v1/vision/predict/"
    
    /// The JWT token that is grabbed from the Einstein authorization page
    open var token: String?
    
    /// Typealias for the completion of a prediction call
    public typealias PredictionCompletion = (Prediction?) -> Void
    
    /// The prediction service for the Einstein manager
    private lazy var service: PredictionService = {
        guard let token = self.token else {
            fatalError("Token not set for Manager: \(self)")
        }
        
        return PredictionService(bearerToken: token)!
    }()
    
    public func predictImage(_ img: UIImage, withModelId modelId: String, completion: @escaping PredictionCompletion) {
        guard let imgData = UIImagePNGRepresentation(img) else {
            fatalError("Error converting image to png representation: \(img)")
        }
        
        let base64Img = imgData.base64EncodedString()
        
        service.predictBase64(modelId: modelId,
                              base64: base64Img,
                              sampleId: "")
        { [unowned self] (result) in
            let prediction = self.collectResult(result)
            completion(prediction)
        }
    }
    
    private func collectResult(_ result: PredictionResult?) -> Prediction? {
        guard let probs = result?.probabilities else {
            print("No results collected")
            return nil
        }
        
        return Prediction(probabilities: probs)
    }
}
