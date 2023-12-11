//
//  StepsTableViewCell.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit

class StepsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var stepVideo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
