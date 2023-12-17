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
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Saved", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithDeleteOption(message: String, recipeID: String) {
        let alert = UIAlertController(title: "Saved", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            // Handle delete option
            self?.deleteSavedRecipe(recipeID: recipeID)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteSavedRecipe(recipeID: String) {
        guard let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID") else {
            return
        }

        Firestore.firestore().collection("users/\(currentUserDocumentID)/savedRecipes")
                .whereField("recipeID", isEqualTo: recipeID)
                .getDocuments { [weak self] (snapshot, error) in
                    if let error = error {
                        print("Error getting saved recipe document: \(error)")
                    } else if let document = snapshot?.documents.first {
                        let documentID = document.documentID
                        Firestore.firestore().collection("users/\(currentUserDocumentID)/savedRecipes").document(documentID).delete { error in
                            if let error = error {
                                print("Error deleting saved recipe document: \(error)")
                            } else {
                                self?.showAlert(message: "Recipe deleted successfully!")
                            }
                        }
                    }
        }
    }
    
    func validateSavedRecipe(recipeID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let savedRef = Firestore.firestore().collection("users/\(userID)/savedRecipes").whereField("recipeID", isEqualTo: recipeID)

        savedRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting saved recipe document: \(error)")
                completion(false)
            } else if snapshot?.isEmpty == false {
                // Recipe is already saved
                completion(true)
            } else {
                // Recipe is not saved
                completion(false)
            }
        }
    }
    
    @IBAction func SavedRecipe(_ sender: Any) {
        if let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID"), let recipeID = recipe?.documentID{
//            saveRecipeForCurrentUser(recipeID: recipeID, userID: currentUserDocumentID)
            
            validateSavedRecipe(recipeID: recipe!.documentID, userID: currentUserDocumentID) { [weak self] isSaved in
                    if isSaved {
                        self?.showAlertWithDeleteOption(message: "Recipe is already saved. Do you want to delete it?", recipeID: self?.recipe?.documentID ?? "")
                    } else {
                        self?.saveRecipeForCurrentUser(recipeID: self?.recipe?.documentID ?? "", userID: currentUserDocumentID)
                        self?.showAlert(message: "Recipe saved successfully!")
                        if let bookmarkVC = self?.storyboard?.instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController {
                            print("masuk validasi bookmark")
                            bookmarkVC.selectedRecipe = self?.recipe
            //                        navigationController?.pushViewController(bookmarkVC, animated: true)
                        }
                    }
                }
            
//            print("masuk sini ga sih")
//            if let bookmarkVC = storyboard?.instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController {
//                print("masuk validasi bookmark")
//                        bookmarkVC.selectedRecipe = recipe
////                        navigationController?.pushViewController(bookmarkVC, animated: true)
//            }
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
