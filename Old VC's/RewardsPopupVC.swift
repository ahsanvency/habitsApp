//
//  ViewController.swift
//  Habits
//
//  Created by Ahsan Vency on 1/29/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit

class rewardsPopupVC: UIViewController, UITextViewDelegate {

    var basicStr: String = ""
    var intStr: String = ""
    var advStr: String = ""
    
    var weekArray = [Int]()
    var habitName: String?
    var whyLblText: String = ""
    var whenLblText:String = ""
    var whereLblText:String = ""
    var currentText:String = ""

    var basicReward1: String?
    var basicReward2: String?
    
    var intReward1: String?
    var intReward2: String?
    
    @IBOutlet weak var basicText: UITextView!
    @IBOutlet weak var intText: UITextView!
    @IBOutlet weak var advText: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var screenTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveBtn(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let backView = storyBoard.instantiateViewController(withIdentifier: "NewHabitVCID") as! NewHabitVC
        backView.whereLblText = whereLblText
        backView.weekArray = weekArray
        backView.whyLblText = whyLblText
        backView.whenLblText = whenLblText
        backView.basicStr = basicText.text
        backView.basicReward1 = basicReward1!
        backView.basicReward2 = basicReward2!
        backView.intStr = intText.text
        backView.intReward1 = intReward1!
        backView.intReward2 = intReward2!
        backView.advStr = advText.text
        backView.currentText = currentText
        self.present(backView, animated: true) {
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == self.basicText {
            self.basicText.becomeFirstResponder()
            scrollDown(y: 593)
        }else if textView == self.intText {
            self.intText.becomeFirstResponder()
            scrollDown(y: 293)
        }else{
            self.advText.becomeFirstResponder()
            scrollDown(y: -7)
        }
    }
    
    func scrollDown(y: CGFloat){
    DispatchQueue.main.async(execute: {
    self.scrollView.setContentOffset(CGPoint(x: 0,y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height - y), animated: true)
    })
    }
    
    func setupScreen(){
        let myGradient = UIImage(named: "textRewardsPopup.png")
        screenTitle.textColor = UIColor(patternImage: myGradient ?? UIImage())
        basicText.backgroundColor = satinColor
        basicText.textColor = maroonColor
        intText.backgroundColor = satinColor
        intText.textColor = maroonColor
        advText.backgroundColor = satinColor
        advText.textColor = maroonColor
    }
}