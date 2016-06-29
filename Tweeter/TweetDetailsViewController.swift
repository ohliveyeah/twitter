//
//  TweetDetailsViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/28/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var idString: String?
    var nameString: String?
    var screennameString: String?
    var tweetText: String?
    var retweetNumber: String?
    var favoritesNumber: String?
    var timestampString: String?
    var profileURL: NSURL?
    var imageRequest: NSURLRequest?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = nameString
        screennameLabel.text = screennameString
        tweetLabel.text = tweetText
        retweetLabel.text = retweetNumber
        favoritesLabel.text = favoritesNumber
        timestampLabel.text = timestampString
        
                profilePicture.setImageWithURLRequest(
                    imageRequest!,
                    placeholderImage: nil,
                    success: { (imageRequest, imageResponse, image) -> Void in
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            self.profilePicture.alpha = 0.0
                            self.profilePicture.image = image
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.profilePicture.alpha = 1.0
                            })
                        } else {
                            self.profilePicture.image = image
                        }
                    }, failure: { (imageRequest, imageResponse, error) -> Void in
                        print(error.localizedDescription)
                })
        
               profilePicture.setImageWithURL(profileURL!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(idString!)
    }
    
    @IBAction func onTapFavorite(sender: AnyObject) {
        TwitterClient.sharedInstance.favorite(idString!)
    }
    
    @IBAction func onTapBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ProfileView") {
            let vc = segue.destinationViewController as! OtherProfileViewController
            vc.user = self.user
        }
    }
}
