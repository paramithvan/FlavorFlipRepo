//
//  BookmarkViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit
import FirebaseFirestore

class BookmarkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var selectedRecipe: recipeModel?
    var savedRecipes: [recipeModel] = []

    @IBOutlet weak var savedList: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedList.dataSource = self
        savedList.delegate = self
    
        if let selectedRecipe = selectedRecipe {
                   savedRecipes.append(selectedRecipe)
                   savedList.reloadData()
               }
        fetchedSavedRecipes(for: "currentUserDocumentID" )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           flowLayout.scrollDirection = .vertical
           flowLayout.minimumLineSpacing = 2
           flowLayout.minimumInteritemSpacing = 2
           flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        savedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = savedList.dequeueReusableCell(withReuseIdentifier: "savedCell", for: indexPath) as! SavedRecipeCollectionViewCell
        
        let recipe = savedRecipes[indexPath.item]
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

                DispatchQueue.main.async {
                    cell.imageRecipes.image = image
                }

            }.resume()
        } else {
            print("URL gambar tidak valid")
        }
        cell.TitleLabel.text = recipe.name
        
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

                DispatchQueue.main.async {
                    cell.imageRecipes.image = image
                }

            }.resume()
        } else {
            print("URL gambar tidak valid")
        }
        
        cell.TitleLabel.text = recipe.name
        
        return cell
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
        let dispatchGroup = DispatchGroup()
        var newRecipes: [recipeModel] = []
        
        for documentID in recipeDocumentIDs{
            dispatchGroup.enter()
            
            let recipeRef = Firestore.firestore().collection("recipes").document(documentID)
            recipeRef.getDocument{ document, error in
                defer{
                    dispatchGroup.leave()
                }
                
                if let document = document, document.exists {
                    if let imagePotrait = document.data()?["imagePotrait"] as? String,
                       let name = document.data()?["name"] as? String,
                       let creator = document.data()?["creator"] as? String,
                       let ingredients = document.data()?["ingredients"] as? [String],
                       let equipment = document.data()?["equipment"] as? [String],
                       let steps = document.data()?["Steps"]as? [String]{
                        let recipe = recipeModel(documentID: documentID, imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients,equipment: equipment, steps: steps)
                        // masukin recipe yang di fecth ke yang di save
//                        self.savedRecipes.append(recipe)
//                        self.savedList.reloadData()
                        newRecipes.append(recipe)
                    }
                }else{
                    print("Recipe document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }
                
                self.savedRecipes = newRecipes
                self.savedList.reloadData()
            }
        }
        
        dispatchGroup.notify(queue: .main){
            self.savedRecipes = newRecipes
            self.savedList.reloadData()
        }
    }
    
    
}
