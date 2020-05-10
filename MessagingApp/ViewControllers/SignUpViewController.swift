//
//  SignUpViewController.swift
//  MessagingApp
//
//  Class is responsible to hanlde the database document creation based on user entered values
//
//  Created by Prakhar on 02/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    // MARK:- Business Logic
    
    // Validate all the user fields before further accessing
    func fieldsValidation() -> String? {
        
        if firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please make a valid entry"
        }
        
        let cleanedPassword = passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Password validation check
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Password must contain: \n 1. minimum of 8 characters \n 2. must contain a special character \n 3. must contain a number"
        }
        return nil
    }
    
    // Error message handle
    func showErrorMessage(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    // Singup button action to perform database document creation
    @IBAction func signUpButtonClick(_ sender: Any) {
        
        let error = self.fieldsValidation()
        
        if error != nil{
            self.showErrorMessage(error!)
        }else{
            
            let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // User creation in firebase firestore
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil{
                    self.showErrorMessage("Error in account creation")
                }else{
                    guard let uid = result?.user.uid else {
                        return
                    }
                    guard let emailid = self.emailTF.text, let firstname = self.firstNameTF.text, let lastname = self.lastNameTF.text else {
                        return
                    }
                    
                    let ref = Database.database().reference()
                    let userRefernce = ref.child("users").child(uid)
                    let values = ["firstname": firstname, "lastname": lastname, "email": emailid]
                    userRefernce.updateChildValues(values)
                    
                    // Show alert window with a message
                    self.showAlertWindow(sender as! UIButton)
                }
            }
        }
    }
    
    // Format buttons and labels and add message text
    fileprivate func setupViews(){
        Utilities.styleHollowButton(signUpButton)
        self.setupPlaceholders()
        self.setupTextFielf()
        errorLabel.alpha = 0
        messageLabel.text = "Let's sign up"
    }
    
    // Method to design placeholder text
    fileprivate func setupPlaceholders(){
        Utilities.stylePlaceholderText(firstNameTF, placeholderText: "First name")
        Utilities.stylePlaceholderText(lastNameTF, placeholderText: "Last name")
        Utilities.stylePlaceholderText(emailTF, placeholderText: "Email id")
        Utilities.stylePlaceholderText(passwordTF, placeholderText: "Password")
    }
    
    // Method to style textfields
    fileprivate func setupTextFielf(){
        Utilities.styleTextField(firstNameTF)
        Utilities.styleTextField(lastNameTF)
        Utilities.styleTextField(emailTF)
        Utilities.styleTextField(passwordTF)
    }
    
    // Create and display an alert window with some message
    fileprivate func showAlertWindow(_ sender: UIButton){
        // Create the alert
        let alert = UIAlertController(title: "Thank you for sign up!", message: "Please proceed to login", preferredStyle: UIAlertController.Style.alert)
        // Add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            let loginViewController = self.storyboard?.instantiateViewController(identifier: Constants.StroyBoards.loginViewControllerID)
            self.navigationController?.pushViewController(loginViewController!, animated: true)
        }))
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
