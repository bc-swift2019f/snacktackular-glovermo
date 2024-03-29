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
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
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
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        // Convert photo.image to a data type so it can be saved by Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("*** ERROR: Could not convert image to data format")
            return completed(false)
        }
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        // Generate a unique ID to use for the photo.image's name
        documentUUID = UUID().uuidString
        // Create a ref to upload storage to spot.documentID's folder (bucket) with the name we created
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)

        let uploadTask = storageRef.putData(photoData, metadata: uploadMetadata) {
            metadata, error in
            guard error == nil else {
                print("ERROR during putData storage upload for reference \(storageRef). Error: \(error?.localizedDescription)")
                return
            }
            print("Upload worked! Metadata is \(metadata)")
        }
        uploadTask.observe(.success) { (snapshot) in
            // Create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            // This will either create a new doc at documentUUID or update the existing doc with that name
            
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** Error updating document \(self.documentUUID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("*** ERROR: Upload task for file \(self.documentUUID) failed in spot \(spot.documentID)")
            }
            return completed(false)
        }
    }
}
