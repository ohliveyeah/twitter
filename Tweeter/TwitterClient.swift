//
//  TwitterClient.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "rLjgXxdZX1OQyjwHg9YbpImzE", consumerSecret: "n5vticRJfTVDQs0drieDxVwFH53Xs8T4AX5GaWM7ajlBFevsVu")
    
    func homeTimeLine(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        
        self.printRateStatuses()

        
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as? [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries!)
            
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func homeTimelineSinceID (idString: String, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        
        self.printRateStatuses()
        
        GET("1.1/statuses/home_timeline.json?max_id=\(idString)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as? [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries!)
            
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })

    }
    
    func userTimeline (user: User, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/user_timeline.json?screen_name=\(user.screenname!)", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let dictionaries = response as? [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries!)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error: \(error.localizedDescription)")
                failure(error)
        })

    }
    
    func mentionsTimeLine (success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/mentions_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as? [NSDictionary]
            print(dictionaries)
            let tweets = Tweet.tweetsWithArray(dictionaries!)
            print(tweets)
            success(tweets)
            }, failure:  { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error: \(error.localizedDescription)")
                failure(error)
        })
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as? NSDictionary
            //print(userDictionary)
            let user = User(dictionary: userDictionary!)
            
            success(user)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    var loginSuccess : (() -> ())?
    var loginFailure : ((NSError) -> ())?
    
    func login(success:() -> (), failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "tweeterapp://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            //print("I got a token")
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            
        }) { (error: NSError!) -> Void in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
        
    }
    
    func handleOpenURL (url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: (url.query)!)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken!, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
                }, failure: { (error: NSError) -> () in
                    self.loginFailure?(error)
            })
            self.loginSuccess?()
        })  { (error: NSError!) -> Void in
            print ("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
    }
    
    func composeTweet(statusString: String) {
        //let translatedStatus = statusString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        let parems = ["status" : statusString]
        POST("1.1/statuses/update.json", parameters: parems, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            print("successfully posted")
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print ("error: \(error.localizedDescription)")
            }
        )}
    
    func getTweet (idString: String) {
        GET("1.1/statuses/show.json?id=\(idString)", parameters: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            print("successfully fetched tweet")
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print ("error: \(error.localizedDescription)")
            }
        )}

    func favorite(idString: String) {
        POST("1.1/favorites/create.json?id=\(idString)", parameters: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            print("successfully favorited")
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print ("error: \(error.localizedDescription)")
            }
        )}
    
    func retweet(idString: String) {
        POST("1.1/statuses/retweet/\(idString).json", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            print("successfully retweeted")
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print ("error: \(error.localizedDescription)")
            }
        )}
    
    func unfavorite
        (idString: String) {
        POST("1.1/favorites/destroy.json?id=\(idString)", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            print("successfully unfavorited")
            },  failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print ("error: \(error.localizedDescription)")
            }
        )
    }
    
    func getRateStatuses(handler: ((response: NSDictionary?, error: NSError?) -> Void)) {
        GET("1.1/application/rate_limit_status.json?resources=statuses", parameters:nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                if let dict = response as? NSDictionary {
                    handler(response:dict, error:nil)
                }
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                handler(response:nil, error:error)
        })
    }
    
    func unretweet () {
//        // step 1
//        if tweet.retweeted is false
//        return or error // you cannot unretweet a tweet that has not retweeted
//        else
//        if tweet.retweeted_status is empty
//        let original_tweet_id = tweet.id_str
//        else // tweet was itself a retweet
//        let original_tweet_id = tweet.retweeted_status.id_str
//        
//        // step 2
//        let full_tweet = GET("https://api.twitter.com/1.1/statuses/show/" + original_tweet_id + "json?include_my_retweet=1")
//        let retweet_id = full_tweet.current_user_retweet.id_str
//        
//        // step 3
//        POST("https://api.twitter.com/1.1/statuses/destroy/" + retweet_id + ".json")
    }
    
    private static let ratePrintLabels = [
        "/statuses/home_timeline":"home timeline",
        "/statuses/retweets/:id":"retweet",
        "/statuses/user_timeline":"user timeline"]
    
    func printRateStatuses() {
        self.getRateStatuses { (response, error) in
            if let error = error {
                print("received error getting rate limits")
            }else{
                if let response = response {
                    for (key,value) in TwitterClient.ratePrintLabels {
                        if let resourcesDict = response["resources"] as? NSDictionary {
                            if let statusDict = resourcesDict["statuses"] as? NSDictionary {
                                if let keyDict = statusDict[key] as? NSDictionary {
                                    let limit = keyDict["limit"] as! Int
                                    let remaining = keyDict["remaining"] as! Int
                                    let epoch = keyDict["reset"] as! Int
                                    let resetDate = NSDate(timeIntervalSince1970: Double(epoch))
                                    print("\(value) rate: limit=\(limit), remaining=\(remaining); expires in \(TwitterClient.formatIntervalElapsed(resetDate.timeIntervalSinceNow))")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static var elapsedTimeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    static func formatTimeElapsed(sinceDate: NSDate) -> String {
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }
    
    static func formatIntervalElapsed(interval: NSTimeInterval) -> String {
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }

}
