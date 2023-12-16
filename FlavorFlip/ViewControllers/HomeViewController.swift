//
//  HomeViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 06/12/23.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, RecipeTableViewCellDelegate{

    let database = Firestore.firestore()

    @IBOutlet weak var TableViewRecipe: UITableView!
    var arrOfRecipe = [[recipeModel]]() // Mengubah tipe data ke array dua dimensi
    var selectedRecipeIndex: IndexPath?

    
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
                        let steps = data["Steps"]as? [String]{
                        
                        let documentID = document.documentID
                        let recipe = recipeModel(documentID: documentID,imagePotrait: imagePotrait, name: name, creator: creator, ingredients: ingredients, equipment: equipment,steps: steps)
                        
                        // Menambahkan recipe ke array 2 dimensi
                        fetchedRecipes.append([recipe])
                    }
                }
                self?.arrOfRecipe = fetchedRecipes
                self?.TableViewRecipe.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Menggunakan array dalam array, sehingga setiap section hanya memiliki satu item
        return arrOfRecipe[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Mengembalikan jumlah section sesuai dengan jumlah elemen di arrOfRecipe
        return arrOfRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecipeTableViewCell
        
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
                    cell.RecipePhotos.image = image
                }

            }.resume()
        } else {
            print("URL gambar tidak valid")
        }
        
        cell.RecipeTItleLabel.text = recipe.name
        cell.ChefLabel.text = recipe.creator
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableViewRecipe.dataSource = self
        TableViewRecipe.delegate = self
        fetchDataFromFirestore()
        
        // buat ilangin putih putih di atasnya
//        TableViewRecipe.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: TableViewRecipe.frame.height, height: CGFloat.leastNormalMagnitude))
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
}
