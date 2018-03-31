//
//  habitInfoVC.swift
//  Habits
//
//  Created by Ahsan Vency on 3/29/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class habitInfoVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var habitPic: UIImageView!
    
    @IBOutlet weak var habitNameLbl: UILabel!
    @IBOutlet weak var scrollInfo: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var chosenHabit: Habit!
    var whySlide: whySlide!
    var whereSlide: whereSlide!
    var whenSlide: whenSlide!
    var basicRewardsSlide: basicRewardsSlide!
    var intRewardsSlide: intRewardsSlide!
    var advRewardsSlide: advRewardsSlide!
    var confirmSlide: confirmSlide!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    func upAlert (messages: String) {
        let myAlert = UIAlertController(title: "Alert", message: messages, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func createSlides() -> [UIView]{
        whySlide = Bundle.main.loadNibNamed("whySlide", owner: self, options: nil)!.first as! whySlide
        whySlide.intrinsicLabel.text = "Did you know intrinsic reasons like \(chosenHabit.intrinsicReason) help you succeed?"
        whySlide.questionLabel.text = "Why do you want to start \(chosenHabit.habitName)?"
        
        whereSlide = Bundle.main.loadNibNamed("whereSlide", owner: self, options: nil)!.first as! whereSlide
        whereSlide.questionLabel.text = "Where is a consistent location you can \(chosenHabit.habitVerb)?"
        
        whenSlide = Bundle.main.loadNibNamed("whenSlide", owner: self, options: nil)!.first as! whenSlide
        whenSlide.questionLabel.text = "When can you consistently \(chosenHabit.habitVerb)?"
        
        basicRewardsSlide = Bundle.main.loadNibNamed("basicRewardsSlide", owner: self, options: nil)!.first as! basicRewardsSlide
        
        intRewardsSlide = Bundle.main.loadNibNamed("intRewardsSlide", owner: self, options: nil)!.first as! intRewardsSlide
        
        advRewardsSlide = Bundle.main.loadNibNamed("advRewardsSlide", owner: self, options: nil)!.first as! advRewardsSlide
        
        confirmSlide = Bundle.main.loadNibNamed("confirmSlide", owner: self, options: nil)!.first as! confirmSlide
        
        return [whySlide, whereSlide, whenSlide, basicRewardsSlide, intRewardsSlide, advRewardsSlide, confirmSlide]
    }
    
    func setupscrollInfo(Slides:[UIView]){
        scrollInfo.frame = CGRect(x: 0, y: 0, width: scrollInfo.frame.width, height: scrollInfo.frame.height)
        scrollInfo.contentSize = CGSize(width: scrollInfo.frame.width * CGFloat(Slides.count), height: scrollInfo.frame.height)
        scrollInfo.isPagingEnabled = true
        
        for i in 0..<Slides.count{
            Slides[i].frame = CGRect(x: scrollInfo.frame.width * CGFloat(i) , y: 0, width: scrollInfo.frame.width, height: scrollInfo.frame.height)
            scrollInfo.addSubview(Slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/scrollInfo.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    
    @IBAction func confirmHabit(_ sender: Any) {
        whenSlide.save()
        
        if Auth.auth().currentUser?.uid != nil {
            
            //checks to see if txtFeilds are empty
            let valid = validateTextFeilds()
            if valid == true{
                
                //database instance
                var ref: DatabaseReference!
                ref = Database.database().reference()
                
                //current user
                guard let user = Auth.auth().currentUser else {
                    return
                }
                let uid = user.uid
                
                //getting key of habits list
                let habitRefKey = ref.child("Users").child(uid).child("Habits").childByAutoId().key
                //Values to add to Habits list
                let childUpdates = ["/Users/\(uid)/Habits/\(habitRefKey)": chosenHabit.habitName]
                ref.updateChildValues(childUpdates)
                //Adding Habit to Habits node
                //This is where the information on the label needs to be changed
                DataService.ds.REF_HABITS.child(uid).removeValue()
                
                DataService.ds.REF_HABITS.child(uid).child(habitRefKey).setValue(["Why": whySlide.whyField.text,"When":"\(whenSlide.daysOfWeekStr)\(whenSlide.timeStr)","Where":whereSlide.whereField.text,"name":chosenHabit.habitName,"freq":whenSlide.weekArray])
                //Adding rewards to habit
                DataService.ds.REF_HABITS.child(uid).child(habitRefKey).child("Rewards").setValue(["basicReward1":basicRewardsSlide.basicField1.text,"basicReward2":basicRewardsSlide.basicField2.text,"intReward1":intRewardsSlide.intField1.text,"intReward2":intRewardsSlide.intField2.text,"Adv":advRewardsSlide.advField.text, "Success": 0])
                
                //Segue
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainScreenViewCID") as! MainScreenViewC
                newViewController.firstTimeLoaded = 1;
                self.present(newViewController, animated: true){
                }
            } else {
                print("error")
            }
        }
    }
    
    func validateTextFeilds() -> Bool{
        if (whySlide.whyField.text == "") {
            //handel the errors properly
            self.upAlert(messages: "Please fill out Why.")
            return false
        }
        else if (whereSlide.whereField.text == ""){
            
            self.upAlert(messages: "Please fill out Where.")
            return false
        }
        else if (whenSlide.daysOfWeekStr == "" || whenSlide.timeStr == ""){
            
            self.upAlert(messages: "Please fill out When.")
            return false
        }
        else if (basicRewardsSlide.basicField1.text == "Tap to pick a basic reward." || basicRewardsSlide.basicField1.text == "" || basicRewardsSlide.basicField1.text == "Enter Custom Reward Above" || basicRewardsSlide.basicField2.text == "Tap to pick a basic reward." || basicRewardsSlide.basicField2.text == "" || basicRewardsSlide.basicField2.text == "Enter Custom Reward Above"){
            
            self.upAlert(messages: "Please enter Basic Rewards")
            return false
        }
        else if (intRewardsSlide.intField1.text == "Tap to pick an intermediate reward." || intRewardsSlide.intField1.text == "" || intRewardsSlide.intField1.text == "Enter Custom Reward Above" || intRewardsSlide.intField2.text == "Tap to pick an intermediate reward." || intRewardsSlide.intField2.text == "" || intRewardsSlide.intField2.text == "Enter Custom Reward Above"){
            
            self.upAlert(messages: "Please enter Intermediate Rewards")
            return false
        }
        else if (advRewardsSlide.advField.text == "Tap to pick an advanced reward." || advRewardsSlide.advField.text == "" || advRewardsSlide.advField.text == "Enter Custom Rewards Above"){
            
            self.upAlert(messages: "Please enter an Advanced Reward")
            return false
        }
        else {
            print("GOOD")
        }
        return true
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    func setupScreen(){
        habitPic.image = UIImage(named: "\(chosenHabit.habitName) Blue")
        habitNameLbl.text = chosenHabit.habitName
        //habitPic.image = UIImage(named: "Running")
        scrollInfo.delegate = self
        let Slides:[UIView] = createSlides()
        setupscrollInfo(Slides: Slides)
        pageControl.numberOfPages = Slides.count
        pageControl.currentPage = 0
        pageControl.tintColor = blueColor
        scrollInfo.layer.cornerRadius = 10.0
        view.bringSubview(toFront: pageControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
}