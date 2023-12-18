//
//  BookmarkViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 10/12/23.
//

import UIKit
import FirebaseFirestore

class BookmarkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var selectedRecipe: recipeModel?
    var savedRecipes = [recipeModel]()
    var usernameVar: String?
    var emailVar: String?
    var cornerRadius: CGFloat = 12.0
   
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var greetings: UILabel!
    @IBOutlet weak var savedList: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    func fetchDataUser(){
        let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID")
        Firestore.firestore().collection("users").getDocuments{
            [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var fetchedUsers: [User] = []
                for document in snapshot!.documents{
                    let data = document.data()
                    let id = document.documentID as? String
                    print(currentUserDocumentID)
                    if id == currentUserDocumentID{
                        print("yeha")
                        let email = data["email"] as? String
                        print(email)
                        let use = data["username"] as? String
                        print(use)
                        self?.userEmail.text = email
                        self?.greetings.text = "Hello, \(use!)"
                    }

                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedSavedRecipes()
        self.savedList.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedList.dataSource = self
        savedList.delegate = self
        savedList.reloadData()
        fetchDataUser()
        userEmail.text = emailVar
        greetings.text = "Hello, \(usernameVar)"
        
        
        print(selectedRecipe)
        if let selectedRecipe = selectedRecipe {
            print("masuk sini")
                   savedRecipes.append(selectedRecipe)
                   savedList.reloadData()
               }
        print("hi")
        fetchedSavedRecipes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = savedRecipes[indexPath.item]
        performSegue(withIdentifier: "LookDetail", sender: selectedRecipe)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LookDetail", let destinationVC = segue.destination as? DetailRecipeViewController, let selectedRecipe = sender as? recipeModel {
            destinationVC.recipe = selectedRecipe
        }
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let customHeight:CGFloat = 235
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (savedList.frame.size.width - space) / 2.0
        
        return CGSize(width: size, height: customHeight)
    }
    
    
    
    func fetchedSavedRecipes() {
        guard let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID") else {
            return
        }

        let userRef = Firestore.firestore().collection("users").document(currentUserDocumentID)
        userRef.collection("savedRecipes").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting saved recipes: \(error.localizedDescription)")
                return
            }

            var savedRecipeIDs: [String] = []

            for document in querySnapshot!.documents {
                let recipeID = document["recipeID"] as? String
                savedRecipeIDs.append(recipeID ?? "")
            }

            self?.fetchRecipeDetails(for: savedRecipeIDs)
        }
    }

    func fetchRecipeDetails(for recipeIDs: [String]) {
        var newRecipes: [recipeModel] = []

        for recipeID in recipeIDs {
            let recipeRef = Firestore.firestore().collection("recipes").document(recipeID)

            recipeRef.getDocument { [weak self] (recipeDocument, error) in
                if let recipeDocument = recipeDocument, recipeDocument.exists {
                    if let imagePotrait = recipeDocument["imagePotrait"] as? String,
                       let name = recipeDocument["name"] as? String,
                       let creator = recipeDocument["creator"] as? String,
                       let ingredients = recipeDocument["ingredients"] as? [String],
                       let equipment = recipeDocument["equipment"] as? [String],
                       let steps = recipeDocument["Steps"] as? [String],
                       let creatorPhotos = recipeDocument["creatorPhotos"] as? String{

                        let recipe = recipeModel(documentID: recipeID, imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, equipment: equipment, steps: steps, creatorPhotos: creatorPhotos)
                        newRecipes.append(recipe)
                    }
                } else {
                    print("Recipe document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }

                self?.savedRecipes = newRecipes
                self?.savedList.reloadData()
            }
        }
    }

    @IBAction func logout(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    func fetchRecipeDetails(for recipeDocumentIDs: [String]){
//        var newRecipes: [recipeModel] = []
//
//        for documentID in recipeDocumentIDs{
//            let recipeRef = Firestore.firestore().collection("recipes").document(documentID)
//
//            recipeRef.getDocument{ document, error in
//                if let document = document, document.exists {
//                    if let imagePotrait = document.data()?["imagePotrait"] as? String,
//                       let name = document.data()?["name"] as? String,
//                       let creator = document.data()?["creator"] as? String,
//                       let ingredients = document.data()?["ingredients"] as? [String],
//                       let equipment = document.data()?["equipment"] as? [String],
//                       let steps = document.data()?["Steps"]as? [String]{
//                        let recipe = recipeModel(documentID: documentID, imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, equipment: equipment, steps: steps)
////                        // masukin recipe yang di fecth ke yang di save
////                        self.savedRecipes.append(recipe)
////                        self.savedList.reloadData()
//                        newRecipes.append(recipe)
//                        print(recipe)
//                    }
//                }else{
//                    print("Recipe document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
//                }
//
//                self.savedRecipes = newRecipes
//                self.savedList.reloadData()
//            }
//        }
//    }
    
//    func fetchRecipeDetails(recipeIDs: String) {
//        var newRecipes: [recipeModel] = []
//
//        for recipeID in recipeIDs {
////            let recipeRef2 = Firestore.firestore().collection("recipes").document(recipeID)
////            print(recipeRef2)
//            
//            let recipeRef = Firestore.firestore().document(recipeID)
//            recipeRef.getDocument { [weak self] (recipeDocument, error) in
//                print(recipeDocument)
//                if let recipeDocument = recipeDocument, recipeDocument.exists {
//                    if let imagePotrait = recipeDocument.data()?["imagePotrait"] as? String,
//                       let name = recipeDocument.data()?["name"] as? String,
//                       let creator = recipeDocument.data()?["creator"] as? String,
//                       let ingredients = recipeDocument.data()?["ingredients"] as? [String],
//                       let equipment = recipeDocument.data()?["equipment"] as? [String],
//                       let steps = recipeDocument.data()?["Steps"] as? [String] {
//                        let recipe = recipeModel(documentID: recipeDocument.documentID, imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, equipment: equipment, steps: steps)
//                        newRecipes.append(recipe)
//                        self?.savedRecipes = newRecipes
//                        self?.savedList.reloadData()
//                    }
//                } else {
//                    print("Recipe document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
//    }
    
    
}
