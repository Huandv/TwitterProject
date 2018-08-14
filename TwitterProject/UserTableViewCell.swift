//
//  UserTableViewCell.swift
//  TwitterProject
//
//  Created by Huan CAO on 8/13/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userscreennameLabel: UILabel!
    @IBOutlet weak var usertweetsLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLikeButton: UIButton!
    @IBOutlet weak var userRetweetButton: UIButton!
    @IBOutlet weak var userImgHeightLayoutConstraint: NSLayoutConstraint!
    
    var id: String = ""
    var onTapMoreButton: ((_ id: String) -> Void)?
    
    var onTapLikeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapRetweetButton: ((_ id: String, _ button: UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImageView.layer.borderWidth = 1.0
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width/2
        userProfileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateUI(tweet: TweetData, indexPath: IndexPath) {
        let userProfileUrl = tweet.profile_image_url
        userProfileImageView.sd_setImage(with: NSURL(string: userProfileUrl)! as URL)
        usernameLabel.text = tweet.name
        userscreennameLabel.text = tweet.screen_name
        usertweetsLabel.text = tweet.text
        id = tweet.tweetId
        
        if let url = tweet.media_url {
            let imgUrl = NSURL(string: url[0].media_url!)
            userImgHeightLayoutConstraint.constant = 131
            userImageView.sd_setImage(with: imgUrl! as URL, placeholderImage: UIImage(named: "placeholderImage"))
        } else {
            userImageView.image = nil
            userImgHeightLayoutConstraint.constant = 0
        }
        
        let likeImg = (tweet.isLiked == 1) ? #imageLiteral(resourceName: "1") : #imageLiteral(resourceName: "11")
        userLikeButton.setImage(likeImg, for: .normal)
        userLikeButton.setTitle("\(tweet.favorite_count)", for: .normal)
        
        let retweetImg = (tweet.isRetweeted == 1) ? #imageLiteral(resourceName: "r1") : #imageLiteral(resourceName: "retwIcon")
        userRetweetButton.setImage(retweetImg, for: .normal)
        userRetweetButton.setTitle("\(tweet.retweet_count)", for: .normal)
        
    }
    
    @IBAction func onTapBtn(_ sender: Any) {
        self.onTapMoreButton?(id)
    }
    
    @IBAction func onTapLikeBtn(_ sender: Any) {
        self.onTapLikeButton?(id, userLikeButton)
    }
    
    @IBAction func onTapRetweetBtn(_ sender: Any) {
        self.onTapRetweetButton?(id, userRetweetButton)
    }
}
