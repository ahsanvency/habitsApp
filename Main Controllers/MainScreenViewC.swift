//
//  MainScreenViewC.swift
//  Habits
//
//  Created by Ahsan Vency on 1/4/18.
//  Copyright © 2018 ahsan vency. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import UserNotifications

class MainScreenViewC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var animationLabel: UILabel!
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var fakeLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    
    
    var intrinsicQuestions = [String]()
    var randomPopupNumber = 7
    var firstTimeLoaded: Int?
    let userDefault = UserDefaults.standard
    var habitName: String?
    
    override func viewDidAppear(_ animated: Bool) {

        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.notif()

        }
        runAnimation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingScreen()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
        }
        
        
        //title
        let myGradient = UIImage(named: "textMainScreen.png")
        screenTitle.textColor = UIColor(patternImage: myGradient ?? UIImage())
        
        guard let user = Auth.auth().currentUser else {
            print("User not found")
            return
        }
        let uid = user.uid
        DataService.ds.REF_HABITS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            //getting habit key
//            guard let firstKey = value?.allKeys[0] else{
            guard (value?.allKeys[0]) != nil else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "pickHabitVCID") as! pickHabitVC
                self.present(newViewController, animated: true, completion: nil)
                return
            }
        })

    }

    func showLoadingScreen(){
        loadingView.bounds.size.width = view.bounds.width
        loadingView.bounds.size.height = view.bounds.height
        loadingView.center = view.center
        loadingView.alpha = 1.0
        view.addSubview(loadingView)
        
        
        UIView.animate(withDuration: 1, delay: 0.7, options: [], animations: {
            self.loadingView.alpha = 0
        }) { (success) in
            
        }
    }
    
    func runAnimation(){
        userDefault.bool(forKey: "animationDone")
//        if (animationDone == false) {
        if firstTimeLoaded == 1{
            self.animationLabel.isHidden = false
            UIView.animate(withDuration: 0.75, delay: 0, options: [], animations: {
                self.tableView.frame.origin.x -= 75
                self.fakeView.frame.origin.x -= 75
            }, completion: { _ in
                UIView.animate(withDuration: 0.75, delay: 0.3, options: [], animations: {
                    self.tableView.frame.origin.x += 75
                    self.fakeView.frame.origin.x += 75
                }, completion: { _ in
                })
            })
            UIView.animate(withDuration: 0.75, delay: 1.05, options: [], animations: {
                self.animationLabel.alpha = 0
            }, completion: { _ in
                self.animationLabel.isHidden = true
            })
            userDefault.set(true, forKey: "animationDone")
        }else {
            self.animationLabel.isHidden = true
        }
    }
    //To start there will only be one habit
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath) as? HabitCell{
            return cell;
        }
        
        return HabitCell();
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rewardsAction = UITableViewRowAction(style: .normal, title: "Rewards") { (action, index) in
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
                let success = rewardsDict!["Success"] as? Int

                
                switch (success!){
                case 5..<10:
                    self.randomPopupNumber = 5;
                case 10..<20:
                    self.randomPopupNumber = 3;
                case 20..<31:
                    self.randomPopupNumber = 2;
                default:
                    self.randomPopupNumber = 10;
                    break;
                }
                self.habitName = (firstDict["name"] as! String)
                
                self.intrinsicQuestions = ["How are you progressing with \(self.habitName!)?",
                    "Why do you want to cself.ontinue \(self.habitName!)?",
                    "How does \(self.habitName!) relate to your values?",
                    "What do you gain by \(self.habitName!)?"]
                
                let test = Int(arc4random_uniform(UInt32(self.randomPopupNumber)))
                if test == 0 {
                    let intrinsicAlert = UIAlertController(title: "Intrinsic Reminder", message: self.intrinsicQuestions[Int(arc4random_uniform(UInt32(self.intrinsicQuestions.count)))], preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                        if let textField = intrinsicAlert.textFields?[0]{
                            if textField.text == ""{
                                self.present(intrinsicAlert, animated: true, completion: nil)
                            } else{
                                self.performSegue(withIdentifier: "toRewardsScreen", sender: self)
                            }
                        }
                         })
                    intrinsicAlert.addAction(okAction)
                    intrinsicAlert.addTextField(configurationHandler: nil)
                    self.present(intrinsicAlert, animated: true, completion: nil)
                }else{
                    self.performSegue(withIdentifier: "toRewardsScreen", sender: nil)
                }
            })
            
        }
        rewardsAction.backgroundColor = blueColor
        return [rewardsAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350;
    }
    
    //This is the menu button thats treated as a logout
    @IBAction func menuAsLogout(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! Auth.auth().signOut()
//        dismiss(animated: true, completion: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginID") as! loginVC
        view.window?.layer.add(bottomTransition(duration: 0.5), forKey: nil)
        self.present(newViewController, animated: false, completion: nil)
    }
    
    
    
    @IBAction func addNewHabitBtn(_ sender: Any) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not found")
            return
        }
        let uid = user.uid

        DataService.ds.REF_HABITS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //getting habit key
            guard let firstKey = value?.allKeys[0] else {
                print("n")
                return }
            
            //using habit key to get dict
            let firstDict = value![firstKey] as! Dictionary<String,Any>
            var rewardsDict = firstDict["Rewards"] as? Dictionary<String, Any>
            var success = rewardsDict!["Success"] as? Double

            //getting dict values and assigning them to labels
            guard let successesInt = success else {
                print("none")
                return
            }
            
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let newViewController = storyBoard.instantiateViewController(withIdentifier: "NewHabitVCID") as! NewHabitVC
//            self.present(newViewController, animated: true, completion: nil)
            
            if successesInt >= 30 {

                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "pickHabitVCID") as! pickHabitVC
                self.present(newViewController, animated: true, completion: nil)


            } else  {
                func alert (messages: String) {
                    let myAlert = UIAlertController(title: "Alert", message: messages, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction: UIAlertAction) in
                    })
                    myAlert.addAction(okAction)
                    self.present(myAlert, animated: true, completion: nil)
                }

                alert(messages: "It's best to do one keystone habit at a time.")
                    //You need to get to 30 days before adding a new habit. You currently have \(Int(successesInt)) days.")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func notif(){
        guard let user = Auth.auth().currentUser else {
            print("User not found")
            return
        }
        let uid = user.uid
        
        DataService.ds.REF_HABITS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            //getting habit key
            guard let firstKey = value?.allKeys[0] else {
                print("n")
                return }
            //using habit key to get dict
            let firstDict = value![firstKey] as! Dictionary<String,Any>
            let fbTime  =  firstDict["When"] as? String
            let fbParseTime = fbTime?.split(separator: " ")//
            let fbLength = fbParseTime?.count
            let fbTimeVal = fbParseTime![fbLength! - 2 ..< fbLength! ]
            var fbTimeArray = [String]()
            var fbNewTime = ""
            for x in fbTimeVal {
                fbTimeArray.append(String(x))
                fbNewTime += x + " "
            }
            //fb values
            guard let currentHabitTimeMin =  Int(fbTimeArray[0].split(separator: ":")[1]) else {
                print("error")
                return
            }
            guard let  currentHabitTimeHours = Int(fbTimeArray[0].split(separator: ":")[0]) else {
                print("error")
                return
            }
            
            print(currentHabitTimeMin)
            print(currentHabitTimeHours)
        //Creates the notification
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
//        content.subtitle = "They are up now"
            content.body = "In one hour its time to \(String(describing: self.habitName))."
        //App icon for the badge
        content.badge = 1
        var date = DateComponents()
        date.hour = currentHabitTimeHours - 1
        date.minute = currentHabitTimeMin
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        //Adds to the notification center which has the job of displaying it
        
        UNUserNotificationCenter.current().add(request) { (error) in
        }
            
            })
    }
}

class CustomProgressView: UIProgressView {
    
    var height:CGFloat = 1.0
    // Do not change this default value,
    // this will create a bug where your progressview wont work for the first x amount of pixel.
    // x being the value you put here.
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size:CGSize = CGSize.init(width: self.frame.size.width, height: height)
        return size
    }
}
