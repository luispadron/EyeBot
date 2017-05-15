//
//  StoredPrediction.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import RealmSwift

class StoredPrediction: Object {
    dynamic var label: String = ""
    dynamic var probability: Double = 0.0
    
    convenience init(label: String, probability: Double) {
        self.init()
        self.label = label
        self.probability = probability
    }
}
