//
//  satinButton.swift
//  Habits
//
//  Created by Ahsan Vency on 2/18/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit

class satinButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor;
        layer.borderColor = seaFoamColor.cgColor
        layer.borderWidth = 2.0
        layer.shadowOpacity = 0.8;
        layer.shadowRadius = 5.0;
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
        layer.cornerRadius = 5.0;
        layer.masksToBounds = true;
        backgroundColor = satinColor
        setTitleColor(blueColor, for: .normal)
    }
    
}