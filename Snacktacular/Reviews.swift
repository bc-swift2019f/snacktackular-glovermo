//
//  Reviews.swift
//  Snacktacular
//
//  Created by Morgan Glover on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray = [Review]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
        //whenever anything changes in “spots”, run the code in the curls that follow, which will load in the new data with any changes
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            //empty out array or you’ll get duplicates
            self.reviewArray = []
            // there are querySnapshot!.documents.count documents in the spots snapshot. querySnapshot contains results, with all documents stored in its .documents property
            // loop through all of the documents returned by querySnapshot. Each document has data stored in a dictionary in document.data()
            for document in querySnapshot!.documents {
                // Spot(dictionary:) is a completion handler (not yet written) in the Spot class that will accept a dictionary and return a new instance of Spot from the dictionary’s key:value pairs
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
                // append each new Spot that we read in to the spotArray property of Spots
            }
            completed()
        }
    }
    
}
