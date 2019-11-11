//
//  Photo.swift
//  Snacktacular
//
//  Created by Morgan Glover on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String // universal unique identifier
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let time = dictionary["date"] as! Timestamp?
        let date = time?.dateValue() ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
}
