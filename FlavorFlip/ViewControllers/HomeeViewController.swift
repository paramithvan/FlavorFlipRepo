//
//  HomeeViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 18/12/23.
//

import UIKit
import FirebaseFirestore

class HomeeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecipesTableViewDelegate {
    
    let database = Firestore.firestore()
    
    var arrOfRecipe = [[recipeModel]]() // Mengubah tipe data ke array dua dimensi
    var selectedRecipeIndex: IndexPath?
    
    @IBOutlet weak var listRecipeTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listRecipeTV.dataSource = self
        listRecipeTV.delegate = self
        fetchDataFromFirestore()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfRecipe[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Mengembalikan jumlah section sesuai dengan jumlah elemen di arrOfRecipe
        return arrOfRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecipeListTableViewCell
        
        cell.delegate = self // Mengatur delegate pada setiap sel untuk menangani pengklikan tombol
        cell.indexPath = indexPath // setel indexPath pada cell

        // Mengatur recipe pada setiap sel agar dapat diakses saat tombol diklik
        cell.recipe = arrOfRecipe[indexPath.section][indexPath.row]
        
        // Mengambil recipe dari array dua dimensi
        let recipe = arrOfRecipe[indexPath.section][indexPath.row]
        
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
                    cell.recipeImages.image = image
                }

            }.resume()
        } else {
            print("URL gambar tidak valid")
        }
        
        cell.recipeTitle.text = recipe.name
        cell.chefName.text = recipe.creator
        
        return cell
    }
    
    // Implementasi fungsi dari RecipeTableViewCellDelegate
    func didTapGoToDetail(recipe: recipeModel, indexpath: IndexPath) {
        // Menangani pengklikan tombol dan pindah ke DetailRecipeViewController
        selectedRecipeIndex = indexpath
        performSegue(withIdentifier: "goToDetail", sender: recipe)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToDetail", let destinationVC = segue.destination as? DetailRecipeViewController, let recipe = sender as? recipeModel {
                destinationVC.recipe = recipe
                destinationVC.selectedRecipeIndex = selectedRecipeIndex
            }
        }
    
    func fetchDataFromFirestore() {
        database.collection("recipes").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var fetchedRecipes: [[recipeModel]] = []
                for document in snapshot!.documents {
                    let data = document.data()
//                    print("Data from Firestore: \(data)")
                    if let imagePotrait = data["imagePotrait"] as? String,
                       let name = data["name"] as? String,
                        let creator = data["creator"] as? String,
                       let ingredients = data["ingredients"] as? [String],
                       let equipment = data["equipment"] as? [String],
                        let steps = data["Steps"] as? [String],
                    let creatorPhotos = data["creatorPhotos"] as? String{
                        
                        let documentID = document.documentID
                        let recipe = recipeModel(documentID: documentID,imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, equipment: equipment, steps: steps, creatorPhotos: creatorPhotos)
                        
                        // Menambahkan recipe ke array 2 dimensi
                        fetchedRecipes.append([recipe])
                    }
                }
                self?.arrOfRecipe = fetchedRecipes
                self?.listRecipeTV.reloadData()
            }
        }
    }
    
    

   
}
