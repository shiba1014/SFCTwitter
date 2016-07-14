//
//  TweetCell.swift
//  SFCtwitter
//
//  Created by Paul McCartney on 2016/07/12.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet var usernameLabel: UILabel?
    @IBOutlet var userIdLabel: UILabel?
    @IBOutlet var profileImageView: UIImageView?
    @IBOutlet var tweetLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
