//
//  whereAddPopupVC.swift
//  Habits
//
//  Created by Ahsan Vency on 1/21/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit

class whereAddPopupVC: UIViewController {
    
    var habitRow: Int?
    var habitName: String?
    var whyLblText: String?
    var weekArray = [Int]()
    var whenLblText:String?
    var whereLblText:String?
    var currentText:String?
    
    var basicStr: String?
    var intStr: String?
    var advStr: String?
    
    var basicReward1: String?
    var basicReward2: String?
    
    var intReward1: String?
    var intReward2: String?
    
    @IBOutlet weak var whereText: fancyField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var screenTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whereText.textColor = maroonColor
        let myGradient = UIImage(named: "textWherePopup.png")
        screenTitle.textColor = UIColor(patternImage: myGradient ?? UIImage())
        
        questionLabel.text = "Where is a consistent location you can \(String(describing: habitName!))"
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let whereView = storyBoard.instantiateViewController(withIdentifier: "NewHabitVCID") as! NewHabitVC
        whereView.whereLblText = whereText.text!
        whereView.weekArray = weekArray
        whereView.whyLblText = whyLblText!
        whereView.whenLblText = whenLblText!
        whereView.basicStr = basicStr!
        whereView.basicReward1 = basicReward1!
        whereView.basicReward2 = basicReward2!
        whereView.intStr = intStr!
        whereView.intReward1 = intReward1!
        whereView.intReward2 = intReward2!
        whereView.advStr = advStr!
        whereView.currentText = currentText!
        whereView.editButtonPressed = 1
        self.present(whereView,animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let whereView = storyBoard.instantiateViewController(withIdentifier: "NewHabitVCID") as! NewHabitVC
            whereView.weekArray = self.weekArray
            whereView.whyLblText = self.whyLblText!
            whereView.whenLblText = self.whenLblText!
            whereView.basicStr = self.basicStr!
            whereView.basicReward1 = self.basicReward1!
            whereView.basicReward2 = self.basicReward2!
            whereView.intStr = self.intStr!
            whereView.intReward1 = self.intReward1!
            whereView.intReward2 = self.intReward2!
            whereView.advStr = self.advStr!
            whereView.currentText = self.currentText!
            whereView.editButtonPressed = 0
            self.present(whereView, animated: true, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= (keyboardSize.height - 125)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += (keyboardSize.height - 125)
            }
        }
    }
    
}
