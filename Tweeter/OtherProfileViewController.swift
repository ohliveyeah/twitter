//
//  OtherProfileViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/29/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class OtherProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var tweetsNumberLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    
    var user: User?
    var tagline: String?
    var name: String?
    var screenname: String?
    var profileURL: NSURL?
    var imageRequest: NSURLRequest?
    var tweetsCount = 0
    var followersCount = 0
    var followingCount = 0
    var tweets: [Tweet] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.setProfileUser(user)
        self.nameLabel.text = self.user!.name
        self.screennameLabel.text = self.user!.screenname
        self.taglineLabel.text = self.user!.tagline
        
        if (self.user!.statusesCount > 1000) {
            let shortTweetsCount = (self.user!.statusesCount) / 1000
            self.tweetsNumberLabel.text = "\(shortTweetsCount)k"
        }
        else {
            self.tweetsNumberLabel.text = String(self.user!.statusesCount)
        }
        
        if (self.user!.followersCount > 1000000) {
            let shortFollowersCount = (self.user!.followersCount) / 1000000
            self.followersLabel.text = "\(shortFollowersCount)M"
            print("Holy cow!")
        }
        else if (self.user!.followersCount > 1000) {
            let shortFollowersCount = (self.user!.followersCount) / 1000
            self.followersLabel.text = "\(shortFollowersCount)k"
            print("That's a lot")
        }
        else {
             self.followersLabel.text = String(self.user!.followersCount)
        }

        if (self.user!.friendsCount > 1000000) {
            let shortFollowersCount = (self.user!.friendsCount) / 1000000
            self.followingLabel.text = "\(shortFollowersCount)M"
            print("Holy cow!")
        }
        else if (self.user!.friendsCount > 1000) {
            let shortFollowersCount = (self.user!.friendsCount) / 1000
            self.followingLabel.text = "\(shortFollowersCount)k"
            print("That's a lot")
        }
        else {
            self.followingLabel.text = String(self.user!.friendsCount)
        }
        
        let profilePicURL = self.user!.profileURL
        let imageRequest = NSURLRequest(URL: profilePicURL!)
        
        self.profilePicture.setImageWithURLRequest(
            imageRequest,
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
                
                TwitterClient.sharedInstance.userTimeline (self.user!, success: {
                    (tweets: [Tweet]) in
                    self.tweets = tweets
                    self.tableView.reloadData()
                    
                    
                    
                    }, failure: { (error: NSError) -> () in
                        print (error.localizedDescription)
                })
                
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                print(error.localizedDescription)
        })
        
    }
    
    @IBAction func didTapBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetTableViewCell
        let tweet = tweets[indexPath.row]
        cell.idString = tweet.tweetID
        cell.tweetLabel.text = tweet.text
        cell.timestampLabel.text = tweet.timestampText
        cell.usernameLabel.text = "@\(tweet.username!)"
        cell.retweetLabel.text = String(tweet.retweetCount)
        cell.favoriteLabel.text = String(tweet.favoritesCount)
        cell.nameLabel.text = tweet.name!
        
        let profilePicURL = tweet.author?.profileURL
        let imageRequest = NSURLRequest(URL: profilePicURL!)
        
        cell.profilePic.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.profilePic.alpha = 0.0
                    cell.profilePic.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.profilePic.alpha = 1.0
                    })
                } else {
                    cell.profilePic.image = image
                }
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                print(error.localizedDescription)
        })
        
        cell.profilePic.setImageWithURL(profilePicURL!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return tweets.count
    }
}
