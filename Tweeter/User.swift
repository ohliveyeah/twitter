//
//  User.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileURL: NSURL?
    var tagline: String?
    var followersCount = 0
    var friendsCount = 0
    var location: String?
    var statusesCount = 0
    var coverURL: NSURL?
    var coverPhotoUsed = true
    
    var dictionary: NSDictionary?
      static let userDidLogoutNotification = "UserDidLogout"
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        friendsCount = (dictionary["friends_count"] as? Int) ?? 0
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        location = dictionary["location"] as? String
        statusesCount = (dictionary["statuses_count"] as? Int) ?? 0
        
        var profileURLString = dictionary["profile_image_url_https"] as? String
        

        if let profileURLString = profileURLString {
            let newProfileURLString = profileURLString.stringByReplacingOccurrencesOfString("_normal", withString: "")
            profileURL = NSURL(string: newProfileURLString)
        }
        
        coverPhotoUsed = (dictionary["profile_use_background_image"]?.boolValue)!
        
        var coverURLString = dictionary["profile_banner_url"] as? String
        
        if let coverURLString = coverURLString {
            let newCoverURLString = coverURLString.stringByReplacingOccurrencesOfString("_normal", withString: "")
            coverURL = NSURL(string: coverURLString)
        }
    }
    
        static var _currentUser: User?
        
        class var currentUser: User? {
            get {
                if _currentUser == nil {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    let userData = defaults.objectForKey("currentUserData") as? NSData
                    if let userData = userData {
                        let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    }
                }
                return _currentUser
            }
            set(user) {
                _currentUser = user
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if let user = user {
                    let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                    defaults.setObject(data, forKey: "currentUserData")
                }
                else {
                    defaults.setObject(nil, forKey: "currentUserData")
                }
                defaults.synchronize()
            }
        }
}
