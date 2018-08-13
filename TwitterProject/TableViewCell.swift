//
//  TableViewswift
//  TwitterProject
//
//  Created by Huan CAO on 7/10/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scNameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userscNameLabel: UILabel!
    @IBOutlet weak var usertweetsLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var likeUserButton: UIButton!
    @IBOutlet weak var retweetUserButton: UIButton!
    
    @IBOutlet weak var likeHomeButton: UIButton!
    @IBOutlet weak var retweetHomeButton: UIButton!
    
    @IBOutlet weak var imageHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImgHeightLayoutConstraint: NSLayoutConstraint!
    
    var id: String = ""
    var indexPath: IndexPath!
    var onTapMoreButton: ((_ id: String) -> Void)?
    
    var onTapLikeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapRetweetButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapLikeHomeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapRetweetHomeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateUI(tweet: TweetData, indexPath: IndexPath) {
        self.indexPath = indexPath
        let profileUrlImage = tweet.profile_image_url
        
        profileImageView.sd_setImage(with: NSURL(string: profileUrlImage)! as URL)
        label.text = tweet.text
        name.text = tweet.name
        scNameLabel.text = tweet.screen_name
        id = tweet.tweetId
        
        if let url = tweet.media_url {
            let imgUrl = NSURL(string: url[0].media_url!)
            imageHeightLayoutConstraint.constant = 131
            imgView.sd_setImage(with: imgUrl! as URL, placeholderImage: UIImage(named: "placeholderImage"))
        } else {
            imgView.image = nil
            imageHeightLayoutConstraint.constant = 0
        }
        
        let likeImg = (tweet.isLiked == "1") ? #imageLiteral(resourceName: "1") : #imageLiteral(resourceName: "11")
        likeHomeButton.setImage(likeImg, for: .normal)
        likeHomeButton.setTitle("\(tweet.favorite_count)", for: .normal)
        
        let retweetImg = (tweet.isRetweeted == "1") ? #imageLiteral(resourceName: "r1") : #imageLiteral(resourceName: "retwIcon")
        retweetHomeButton.setImage(retweetImg, for: .normal)
        retweetHomeButton.setTitle("\(tweet.retweet_count)", for: .normal)
    }
    
    @IBAction func onTapBtn(_ sender: Any) {
        self.onTapMoreButton?(id)
    }
    @IBAction func onTapRetweetBtn(_ sender: Any) {
        self.onTapRetweetButton?(id, retweetUserButton)
    }
    @IBAction func onTapLikeBtn(_ sender: Any) {
        self.onTapLikeButton?(id, likeUserButton)
    }
    @IBAction func onTapLikeHomeBtn(_ sender: Any) {
        self.onTapLikeHomeButton?(id, likeHomeButton)
    }
    @IBAction func onTapRetweetHomeBtn(_ sender: Any) {
        self.onTapRetweetHomeButton?(id, retweetHomeButton)
    }
    
    
}
