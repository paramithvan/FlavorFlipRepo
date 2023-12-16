//
//  DetailRecipeViewController.swift
//  FlavorFlip
//
//  Created by Yonathan Handoyo on 07/12/23.
//

import UIKit
import FirebaseFirestore

class DetailRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var recipe: recipeModel?
    var selectedRecipeIndex: IndexPath?
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var chefImage: UIImageView!
    @IBOutlet weak var chefName: UILabel!
    
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var timeDetail: UILabel!
    @IBOutlet weak var levelDetail: UILabel!
    @IBOutlet weak var portionDetail: UILabel!
    
    @IBOutlet var recipeDescription: UILabel!
    @IBOutlet weak var stepsList: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToIngredients", let destinationVC = segue.destination as? IngredientsViewController, let recipe = sender as? recipeModel {
                destinationVC.recipe = recipe
                print(recipe)
                destinationVC.selectedIngredientIndex = selectedRecipeIndex
        }
    }
    
    @IBAction func GoToIngredients(_ sender: Any) {
        performSegue(withIdentifier: "goToIngredients", sender: recipe)
    }
    
    @IBAction func SavedRecipe(_ sender: Any) {
        if let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID"), let recipeID = recipe?.documentID{
            saveRecipeForCurrentUser(recipeID: recipeID, userID: currentUserDocumentID)
            
            if let bookmarkVC = storyboard?.instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController {
                        bookmarkVC.selectedRecipe = recipe
                        navigationController?.pushViewController(bookmarkVC, animated: true)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Selected Recipe Index: \(String(describing: selectedRecipeIndex))")
        
        stepsList.dataSource = self
        stepsList.delegate = self
        
        if let recipe = recipe {
            chefName.text = recipe.creator
            recipeTitle.text = recipe.name
            recipeDescription.text = recipe.description
            timeDetail.text = recipe.time
            levelDetail.text = recipe.level
            
            
            if let imageURLString = recipe.imagePotrait, let imageURL = URL(string: imageURLString) {
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let error = error {
                    print("Error mengunduh gambar: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                        print("Gagal membuat gambar dari data")
                        return
                    }

                    DispatchQueue.main.async { [self] in
                        recipeImage.image = image
                    }

                }.resume()
            } else {
                print("URL gambar tidak valid")
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe?.steps?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as! StepsTableViewCell
        
        // Periksa apakah recipe dan steps tidak nil, dan indexPath.row adalah indeks yang valid
        if let steps = recipe?.steps, indexPath.row < steps.count {
            cell.stepsLabel.text = steps[indexPath.row]
        } else {
            cell.textLabel?.text = "Langkah tidak valid"
        }
        return cell
    }

    
    func saveRecipeForCurrentUser(recipeID: String, userID: String){
        let savedRef = Firestore.firestore().collection("users/\(userID)/savedRecipes")
        print("current userID : \(userID)")
        
        savedRef.addDocument(data: ["userID" : userID, "recipeID" : recipeID]){ error in
            if let error = error {
                        print("Error saving recipe: \(error)")
                    } else {
                        print("Recipe successfully saved for the current user.")
                    }
        }
    }
    
    
    
}
