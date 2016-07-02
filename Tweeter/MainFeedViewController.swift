//
//  MainFeedViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class MainFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var tweets: [Tweet] = []
    //var limit = 20
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)

        
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
        cell.setCell(tweet)
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
        vc.favorited = tweet.favorited
        vc.retweeted = tweet.retweeted
        
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
        cell.retweetImage.image = UIImage(named: "retweet-action-on")
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
        
        if (!(tweets[(indexPath?.row)!].favorited)) {
            TwitterClient.sharedInstance.favorite(cell.idString!)
            cell.favoriteImage.image = UIImage(named: "like-action-on")
        }
        else {
            TwitterClient.sharedInstance.unfavorite(cell.idString!)
            cell.favoriteImage.image = UIImage(named: "like-action")
        }
        
        TwitterClient.sharedInstance.homeTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                print("Loading data!!")
                loadMoreData()
            }
            
        }
    }
    
    func loadMoreData() {
        
        if (!isMoreDataLoading) {
            isMoreDataLoading = true
            let currentTweet = tweets[tweets.count - 1]
            let idString = currentTweet.tweetID
            //print(idString)
            TwitterClient.sharedInstance.homeTimelineSinceID (idString!, success: { (tweets: [Tweet]) in
                self.isMoreDataLoading = false
                self.tweets.appendContentsOf(tweets)
                self.tableView.reloadData()
                }, failure: { (error: NSError) -> () in
                    self.isMoreDataLoading = false
                    print (error.localizedDescription)
            })
        }
    }
    
}
