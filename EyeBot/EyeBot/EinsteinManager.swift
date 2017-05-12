//
//  EinsteinManager.swift
//  EyeBot
//
//  Created by Luis Padron on 5/12/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import Foundation
import Alamofire

open class EinsteinManager {
    /// The singleton for the manager
    open static let shared = EinsteinManager()
    
    open var apiUrl: String = "https://api.metamind.io/v1/vision/predict/"
    open var token: String?
    static var generalImageId = "GeneralImageClassifier"
    
    public func predictGeneralImage(imageUrl: String) {
        guard let token = self.token else {
            fatalError("No token assigned to \(self)")
        }
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(token)",
            "Cache-Control" : "no-cache",
            "Content-Type"  : "multipart/form-data"
        ]
        
        Alamofire.upload(
            multipartFormData:
            { multipartFormData in
                multipartFormData.append(
                    imageUrl.data(using: .utf8, allowLossyConversion: false)!,
                    withName: "sampleLocation",
                    mimeType: "text/plain"
                )
                multipartFormData.append(
                    EinsteinManager.generalImageId.data(using: .utf8, allowLossyConversion: false)!,
                    withName: "modelId",
                    mimeType: "text/plain"
                )
            },
                         usingThreshold: UInt64.init(),
                         to: self.apiUrl,
                         method: .post,
                         headers: headers,
                         encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
}
