//
//  Prediction.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation

/// Prediction struct, returned in a prediction call when using EinsteinManager
public struct Prediction {
    let mostProbable: Probability
    let leastProbable: Probability
    let allProbabilities: [Probability]
    
    init?(withJSON json: [String : Any]) {
        guard let probabiltiesJSON = json["probabilities"] as? [AnyObject] else {
            return nil
        }
        
        var probabilities = [Probability]()
        
        for probJSON in probabiltiesJSON {
            let label = probJSON.value(forKey: "label") as! String
            let percent = probJSON.value(forKey: "probability") as! Double
            probabilities.append(Probability(label: label, percent: percent * 100))
        }
        
        probabilities.sort { $0.percent > $1.percent }
        self.mostProbable = probabilities.first!
        self.leastProbable = probabilities.last!
        self.allProbabilities = probabilities
    }
}
