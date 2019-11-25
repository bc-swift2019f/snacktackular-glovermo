//
//  ReviewTableViewController.swift
//  Snacktacular
//
//  Created by Morgan Glover on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit
import Firebase

class ReviewTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet var starButtonCollection: [UIButton]!
    
    var spot: Spot!
    var review: Review!
    let dateFormatter = DateFormatter()
    var rating = 0 {
        didSet {
            for starButton in starButtonCollection {
                let image = UIImage(named: (starButton.tag < rating ? "star-filled" : "star-empty"))
                starButton.setImage(image, for: .normal)
            }
//            print(">>> new rating: \(rating)")
            review.rating = rating
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if tap outside field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard let spot = spot else {
            print("no valid spot in Review Detail VC")
            return
        }
        
        if review == nil {
            review = Review()
        }

        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        rating = review.rating
        reviewTitleField.text = review.title
        enableDisableSaveButton()
        reviewTextView.text = review.text
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        reviewDateLabel.text = "posted: \(dateFormatter.string(from: review.date))"
        if review.documentID == "" { // new review
            addBordersToEditableObjects()
        } else {
            if review.reviewerUserID == Auth.auth().currentUser?.email { // review posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else { // review posted by other user
                cancelBarButton.title = ""
                saveBarButton.title = ""
                postedByLabel.text = "Posted by: \(review.reviewerUserID)"
                //disable stars
                for starButton in starButtonCollection {
                    starButton.backgroundColor = UIColor.white
                    starButton.adjustsImageWhenDisabled = false
                    starButton.isEnabled = false
                    reviewTitleField.isEnabled = false
                    reviewTextView.isEditable = false
                    reviewTitleField.backgroundColor = UIColor.white
                    reviewTextView.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    func addBordersToEditableObjects() {
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func enableDisableSaveButton() {
        if reviewTitleField.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func saveThenSegue() {
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
        review.saveData(spot: spot) { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = Int(sender.tag) + 1
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
    }
    
    @IBAction func reviewTitleChanged(_ sender: UITextField) {
        enableDisableSaveButton()
    }
    
    @IBAction func returnTitleDonePressed(_ sender: UITextField) {
        saveThenSegue()
    }
}
