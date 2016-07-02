//
//  TweetTableViewCell.swift
//  Tweeter
//
//  Created by Olivia Gregory on 6/27/16.
//  Copyright © 2016 Olivia Gregory. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    //@IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var retweetImage: UIImageView!
    @IBOutlet weak var favoriteImage: UIImageView!
    var idString: String?
    @IBOutlet weak var tweetView: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(tweet: Tweet) {
        idString = tweet.tweetID
        tweetView.text = tweet.text
        timestampLabel.text = tweet.timestampText
        usernameLabel.text = "@\(tweet.username!)"
        retweetLabel.text = String(tweet.retweetCount)
        favoriteLabel.text = String(tweet.favoritesCount)
        nameLabel.text = tweet.name!
        
        if (tweet.favorited) {
            favoriteImage.image = UIImage(named: "like-action-on")
        }
        if (tweet.retweeted) {
            retweetImage.image = UIImage(named: "retweet-action-on")
        }
        
        let profilePicURL = tweet.author?.profileURL
        let imageRequest = NSURLRequest(URL: profilePicURL!)
        
      profilePic.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    
                    self.profilePic.alpha = 0.0
                    self.profilePic.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.profilePic.alpha = 1.0
                    })
                } else {
                    self.profilePic.image = image
                }
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                print(error.localizedDescription)
        })
        profilePic.setImageWithURL(profilePicURL!)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
