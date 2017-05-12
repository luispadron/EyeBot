//
//  EinsteinManager.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation

open class EinsteinManager {
    /// The singleton for the manager
    open static let shared = EinsteinManager()
    
    open var apiUrl: String = "https://api.metamind.io/v1/vision/predict"
    open var token: String = ""
    
}
