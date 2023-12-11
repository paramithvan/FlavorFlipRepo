//
//  SavedRecipeCollectionViewCell.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit

class SavedRecipeCollectionViewCell: UICollectionViewCell {
    
    var cornerRadius: CGFloat = 5.0
    
    @IBOutlet weak var imageRecipes: UIImageView!
    @IBOutlet weak var TitleLabel: UITextView!
    
    func configure(with image: UIImage, title: String){
        imageRecipes.image = image
        TitleLabel.text = title
    }
    
    override func layoutSubviews() {
           // cell rounded section
           self.layer.cornerRadius = 15.0
           self.layer.borderWidth = 5.0
           self.layer.borderColor = UIColor.clear.cgColor
           self.layer.masksToBounds = true
           
           // cell shadow section
           self.contentView.layer.cornerRadius = 15.0
           self.contentView.layer.borderWidth = 5.0
           self.contentView.layer.borderColor = UIColor.clear.cgColor
           self.contentView.layer.masksToBounds = true
           self.layer.shadowColor = UIColor.black.cgColor
           self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
           self.layer.shadowRadius = 6.0
           self.layer.shadowOpacity = 0.6
           self.layer.cornerRadius = 15.0
           self.layer.masksToBounds = false
           self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
       }
 
}
