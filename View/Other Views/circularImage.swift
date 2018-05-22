//
//  circularImage.swift
//  Habits
//
//  Created by Ahsan Vency on 4/20/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import Foundation
import UIKit

//Makes the image view on the menu a circular image
class circularImage: UIImageView{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
        
    }
}

