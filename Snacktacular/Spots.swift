//
//  Spots.swift
//  Snacktacular
//
//  Created by Morgan Glover on 11/3/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Spots {
    var spotArray = [Spot]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        //whenever anything changes in “spots”, run the code in the curls that follow, which will load in the new data with any changes
        db.collection("spots").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            //empty out array or you’ll get duplicates
            self.spotArray = []
            // there are querySnapshot!.documents.count documents in the spots snapshot. querySnapshot contains results, with all documents stored in its .documents property
            // loop through all of the documents returned by querySnapshot. Each document has data stored in a dictionary in document.data()
            for document in querySnapshot!.documents {
                // Spot(dictionary:) is a completion handler (not yet written) in the Spot class that will accept a dictionary and return a new instance of Spot from the dictionary’s key:value pairs
                let spot = Spot(dictionary: document.data())
                spot.documentID = document.documentID
                self.spotArray.append(spot)
                // append each new Spot that we read in to the spotArray property of Spots
            }
            completed()
        }
    }
}
