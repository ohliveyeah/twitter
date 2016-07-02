//
//  PostViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/29/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var tweetTextField: UITextField!
    var maxLength = 140
    var currentLength = 0
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.hidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapTweet(sender: AnyObject) {
        if (tweetTextField.text?.characters.count > 140) {
            warningLabel.hidden = false
        }
        else {
        TwitterClient.sharedInstance.composeTweet(tweetTextField.text!)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func didTypeStatus(sender: AnyObject) {
        warningLabel.hidden = true
        currentLength = (tweetTextField.text?.characters.count)!
        var charactersLeft = maxLength - currentLength
        counterLabel.text = "\(charactersLeft) Left"
        if (charactersLeft < 0) {
            tweetTextField.deleteBackward()
        }
    }

}
