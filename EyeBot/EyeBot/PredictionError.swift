//
//  PredictionError.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation

/// An error struct created when prediction fails for some reason which holds a message
public struct PredictionError {
    let message: String
    
    init(message: String) {
        self.message = message
    }
}
