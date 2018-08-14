//
//  newTableViewCell.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/31/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import UIKit

class newTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var folowingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var profileEditButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(data: UserInformation?) {
        let bannerUrl = data?.profile_banner_url
        bannerImageView.sd_setImage(with: NSURL(string: bannerUrl!)! as URL, completed: nil)
        avatarImageView.sd_setImage(with: NSURL(string: (data?.profile_image_url)!)! as URL, completed: nil)
        nameLabel.text = data?.name
        screenNameLabel.text = "@" + (data?.screen_name)!
        folowingLabel.text = "\(data?.friends_count ?? 0)"
        followersLabel.text = "\(data?.followers_count ?? 0)"
    }
}


