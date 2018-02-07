//
//  rewardsVC.swift
//  rewardsScreen
//
//  Created by Ahsan Vency on 1/26/18.
//  Copyright © 2018 Ahsan Vency. All rights reserved.


import UIKit
import Foundation
import Firebase

class rewardsVC: UIViewController {
    
    //Variables
    var blinkDuration = 1.0
    var blinkIsOn = false
    var spinFast = 0.01;
    var spinMedium = 0.075;
    var spinSlow = 0.1;
    var isSpinning = false
    var stoppedLeft: Int?
    
    struct slotComp{
        var image: UIImage!
        var reward: String!
    }
    
    var items = [slotComp]()
    
    //Timers
    var timerLeft = Timer()
    var timerMiddle = Timer()
    var timerRight = Timer()
    var timerGetReadyForNextSpin = Timer()
    var timerWin = Timer()
    var timerUpAlert = Timer()
    
    //Number of times to spin each column
    var numberOfTimesSpinLeft: Int!
    var numberOfTimesSpinMiddle: Int!
    var numberOfTimesSpinRight: Int!
    
    //Tracks how many times it currenly spun
    var leftCurrentSpinCount = 0
    var middleCurrentSpinCount = 0
    var rightCurrentSpinCount = 0
    
    //The value that was ultimately selected
    var selectedItemLeft: Int!
    var selectedItemMiddle: Int!
    var selectedItemRight: Int!
    
    //Other Outlets
    @IBOutlet weak var spinBtn: UIButton!
    @IBOutlet weak var slotsView: UIView!
    
    
    
    
    //Left Column
    @IBOutlet weak var left1Top: UIImageView!
    @IBOutlet weak var left1Bottom: UIImageView!
    @IBOutlet weak var left2Top: UIImageView!
    @IBOutlet weak var left2Bottom: UIImageView!
    @IBOutlet weak var left3Top: UIImageView!
    @IBOutlet weak var left3Bottom: UIImageView!
    
    //middle Column
    @IBOutlet weak var middle1Top: UIImageView!
    @IBOutlet weak var middle1Bottom: UIImageView!
    @IBOutlet weak var middle2Top: UIImageView!
    @IBOutlet weak var middle2Bottom: UIImageView!
    @IBOutlet weak var middle3Top: UIImageView!
    @IBOutlet weak var middle3Bottom: UIImageView!
    
    //right Column
    @IBOutlet weak var right1Top: UIImageView!
    @IBOutlet weak var right1Bottom: UIImageView!
    @IBOutlet weak var right2Top: UIImageView!
    @IBOutlet weak var right2Bottom: UIImageView!
    @IBOutlet weak var right3Top: UIImageView!
    @IBOutlet weak var right3Bottom: UIImageView!
    
    
    let oneTop = slotComp(image: UIImage(named: "topBlue7"), reward: "basic")
    let oneBottom = slotComp(image: UIImage(named: "bottomBlue7"), reward: "basic")
    let twoTop = slotComp(image: UIImage(named: "twoTop"), reward: "intermediate")
    let twoBottom = slotComp(image: UIImage(named: "twoBottom"), reward: "intermediate")
    let threeTop = slotComp(image: UIImage(named: "threeTop"), reward: "advanced")
    let threeBottom = slotComp(image: UIImage(named: "threeBottom"), reward: "advanced")
    let whiteTop = slotComp(image: nil, reward: "nil")
    let whiteBottom = slotComp(image: nil, reward: "nil")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layerTop: CALayer = CALayer()
        layerTop.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0).cgColor //Background color of the view added
        layerTop.position = CGPoint(x: slotsView.bounds.width / 2, y:  -slotsView.bounds.height / 2 + 162) //position of the added view
        layerTop.bounds = CGRect(x: 0, y: 0, width: slotsView.bounds.width, height: 2) //creates a rectange for the added view
        layerTop.shadowColor = UIColor.black.cgColor //shadow color
        layerTop.shadowOffset = CGSize(width: 0,height: 8) //size of the shadow offset
        layerTop.shadowOpacity = 1 //opacity
        layerTop.shadowRadius = 8 //radius of the offset
        //higher radius means more of a gradient
        //Lower radius means a darker shadow
        
        let layerBottom: CALayer = CALayer()
        layerBottom.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0).cgColor
        layerBottom.position = CGPoint(x: slotsView.bounds.width / 2, y: 329)
        layerBottom.bounds = CGRect(x: 0, y: 0, width: slotsView.bounds.width, height: 2)
        layerBottom.shadowColor = UIColor.black.cgColor
        layerBottom.shadowOffset = CGSize(width: 0,height: 5)
        layerBottom.shadowOpacity = 1
        layerBottom.shadowRadius = 8
        let degrees = 180.0
        let radians = CGFloat(degrees * Double.pi / 180)
        layerBottom.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        
        slotsView.layer.addSublayer(layerTop)
        slotsView.layer.addSublayer(layerBottom)
        
        items = [oneTop, oneBottom, whiteTop, whiteBottom, twoTop, twoBottom, oneTop, oneBottom, whiteTop, whiteBottom, oneTop, oneBottom, whiteTop, whiteBottom, threeTop, threeBottom, whiteTop, whiteBottom, twoTop, twoBottom, whiteTop, whiteBottom, oneTop, oneBottom, twoTop, twoBottom, whiteTop, whiteBottom, oneTop, oneBottom]
        
        isSpinning = false
        selectedItemLeft = 1
        selectedItemMiddle = 1
        selectedItemRight = 1
        
        //UNCOMMENT
        rotateitems(index: selectedItemLeft, columnIndex: 1)
        rotateitems(index: selectedItemMiddle, columnIndex: 2)
        rotateitems(index: selectedItemRight, columnIndex: 3)
    }
    
    var canRun = true
    func updateSuccess(){
        //current user
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        //Gets the Habit id
        DataService.ds.REF_HABITS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //getting habit key
            guard let firstKey = value?.allKeys[0] else {
                print("n")
                return }
            
            let firstDict = value![firstKey] as! Dictionary<String,Any>
            
            var rewardsDict = firstDict["Rewards"] as? Dictionary<String, Any>
            var success = rewardsDict!["Success"] as? Int
            
            let time = Date.init()
            let calender = Calendar.current
            let components = calender.dateComponents([.day], from: time)
            guard let day = components.day else
            {   print("error")
                return
            }
            
            if let prevSpunDay = rewardsDict!["SpunDay"] as? Int{
                
                if prevSpunDay == day {
                    //alert
                    let spinAlert = UIAlertController(title: "Alert", message: "Can only play once a day", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in})
                    spinAlert.addAction(okAction)
                    self.present(spinAlert, animated: true, completion: nil)

                } else {
                    success = success! + 1
                    DataService.ds.REF_HABITS.child(uid).child("\(firstKey)").child("Rewards").updateChildValues(["Success": success!,"SpunDay":day])
                    self.runSpin()
                }
                
            } else {
                success = success! + 1
                DataService.ds.REF_HABITS.child(uid).child("\(firstKey)").child("Rewards").updateChildValues(["Success": success!,"SpunDay":day])
                self.runSpin()
            }
            
            
            
        })
        
        
        
        
    }
    
    func runSpin(){
    
        spinBtn.setTitle("Good Luck", for: UIControlState.normal)
        isSpinning = true
        spinBtn.isEnabled = false
        prepareNextSpin()
        //print("SelectedLeft: \(selectedItemLeft!)")
        //print("SpinLeft: \(numberOfTimesSpinLeft!)")
        timerLeft = Timer.scheduledTimer(timeInterval: spinFast, target:self, selector: #selector(updateLeft), userInfo: nil, repeats: true)
        timerMiddle = Timer.scheduledTimer(timeInterval: spinFast, target:self, selector: #selector(updateMiddle), userInfo: nil, repeats: true)
        timerRight = Timer.scheduledTimer(timeInterval: spinFast, target:self, selector: #selector(updateRight), userInfo: nil, repeats: true)
    
    }
    
    @IBAction func spinButton(_ sender: Any) {
        
        if (isSpinning){
            return
        }
        
        updateSuccess()
        

    }
    
    func prepareNextSpin(){
        //can eventually delete these to replace it with returnStop in the functions below
        let stopLeft = returnStop()
        let stopMiddle = returnStop()
        let stopRight = returnStop()
        
//        let stopLeft = 17
//        let stopMiddle = 17
//        let stopRight = 17
        
        
        //Generates the number of times for each column to spin
        numberOfTimesSpinLeft = 60 * Int(arc4random_uniform(UInt32(3))+2) + stopLeft - selectedItemLeft
        if numberOfTimesSpinLeft%2 == 1{
            numberOfTimesSpinLeft = numberOfTimesSpinLeft + 1
        }
        numberOfTimesSpinMiddle = 60 * Int(arc4random_uniform(UInt32(3))+2) + stopMiddle - selectedItemMiddle
        if numberOfTimesSpinMiddle%2 == 1{
            numberOfTimesSpinMiddle = numberOfTimesSpinMiddle + 1
        }
        numberOfTimesSpinRight = 60 * Int(arc4random_uniform(UInt32(3))+2) + stopRight - selectedItemRight
        if numberOfTimesSpinRight%2 == 1{
            numberOfTimesSpinRight = numberOfTimesSpinRight + 1
        }
        
        leftCurrentSpinCount = 0;
        middleCurrentSpinCount = 0;
        rightCurrentSpinCount = 0;
        blinkDuration = 1.0;
    }
    
    @objc func updateLeft(){
        if (isSpinning) == false{
            return
        }
        leftCurrentSpinCount = leftCurrentSpinCount + 1
        if (leftCurrentSpinCount <= numberOfTimesSpinLeft){
            selectedItemLeft = selectedItemLeft - 1
            if selectedItemLeft == -1 {
                selectedItemLeft = 29
            }
            rotateitems(index: selectedItemLeft, columnIndex: 1)
        }
        if Double(leftCurrentSpinCount) > Double(numberOfTimesSpinLeft) / 1.2{
            timerLeft.invalidate()
            timerLeft = Timer.scheduledTimer(timeInterval: spinSlow, target:self, selector: #selector(updateLeft), userInfo: nil, repeats: true)
        }
        if leftCurrentSpinCount >= numberOfTimesSpinLeft{
            timerLeft.invalidate()
        }
        
        if leftCurrentSpinCount >= numberOfTimesSpinLeft && middleCurrentSpinCount >= numberOfTimesSpinMiddle && rightCurrentSpinCount >= numberOfTimesSpinRight {
            checkRewards()
        }
    }
    
    @objc func updateMiddle(){
        if (isSpinning) == false{
            return
        }
        middleCurrentSpinCount = middleCurrentSpinCount + 1
        
        if (middleCurrentSpinCount <= numberOfTimesSpinMiddle){
            selectedItemMiddle = selectedItemMiddle - 1
            if selectedItemMiddle == -1 {
                selectedItemMiddle = 29
            }
            rotateitems(index: selectedItemMiddle, columnIndex: 2)
        }
        if Double(middleCurrentSpinCount) > Double(numberOfTimesSpinMiddle) / 1.2{
            timerMiddle.invalidate()
            timerMiddle = Timer.scheduledTimer(timeInterval: spinSlow, target:self, selector: #selector(updateMiddle), userInfo: nil, repeats: true)
        }
        
        if middleCurrentSpinCount >= numberOfTimesSpinMiddle{
            timerMiddle.invalidate()
        }
        
        if leftCurrentSpinCount >= numberOfTimesSpinLeft && middleCurrentSpinCount >= numberOfTimesSpinMiddle && rightCurrentSpinCount >= numberOfTimesSpinRight {
            checkRewards()
        }
    }
    
    @objc func updateRight(){
        if (isSpinning) == false{
            return
        }
        
        rightCurrentSpinCount = rightCurrentSpinCount + 1
        
        if (rightCurrentSpinCount <= numberOfTimesSpinRight){
            selectedItemRight = selectedItemRight - 1
            if selectedItemRight == -1 {
                selectedItemRight = 29
            }
            rotateitems(index: selectedItemRight, columnIndex: 3)
        }
        
        if Double(rightCurrentSpinCount) > Double(numberOfTimesSpinRight) / 1.2{
            timerRight.invalidate()
            timerRight = Timer.scheduledTimer(timeInterval: spinSlow, target:self, selector: #selector(updateRight), userInfo: nil, repeats: true)
        }
        if rightCurrentSpinCount >= numberOfTimesSpinRight{
            timerRight.invalidate()
        }
        
        if leftCurrentSpinCount >= numberOfTimesSpinLeft && middleCurrentSpinCount >= numberOfTimesSpinMiddle && rightCurrentSpinCount >= numberOfTimesSpinRight {
            timerRight.invalidate()
            checkRewards()
        }
    }
    
    func rotateitems(index: Int, columnIndex: Int){
        var imageTop1: UIImageView
        var imageBottom1: UIImageView
        var imageTop2: UIImageView
        var imageBottom2: UIImageView
        var imageTop3: UIImageView
        var imageBottom3: UIImageView
        
        switch (columnIndex){
        case 1:
            imageTop1 = left1Top
            imageBottom1 = left1Bottom
            imageTop2 = left2Top
            imageBottom2 = left2Bottom
            imageTop3 = left3Top
            imageBottom3 = left3Bottom
        case 2:
            imageTop1 = middle1Top
            imageBottom1 = middle1Bottom
            imageTop2 = middle2Top
            imageBottom2 = middle2Bottom
            imageTop3 = middle3Top
            imageBottom3 = middle3Bottom
        case 3:
            imageTop1 = right1Top
            imageBottom1 = right1Bottom
            imageTop2 = right2Top
            imageBottom2 = right2Bottom
            imageTop3 = right3Top
            imageBottom3 = right3Bottom
        default:
            imageTop1 = left1Top
            imageBottom1 = left1Bottom
            imageTop2 = left2Top
            imageBottom2 = left2Bottom
            imageTop3 = left3Top
            imageBottom3 = left3Bottom
        }
        
        
        var index1Top = index - 3
        if index1Top == -3{
            index1Top = 27
        }else if index1Top == -2{
            index1Top = 28
        }else if index1Top == -1{
            index1Top = 29
        }
        
        var index1Bottom = index - 2
        if index1Bottom == -2{
            index1Bottom = 28
        }else if index1Bottom == -1{
            index1Bottom = 29
        }
        
        var index2Top = index - 1
        if index2Top == -1{
            index2Top = 29
        }
        
        let index2Bottom = index
        
        var index3Top = index + 1
        if index3Top == 30{
            index3Top = 0
        }
        
        
        var index3Bottom = index + 2
        if index3Bottom == 31{
            index3Bottom = 1
        }else if index3Bottom == 30{
            index3Bottom = 0
        }
        
        imageTop1.image = items[index1Top].image
        imageBottom1.image = items[index1Bottom].image
        imageTop2.image = items[index2Top].image
        imageBottom2.image = items[index2Bottom].image
        imageTop3.image = items[index3Top].image
        imageBottom3.image = items[index3Bottom].image
    }
    
    func checkRewards(){
        let leftCheck = items[selectedItemLeft].reward
        let middleCheck = items[selectedItemMiddle].reward
        let rightCheck = items[selectedItemRight].reward
        
        
        //current user
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        
        //Gets the Habit id
        DataService.ds.REF_HABITS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //getting habit key
            guard let firstKey = value?.allKeys[0] else {
                print("n")
                return }
            
            let firstDict = value![firstKey] as! Dictionary<String,Any>
            
            var rewardsDict = firstDict["Rewards"] as? Dictionary<String, Any>
            let basicMessage = "Good effort have earned: \(rewardsDict!["Basic"]!)"
            let intMessage = "Congratulations you have earned: \(rewardsDict!["Int"]!)"
            let advMessage = "You really deserve this: \(rewardsDict!["Adv"]!)"
            
            if leftCheck == "basic" && middleCheck == "basic" && rightCheck == "basic"{
                self.winner()
                self.upAlert(messages: basicMessage)
            }
            else if ((leftCheck == "basic" && middleCheck == "basic") || (leftCheck == "basic" && rightCheck == "basic") || (middleCheck == "basic" && rightCheck == "basic")) && (leftCheck == "intermediate" || middleCheck == "intermediate" || rightCheck == "intermediate" || leftCheck == "advanced" || middleCheck == "advanced" || rightCheck == "advanced"){
                self.winner()
                self.upAlert(messages: basicMessage)
            }
            else if leftCheck == "intermediate" && middleCheck == "intermediate" && rightCheck == "intermediate"{
                self.winner()
                self.upAlert(messages: intMessage)
            }
            else if ((leftCheck == "intermediate" && middleCheck == "intermediate") || (middleCheck == "intermediate" && rightCheck == "intermediate") || (leftCheck == "intermediate" && rightCheck == "intermediate")) && (leftCheck == "basic" || middleCheck == "basic" || rightCheck == "basic" || leftCheck == "advanced" || middleCheck == "advanced" || rightCheck == "advanced"){
                self.winner()
                self.upAlert(messages: intMessage)
            }
            else if leftCheck == "advanced" && middleCheck == "advanced" && rightCheck == "advanced"{
                
                self.winner()
                self.upAlert(messages: advMessage)
            }
            else {
                self.getReadyForNextSpin()
            }
        })
    }
    
    @objc func getReadyForNextSpin(){
        isSpinning = false
        spinBtn.setTitle("SPIN", for: UIControlState.normal)
        spinBtn.isEnabled = true
        spinBtn.backgroundColor = UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1.0)
        timerGetReadyForNextSpin.invalidate()
    }
    
    func startBlinking(){
        timerWin = Timer.scheduledTimer(timeInterval: blinkDuration, target:self, selector: #selector(Blink), userInfo: nil, repeats: true)
    }
    
    //This code can stay relatively similar because of the changes
    @objc func Blink(){
        blinkDuration = blinkDuration - 0.15
        if blinkDuration <= 0 {
            timerWin.invalidate()
            //let image = items[selectedItemLeft].image
            left2Top.image = items[selectedItemLeft - 1].image
            middle2Top.image = items[selectedItemMiddle - 1].image
            right2Top.image = items[selectedItemRight - 1].image
            left2Bottom.image = items[selectedItemLeft].image
            middle2Bottom.image = items[selectedItemMiddle].image
            right2Bottom.image = items[selectedItemRight].image
            
        }else{
            blinkIsOn = !blinkIsOn
            if blinkIsOn{
                //let imageName = ""
                left2Top.image = nil
                middle2Top.image = nil
                right2Top.image = nil
                left2Bottom.image = nil
                middle2Bottom.image = nil
                right2Bottom.image = nil
            }else{
                left2Top.image = items[selectedItemLeft - 1].image
                middle2Top.image = items[selectedItemMiddle - 1].image
                right2Top.image = items[selectedItemRight - 1].image
                left2Bottom.image = items[selectedItemLeft].image
                middle2Bottom.image = items[selectedItemMiddle].image
                right2Bottom.image = items[selectedItemRight].image
            }
        }
    }
    
    func returnStop() -> Int{
        let rand = Int(arc4random_uniform(UInt32(105)))
        var stop = 0;
        
        switch rand {
        case 0..<10:
            stop = 0
        case 10..<12:
            stop = 1
        case 13..<20:
            stop = 2
        case 20..<30:
            stop = 3
        case 30..<34:
            stop = 4
        case 34..<45:
            stop = 5
        case 45..<53:
            stop = 6
        case 53..<58:
            stop = 7
        case 58..<66:
            stop = 8
        case 66..<73:
            stop = 9
        case 73..<76:
            stop = 10
        case 76..<86:
            stop = 11
        case 86..<92:
            stop = 12
        case 92..<96:
            stop = 13
        default:
            stop = 14
        }
        return stop * 2;
    }
    
    func winner(){
        spinBtn.setTitle("WINNER", for: UIControlState.normal)
        spinBtn.backgroundColor = UIColor.green
        startBlinking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.timerGetReadyForNextSpin = Timer.scheduledTimer(timeInterval: 3.0, target:self, selector: #selector(self.getReadyForNextSpin), userInfo: nil, repeats: false)
        })
    }
    
    func upAlert (messages: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            let myAlert = UIAlertController(title: "Alert", message: messages, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let whenView = storyBoard.instantiateViewController(withIdentifier: "MainScreenViewCID") as! MainScreenViewC
        self.present(whenView,animated: true, completion: nil)
    }
    
    
    
}



