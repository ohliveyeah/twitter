//
//  LoginViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapLogin(sender: AnyObject) {
        let client = TwitterClient.sharedInstance
        client.login({
            print("Successfully logged in")
            self.performSegueWithIdentifier("loginSegue", sender: nil)
            }, failure: { (error: NSError) -> Void in
                print("Error\(error.localizedDescription)")
        })
    }
}
