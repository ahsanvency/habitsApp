//
//  basicRewardPopupVC.swift
//  Habits
//
//  Created by Ahsan Vency on 2/19/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit

class basicRewardPopupVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
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
    
    
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var basicField1: fancyField!
    @IBOutlet weak var basicPicker1: UIPickerView!
    @IBOutlet weak var basicField2: fancyField!
    @IBOutlet weak var basicPicker2: UIPickerView!
    
    
    var listOfBasicRewards1 = ["Chocolate", "Candy", "Sweet Drink", "Posting a Selfie", "Watch a Youtube Video", "Cheese and Crackers", "Light Candles"]
    
    var listOfBasicRewards2 = ["Chocolate", "Candy", "Sweet Drink", "Posting a Selfie", "Watch a Youtube Video", "Cheese and Crackers", "Light Candles"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = listOfBasicRewards1[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Avenir Next", size: 15.0)!,NSAttributedStringKey.foregroundColor:blueColor])
        return myTitle
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        var countRow : Int = listOfBasicRewards1.count
        
        if pickerView == basicPicker2{
            countRow = listOfBasicRewards2.count
        }
        
        return countRow
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == basicPicker1{
            let reward = listOfBasicRewards1[row]
            return reward
        }else if pickerView == basicPicker2{
            let reward = listOfBasicRewards2[row]
            return reward
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == basicPicker1{

            basicReward1 = self.listOfBasicRewards1[row]
    
            if basicReward1 == "Enter Custom Reward Above"{
                self.basicField1.becomeFirstResponder()
            }
            self.basicField1.text = basicReward1
            self.basicPicker1.isHidden = true
            self.basicField2.isHidden = false
            self.basicField2.isEnabled = true
            
        }
        else if pickerView == basicPicker2{
            
            basicReward2 = self.listOfBasicRewards2[row]
            
            if basicReward2 == "Enter Custom Reward Above"{
                self.basicField2.becomeFirstResponder()
            }
            self.basicField2.text = basicReward2
            self.basicPicker2.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.basicField1{
            
            self.basicField2.isHidden = true
            basicField2.isEnabled = false

            if basicReward1 != "Enter Custom Reward Above"{
                self.basicPicker1.isHidden = false
                textField.endEditing(true)
            }
            
        }
        if textField == self.basicField2{
            
            basicField1.isEnabled = true
            
            if basicReward2 != "Enter Custom Reward Above" {
                self.basicPicker2.isHidden = false
                textField.endEditing(true)
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.basicField1 {
            basicReward1 = textField.text
        }
        if textField == self.basicField2{
            basicReward2 = textField.text
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.basicField1.endEditing(true)
        self.basicField2.endEditing(true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        if basicField1.text != "Tap to pick a basic reward." && basicField2.text != "Tap to pick a basic reward." && basicField1.text != "Enter Custom Reward Above" && basicField2.text != "Enter Custom Reward Above"{
            basicReward1 = basicField1.text
            basicReward2 = basicField2.text
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let basicRewardInfo = storyBoard.instantiateViewController(withIdentifier: "NewHabitVCID") as! NewHabitVC
            basicRewardInfo.whyLblText = whyLblText!
            basicRewardInfo.weekArray = weekArray
            basicRewardInfo.whenLblText = whenLblText!
            basicRewardInfo.whereLblText = whereLblText!
            basicRewardInfo.basicStr = "\(basicReward1!) or \(basicReward2!)"
            basicRewardInfo.basicReward1 = basicReward1!
            basicRewardInfo.basicReward2 = basicReward2!
            basicRewardInfo.intStr = intStr!
            basicRewardInfo.intReward1 = intReward1!
            basicRewardInfo.intReward2 = intReward2!
            basicRewardInfo.advStr = advStr!
            basicRewardInfo.currentText = currentText!
            self.present(basicRewardInfo,animated: true, completion: nil)
        }else{
            self.upAlert(messages: "Please enter both rewards.")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupScreen(){
        basicField1.text = "Tap to pick a basic reward."
        basicField2.text = "Tap to pick a basic reward."
        listOfBasicRewards1.sort()
        listOfBasicRewards2.sort()
        listOfBasicRewards1.append("Enter Custom Reward Above")
        listOfBasicRewards2.append("Enter Custom Reward Above")
        let myGradient = UIImage(named: "textBasicRewards.png")
        screenTitle.textColor = UIColor(patternImage: myGradient ?? UIImage())
    }
    
    func upAlert (messages: String) {
        let myAlert = UIAlertController(title: "Alert", message: messages, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
}