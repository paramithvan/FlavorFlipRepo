//
//  BookmarkViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit
import FirebaseFirestore

class BookmarkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var savedList: UICollectionView!
    var selectedRecipe: recipeModel?
    var savedRecipes: [recipeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedList.dataSource = self
        savedList.delegate = self
        
        if let selectedRecipe = selectedRecipe {
                   savedRecipes.append(selectedRecipe)
                   savedList.reloadData()
               }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        savedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = savedList.dequeueReusableCell(withReuseIdentifier: "savedCell", for: indexPath) as! SavedRecipeCollectionViewCell
        
        let recipe = savedRecipes[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = savedList.dequeueReusableCell(withReuseIdentifier: "savedCell", for: indexPath) as! SavedRecipeCollectionViewCell
    }
    
    func fetchedSavedRecipes(for userID: String){
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists{
                if let savedRecipeIDs = document.data()?["savedRecipes"] as? [String] {
                    self.fetchRecipeDetails(for: savedRecipeIDs)
                }
            }else{
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchRecipeDetails(for recipeDocumentIDs: [String]){
        for documentID in recipeDocumentIDs{
            let recipeRef = Firestore.firestore().collection("recipes").document(documentID)
            
            recipeRef.getDocument{ document, error in
                if let document = document, document.exists {
                    if let imagePotrait = document.data()?["imagePotrait"] as? String,
                       let name = document.data()?["name"] as? String,
                       let creator = document.data()?["creator"] as? String,
                       let ingredients = document.data()?["ingredients"] as? [String],
                       let steps = document.data()?["Steps"]as? [String]{
                        let recipe = recipeModel(documentID: documentID, imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, steps: steps)
                        // masukin recipe yang di fecth ke yang di save
                        self.savedRecipes.append(recipe)
                        self.savedList.reloadData()
                    }
                }else{
                    print("Recipe document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
