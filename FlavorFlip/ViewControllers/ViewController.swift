//
//  ViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 24/10/23.
//

import UIKit
import FirebaseFirestore


class ViewController: UIViewController {
    let database = Firestore.firestore()
    var arrOfUser = [User]()

    @IBOutlet weak var LoginLabel: UILabel!
    
    @IBOutlet weak var LoginDescription: UILabel!
    
    @IBOutlet weak var DontHaveLabel: UILabel!
    @IBOutlet weak var UsernameField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataUser()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
         let CurrUsername = UsernameField.text!
         let CurrPassword = PasswordField.text!
        
        if(CurrUsername.isEmpty || CurrPassword.isEmpty){
            showMsg(message: "All field must be filled")
        }
        
        if let matchedUser = arrOfUser.first(where: { $0.username == CurrUsername && $0.password == CurrPassword }){
            performSegue(withIdentifier:"LoginSuccess" , sender: self)
            UserDefaults.standard.set(matchedUser.userId, forKey: "currentUserDocumentID")
        }else{
            showMsg(message: "Invalid username or password")
        }
        
        if let currentUserDocumentID = UserDefaults.standard.string(forKey: "currentUserDocumentID") {
            // Use currentUserDocumentID as needed
//            print("Document ID for current user: \(currentUserDocumentID)")
        }

    }
    
    @IBAction func GoToRegist(_ sender: Any) {
    }
    
    func showMsg(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func fetchDataUser(){
        database.collection("users").getDocuments{
            [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var fetchedUsers: [User] = []
                for document in snapshot!.documents{
                    let data = document.data()
//                    print("Data User from Firestore: \(data)")
                    
                    if let email = data["email"] as? String,
                        let username = data["username"] as? String,
                       let password = data["password"] as? String,
                       let userId = document.documentID as? String{
                        let users = User(userId : userId,email: email, username: username, password: password)
                        
                        fetchedUsers.append(contentsOf: [users])
                        
                        // Save Document ID to UserDefaults
//                        let userId =  document.documentID
//                        print("login user ID : \(userId)")
                        
                    }
                }
                self?.arrOfUser = fetchedUsers
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

