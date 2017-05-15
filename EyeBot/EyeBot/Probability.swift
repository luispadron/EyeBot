//
//  Probability.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation

/// The probability for a predicted image
public struct Probability {
    let label: String
    let percent: Double
    
    init(label: String, percent: Double) {
        self.label = label
        self.percent = percent
    }
}
