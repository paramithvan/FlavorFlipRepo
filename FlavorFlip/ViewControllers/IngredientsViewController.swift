//
//  IngredientsViewController.swift
//  FlavorFlip
//
//  Created by Yonathan Handoyo on 10/12/23.
//

import UIKit

class IngredientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var recipe: recipeModel?
    var arrOfSection = ["Ingredients", "Equipment"]
    var selectedIngredientIndex: IndexPath?
    
    
    @IBOutlet weak var ingredientPortion: UILabel!
    @IBOutlet weak var ingredientTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let recipe = recipe{
            // Lakukan konfigurasi UI atau operasi lainnya berdasarkan data recipe di sini
            print("Recipe Name: \(String(describing: recipe.ingredients))")
        }
        
        ingredientTableView.dataSource = self
        ingredientTableView.delegate = self
        
        ingredientTableView.reloadData()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 { // Ingredients section
            return recipe?.ingredients?.count ?? 0
        } else { // Equipment section
            return recipe?.equipment?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell") as! IngredientsTableViewCell
        
        if indexPath.section == 0{
            if let ingredients = recipe?.ingredients, indexPath.row < ingredients.count {
                cell.ingredientName.text = ingredients[indexPath.row]
            } else {
                cell.ingredientName.text = "No ingredient"
            }
        }else{
            if let equipment = recipe?.equipment, indexPath.row < equipment.count {
                cell.ingredientName.text = equipment[indexPath.row]
            } else {
                cell.ingredientName.text = "No equipment"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrOfSection.count
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrOfSection[section]
    }

}
