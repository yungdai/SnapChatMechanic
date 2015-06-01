//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBAction func submitButton(sender: AnyObject) {
        
        // log in user
        PFUser.logInWithUsernameInBackground(self.username.text, password: "password") { (user: PFUser?, error:NSError?) -> Void in
            if user != nil {
                println("user is loggged in")
                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                println("log in failed")
                // setup a new user
                var user = PFUser()
                user.username = self.username.text
                user.password = "password"
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        println("signed up")
                    } else  {
                        println(error)
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    func checkForMessages() {
        
    }

    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




