//
//  UIImageViewX.swift
//  003 - Onboarding Page
//
//  Created by Mark Moeykens on 1/5/17.
//  Copyright © 2017 Mark Moeykens. All rights reserved.
//

import UIKit

@IBDesignable
class UIImageViewX: UIImageView {
    
        // Gives the imageview a rounded corners
        @IBInspectable var cornerRadius: CGFloat {

            get{
                return layer.cornerRadius
            }
            set {
                layer.cornerRadius = newValue
                layer.masksToBounds = newValue > 0
            }
        }
}
