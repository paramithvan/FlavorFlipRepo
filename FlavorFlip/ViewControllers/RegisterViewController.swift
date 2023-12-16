//
//  RegisterViewController.swift
//  FlavorFlip
//
//  Created by Vania Paramitha on 05/12/23.
//

import UIKit
import FirebaseFirestore


class RegisterViewController: UIViewController {
    let database = Firestore.firestore()
    
    @IBOutlet weak var RegisterLabel: UILabel!
    
    @IBOutlet weak var RegistDescLabel: UILabel!
    
    @IBOutlet weak var HaveAccLabel: UILabel!
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var UsernameField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var ConfirmPasswordField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let docRef = database.document("users/userId")
        docRef.getDocument{snapshot, error in
            guard let data = snapshot?.data(), error == nil else{
                return
            }
            print(data)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func RegisButton(_ sender: Any) {
        let email = EmailField.text!
        let username = UsernameField.text!
        let password = PasswordField.text!
        let confirm = ConfirmPasswordField.text!
        
        if(email.isEmpty || username.isEmpty || password.isEmpty || confirm.isEmpty){
            showMsg(message: "All field must be filled")
        }else{
            if(!email.hasSuffix("@gmail.com") && !email.hasSuffix("@yahoo.com") && !email.hasSuffix("@email.com")){
                showMsg(message: "Email must end either with '@gmail.com', '@yahoo.com', or '@email.com'")
            }else if(password.count < 6){
                showMsg(message: "Password length must be more than 6 characters")
            } else if(!validPass(pass: password)){
                showMsg(message: "Password must be alphanumeric.")
            }else if !(password == confirm){
                showMsg(message: "Confirm password must be the same as Password")
            }
        }

        var ref: DocumentReference? = nil
        ref = database.collection("users").addDocument(data:[
                                                        "email": email,
                                                       "username" : username,
                                                        "password":password]){
                                                            err in
                                                              if let err = err {
                                                                print("Error adding document: \(err)")
                                                              } else {
                                                                print("Document added with ID: \(ref!.documentID)")
                                                              }
                                                        }
        
        performSegue(withIdentifier: "RegisterSuccess", sender: self)
    }
    
    @IBAction func GoToLogin(_ sender: Any) {
        performSegue(withIdentifier: "LoginBtn", sender: self)
    }

    
    func showMsg(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func validPass(pass:String) -> Bool{
        
        var isNum = false
        var isAlp = false
        
        for a in pass{
            if(a.isLetter){
                isAlp = true
            }
            
            if(a.isNumber){
                isNum = true
            }
        }
        
        return isAlp && isNum
    }
}
