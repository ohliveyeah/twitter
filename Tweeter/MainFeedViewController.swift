//
//  MainFeedViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class MainFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tweets: [Tweet] = []
    var limit = 20
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        TwitterClient.sharedInstance.homeTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            for tweet in tweets {
                print(tweet.favoritesCount)
            }
            self.tableView.reloadData()
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return tweets.count
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var indexPath: NSIndexPath
        let vc = segue.destinationViewController as! TweetDetailsViewController
        indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
        
        let tweet = tweets[indexPath.row]
        vc.idString = tweet.tweetID
        
        vc.favoritesNumber = "\(tweet.favoritesCount)"
        vc.nameString = tweet.author?.name
        vc.retweetNumber = "\(tweet.retweetCount)"
        vc.screennameString = "@\(tweet.author!.screenname!)"
        vc.tweetText = tweet.text
        vc.user = tweet.author
        
        
        let profilePicURL = tweet.author?.profileURL
        let imageRequest = NSURLRequest(URL: profilePicURL!)
        
        vc.imageRequest = imageRequest
        vc.profileURL = profilePicURL
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    @IBAction func didTapRetweet(sender: AnyObject) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! TweetTableViewCell
    
        TwitterClient.sharedInstance.retweet(cell.idString!)
        TwitterClient.sharedInstance.homeTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })

    }
    
    @IBAction func didTapFavorite(sender: AnyObject) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! TweetTableViewCell
        
        TwitterClient.sharedInstance.favorite(cell.idString!)
        
        TwitterClient.sharedInstance.homeTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
        
    }
    
}
