//
//  EinsteinManager.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation
import Alamofire

/// Prediction struct, returned in a prediction call when using EinsteinManager
public struct Prediction {
//    let mostProbable: Probability
//    let leastProbable: Probability
//    let allProbabilities: [Probability]
//    
//    init(probabilities: [Probability]) {
//        
//        let probs = probabilities.sorted {
//            $0.probability ?? 0 > $1.probability ?? 0
//        }
//        self.mostProbable = probs.first!
//        self.leastProbable = probs.last!
//        self.allProbabilities = probabilities
//    }
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
    public typealias PredictionCompletion = (Prediction) -> Void
    
    
    public func predictImage(_ img: UIImage, withModelId modelId: String, completion: PredictionCompletion) {
        guard let imgData = UIImagePNGRepresentation(img) else {
            fatalError("Error converting image to png representation: \(img)")
        }
        
        let base64Img = imgData.base64EncodedString()
        
    }
}
