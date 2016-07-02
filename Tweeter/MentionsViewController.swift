//
//  MentionsViewController.swift
//  Tweeter
//
//  Created by Olivia Gregory on 7/1/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class MentionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
    TwitterClient.sharedInstance.mentionsTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
        print(self.tweets)
            self.tableView.reloadData()
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
        print(self.tweets)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.mentionsTimeLine({ (tweets: [Tweet]) in
            self.tweets = tweets
            for tweet in tweets {
                print(tweet.favoritesCount)
            }
            self.tableView.reloadData()
            }, failure: { (error: NSError) -> () in
                print (error.localizedDescription)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("called cell for row")
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
