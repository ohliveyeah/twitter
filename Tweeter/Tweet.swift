//
//  Tweet.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text : String?
    var timestamp : NSDate?
    var retweetCount = 0
    var favoritesCount = 0
    var username : String?
    var name: String?
    var author: User?
    var timestampText: String?
    var tweetID: String?
    var retweeted = false
    var favorited = false
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        author = User.init(dictionary: dictionary["user"]! as! NSDictionary)
        username = author!.screenname
        name = author!.name
        tweetID = dictionary["id_str"] as? String
        retweeted = (dictionary["retweeted"] as? Bool)!
        favorited = (dictionary["favorited"] as? Bool)!
        
        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.currentLocale()
            
            //timestamp = dictionary["created_at"] as? String
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            let convertedDate = timestamp?.timeIntervalSinceNow
            let newDate = convertedDate! * -1
            var finalDate = Int(newDate)
            if finalDate > 3600 {
                finalDate = finalDate / 3600
                timestampText = "\(finalDate)h"
            }
            else if finalDate > 60 {
                finalDate = finalDate / 60
                timestampText = "\(finalDate)m"
            }
            else {
                timestampText = "\(finalDate)s"
            }
            
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
