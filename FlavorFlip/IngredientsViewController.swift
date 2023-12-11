//
//  IngredientsViewController.swift
//  FlavorFlip
//
//  Created by Yonathan Handoyo on 10/12/23.
//

import UIKit

class IngredientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe?.ingredients?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell") as! IngredientsTableViewCell
//        cell.delegate
//        cell.ingredientImage.image =
        if let row = recipe?.ingredients, indexPath.row < row.count{
            cell.ingredientName.text = row[indexPath.row]
        }
        else{
            cell.ingredientName.text = "gada"
        }
        
        
//        print(recipe?.ingredients![indexPath.row])
        
        return cell
    }
    
    var recipe: recipeModel?
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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
