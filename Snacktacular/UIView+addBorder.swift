//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by Morgan Glover on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
        self.layer.borderColor = color.cgColor
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}
