//
//  RecipeTableViewCell.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 05/12/23.
//

import UIKit

protocol RecipeTableViewCellDelegate: AnyObject {
    func didTapGoToDetail(recipe: recipeModel, indexpath: IndexPath)
}

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var LogoFlavorFlip: UIImageView!
    
    @IBOutlet weak var RecipePhotos: UIImageView!
    
    @IBOutlet weak var RecipeTItleLabel: UILabel!
    
    @IBOutlet weak var ChefLabel: UILabel!
    
    var recipe: recipeModel?
    
    // Menambahkan delegate untuk memberi tahu HomeViewController saat tombol diklik
    weak var delegate: RecipeTableViewCellDelegate?
    var indexPath: IndexPath?
    
 
    @IBAction func GoToDetail(_ sender: Any) {
        // Memastikan delegate tidak nil dan mengirim data resep dan indexParh
        if let recipe = recipe, let indexPath = indexPath {
            delegate?.didTapGoToDetail(recipe: recipe, indexpath: indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
