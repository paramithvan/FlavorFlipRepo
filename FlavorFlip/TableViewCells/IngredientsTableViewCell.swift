//
//  IngredientsTableViewCell.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    var recipe: recipeModel?
    
    
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var ingredientName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
