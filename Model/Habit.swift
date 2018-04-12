//
//  Habit.swift
//  Habits
//
//  Created by Ahsan Vency on 1/5/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import Foundation
import UIKit

class Habit{
    private var _habitName: String!
    private var _habitPic: UIImage!
    private var _intrinsicReason: String!
    private var _habitVerb: String!
    
    private var _why: String!
    private var _when: String!
    private var _whhere: String!
    
    
//    init(habitName: String) {
//        _habitName = habitName;
//    }
    
    init(habitName: String, habitPic: UIImage, intrinsicReason: String, habitVerb: String) {
        _habitName = habitName;
        _habitPic = habitPic;
        _intrinsicReason = intrinsicReason;
        _habitVerb = habitVerb
    }
    
    
    init(habitName: String, habitPic: UIImage, intrinsicReason: String, habitVerb: String, why: String, when: String, whhere: String) {
        _habitName = habitName;
        _habitPic = habitPic;
        _intrinsicReason = intrinsicReason;
        _habitVerb = habitVerb
        _why = why;
        _when = when;
        _whhere = whhere;
    }
    
//    init(habitName: String, habitPic: UIImage, why: String, when: String, whhere: String) {
//        _habitName = habitName;
//        _habitPic = habitPic;
//        _why = why;
//        _when = when;
//        _whhere = whhere;
//    }
    
    var habitName: String{
        get{
            return _habitName;
        }
        set{
            _habitName = newValue;
        }
    }
    
    var habitPic: UIImage{
        get{
            return _habitPic;
        }
        set{
            _habitPic = newValue;
        }
    }
    
    var intrinsicReason: String{
        get{
            return _intrinsicReason;
        }
        set{
            _intrinsicReason = newValue;
        }
    }
    
    var habitVerb: String{
        get{
            return _habitVerb;
        }
        set{
            _habitVerb = newValue;
        }
    }
    
    
    var why: String {
        get{
            return _why;
        }
        set{
            _why = newValue;
        }
    }
    
    var when: String{
        get {
            return _when;
        }
        set{
            _when = newValue;
        }
    }
    
    var whhere: String{
        get{
            return _whhere
        }
        set{
            _whhere = newValue;
        }
    }
    
}




