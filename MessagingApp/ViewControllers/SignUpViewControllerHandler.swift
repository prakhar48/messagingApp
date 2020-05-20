//
//  SignUpViewControllerHandler.swift
//  MessagingApp
//
//  Created by Prakhar on 10/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // Create instance of UIImagePickerController and present it into the view hierarchy
    @objc func handleProfileImageView(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Load the image based on selection done by user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Cancel button action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Method to register the user in the database with its properties
    func registerUserInDatabase(){
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
                self.updateFirebaseStorage(uid: uid, firstname: firstname, lastname: lastname, emailid: emailid)
            }
        }
    }
    
    // Upload the profile image with jpeg compression to avoid heavy server space usage
    func updateFirebaseStorage(uid: String, firstname: String, lastname: String, emailid: String ){
        let uniqueImageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child("\(uniqueImageName).jpeg")
        if let uploadData = self.profileImageView.image?.jpegData(compressionQuality: 0.1){
            storageRef.putData(uploadData, metadata: nil) { (metaData, error) in
                if error != nil{
                    print("Error \(String(describing: error))")
                    return
                }
                storageRef.downloadURL { (url, error) in
                    if error != nil{
                        print("Error \(String(describing: error))")
                        return
                    }else{
                        if let localURl = url?.absoluteString{
                            let ref = Database.database().reference()
                            let userRefernce = ref.child("users").child(uid)
                            let values = ["firstname": firstname, "lastname": lastname, "email": emailid, "profileImageUrl": localURl]
                            userRefernce.updateChildValues(values)
                            
                            // Show alert window with a message
                            self.showAlertWindow()
                        }
                    }
                }
            }
        }
    }
}
