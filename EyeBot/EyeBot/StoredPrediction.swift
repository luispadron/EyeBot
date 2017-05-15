//
//  StoredPrediction.swift
//  EyeBot
//
//  Created by Luis Padron on 5/15/17.
//  Copyright © 2017 com.eyebot. All rights reserved.
//

import RealmSwift

class StoredPrediction: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var imageData: Data = Data()
    dynamic var label: String = ""
    dynamic var probability: Double = 0.0
    
    var image: UIImage? {
        get {
            return UIImage(data: self.imageData)
        }
    }
    
    convenience init?(image: UIImage, label: String, probability: Double) {
        self.init()
        
        guard let img = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        self.imageData = img
        self.label = label
        self.probability = probability
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
