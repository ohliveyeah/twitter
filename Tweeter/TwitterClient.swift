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
        
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
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
        let translatedStatus = statusString.stringByReplacingOccurrencesOfString(" ", withString: "%20")

        POST("1.1/statuses/update.json?status=\(translatedStatus)", parameters: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            print("successfully posted")
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
}
