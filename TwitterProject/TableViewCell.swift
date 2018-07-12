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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usertweetsLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
