//
//  ProfileViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/28/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverPhoto: UIImageView!
    
    @IBAction func didTapCompose(sender: AnyObject) {
        
    }
    
    
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
        //var currentUser: User?
        TwitterClient.sharedInstance.currentAccount({ (userParem: User) in
            self.setProfileUser(userParem)
            self.nameLabel.text = self.user!.name
            self.screennameLabel.text = self.user!.screenname
            self.taglineLabel.text = self.user!.tagline
            self.tweetsLabel.text = String(self.user!.statusesCount)
            self.followersLabel.text = String(self.user!.followersCount)
            self.followingLabel.text = String(self.user!.friendsCount)
            
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
                        
                        if (self.user!.coverPhotoUsed) {
                            let coverPhotoURL = self.user!.coverURL
                            if let coverPhotoURL = coverPhotoURL {
                                let secondImageRequest = NSURLRequest(URL: coverPhotoURL)
                                self.coverPhoto.setImageWithURLRequest(secondImageRequest, placeholderImage: nil, success: { (secondImageRequest, secondImageResponse, image) -> Void in
                                    if secondImageResponse != nil {
                                        self.coverPhoto.alpha = 0.0
                                        self.coverPhoto.image = image
                                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                                            self.coverPhoto.alpha = 1.0
                                        })
                                    } else {
                                        self.coverPhoto.image = image
                                    }}, failure: { (imageRequest, imageResponse, error) -> Void in
                                        print(error.localizedDescription)
                                        
                                })
                            } else {
                                self.coverPhoto.hidden = true
                                
                            }
                        } else {
                            
                            self.coverPhoto.hidden = true
                        }
                        }, failure: { (error: NSError) -> () in
                            print (error.localizedDescription)
                    })
                }, failure: { (imageRequest, imageResponse, error) -> Void in
                    print(error.localizedDescription)
            })
            
            // self.profilePicture.setImageWithURL(self.profileURL!)
            
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func setProfileUser(userParem: User) {
        user = userParem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetTableViewCell
        let tweet = tweets[indexPath.row]
       cell.setCell(tweet)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return tweets.count
    }
    
    
    
}
