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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK:- Outlets
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
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
            return "Password must contain a minimum of 8 characters,a special symbol and a number"
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
            self.registerUserInDatabase()
        }
    }
    
    // Format buttons and labels and add message text
    fileprivate func setupViews(){
        Utilities.styleHollowButton(signUpButton)
        self.setupPlaceholders()
        self.setupTextFielf()
        errorLabel.alpha = 0
        messageLabel.text = "Let's sign up"
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.contentMode = .scaleAspectFit
        self.profileImageView.layer.cornerRadius = 60
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
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
    
    // Method to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTF.resignFirstResponder()
        signUpButtonClick((Any).self)
        return true
    }
    
    // Create and display an alert window with some message
     func showAlertWindow(){
        // Create the alert
        let alert = UIAlertController(title: "Thank you for sign up!", message: "Please proceed to login", preferredStyle: UIAlertController.Style.alert)
        // Add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.emailTF.text = nil
            self.passwordTF.text = nil
            self.firstNameTF.text = nil
            self.lastNameTF.text = nil
            let loginViewController = self.storyboard?.instantiateViewController(identifier: Constants.StroyBoards.loginViewControllerID)
            self.navigationController?.pushViewController(loginViewController!, animated: true)
        }))
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
