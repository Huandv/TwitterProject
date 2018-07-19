//
//  TableViewCell.swift
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
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userscNameLabel: UILabel!
    
    @IBOutlet weak var usertweetsLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var likeUserButton: UIButton!
    @IBOutlet weak var retweetUserButton: UIButton!
    
    @IBOutlet weak var likeHomeButton: UIButton!
    @IBOutlet weak var retweetHomeButton: UIButton!
    
    
    var id: String = ""
    var onTapMoreButton: ((_ id: String) -> Void)?
    
    var onTapLikeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapRetweetButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapLikeHomeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    var onTapRetweetHomeButton: ((_ id: String, _ button: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
