//
//  LoginViewController.swift
//  MessagingApp
//
//  Class handles login authentication with firebase and provides access to app features such as payments and dashboard
//
//  Created by Prakhar on 02/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK:- Business logic
    // Field validation to access them further without error
    func fieldsValidation() -> String? {
        
        if emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please make a valid entry"
        }
        
        return nil
    }
    
    // Error message handle
    func showErrorMessage(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    // Method to dismiss keyboard when password is entered
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTF.resignFirstResponder()
        loginButtonClick((Any).self)
        return true
    }
    
    // Login button action to perform user login using firebase authentication
    @IBAction func loginButtonClick(_ sender: Any) {
        
        let error =  self.fieldsValidation()
        if error != nil{
            self.showErrorMessage(error!)
        }else{
            let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
                if error != nil{
                    self.showErrorMessage("Error loging in! \n Incorrect email or password ")
                }else{
                    self.dismiss(animated: true, completion: nil)
                    self.perform(#selector(self.transitionToHomeScreen), with: nil, afterDelay: 0)
                }
            }
        }
    }
    
    // Disign buttons and UItextfields as per UI
    fileprivate func setupViews(){
        Utilities.styleHollowButton(loginButton)
        Utilities.styleTextField(emailTF)
        Utilities.styleTextField(passwordTF)
        Utilities.stylePlaceholderText(emailTF, placeholderText: "Email id")
        Utilities.stylePlaceholderText(passwordTF, placeholderText: "Password")
        errorLabel.alpha = 0
        messageLabel.text = "Input credentials"
    }
    
    // Method to navigate to a specific screen
    @objc fileprivate func transitionToHomeScreen(){
        let dataNavigationControllerRef = storyboard?.instantiateViewController(identifier: Constants.StroyBoards.dataNavigationController)
        view.window?.rootViewController = dataNavigationControllerRef
        view.window?.makeKeyAndVisible()
    }
}
