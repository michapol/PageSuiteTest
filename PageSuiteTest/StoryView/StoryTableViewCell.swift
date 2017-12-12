//
//  StoryTableViewCell.swift
//  PageSuiteTest
//
//  Created by Mike Pollard on 07/12/2017.
//  Copyright © 2017 Mike Pollard. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
    
    var cellIndex = 0

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var favorite: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
