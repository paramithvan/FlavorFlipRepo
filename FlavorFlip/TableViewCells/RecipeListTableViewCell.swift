//
//  RecipeListTableViewCell.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 18/12/23.
//

import UIKit

class RecipeListTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var recipeImages: UIImageView!
    
    @IBOutlet weak var recipeTitle: UILabel!
    
    @IBOutlet weak var chefName: UILabel!
    
    @IBOutlet weak var DetailButton: UIButton!
    
    @IBAction func DetailButton(_ sender: Any) {
        // Memastikan delegate tidak nil dan mengirim data resep dan indexParh
        if let recipe = recipe, let indexPath = indexPath {
            delegate?.didTapGoToDetail(recipe: recipe, indexpath: indexPath)
        }
    }
    
    var recipe: recipeModel?
    
    // Menambahkan delegate untuk memberi tahu HomeViewController saat tombol diklik
    weak var delegate: RecipesTableViewDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol RecipesTableViewDelegate: AnyObject {
    func didTapGoToDetail(recipe: recipeModel, indexpath: IndexPath)
}

