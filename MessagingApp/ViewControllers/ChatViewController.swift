//
//  ChatViewController.swift
//  MessagingApp
//
//  Class is responsible to provide chat feature with the choosen user and sync them with server
//
//  Created by Prakhar on 06/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
    
    // MARK:- Outlets and listen to user's via closure
    var user: User? {
        didSet{
            navigationItem.title = (user?.firstname ?? " ") + " " + (user?.lastname ?? " ")
            observeMessages()
        }
    }
    
    var cellID = "collectionCellID"
    var message = [Message]()
    var containerBottomAnchor: NSLayoutConstraint?
    
    // MARK:- LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    // MARK:- Business logic
    
    // UI element creation following closures
    lazy var textField: UITextField = {
        let textFieldInput = UITextField()
        textFieldInput.placeholder = "begin typing..."
        textFieldInput.delegate = self
        textFieldInput.translatesAutoresizingMaskIntoConstraints = false
        return textFieldInput
    }()
    
    lazy var inputContainerView: UIView={
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        containerView.backgroundColor = .white
        
        // Create send message button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // Add constraints to testField
        containerView.addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        // Create separater line for textfield
        let separaterView = UIView()
        separaterView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        separaterView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separaterView)
        
        separaterView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separaterView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separaterView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separaterView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    // Create input accessory view as base of text field
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    // Keyboard responder method
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // Method to observe messages from firebase server
    fileprivate func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.userid else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        userMessageRef.observe(.childAdded, with: { (snapShot) in
            let messageID = snapShot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (dataSnapShot) in
                guard let dictionary = dataSnapShot.value as? [String : AnyObject] else{
                    return
                }
                let messages = Message()
                messages.setValuesForKeys(dictionary)
                self.message.append(messages)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    // Setup collection view for message
    fileprivate func setupView(){
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.keyboardDismissMode = .interactive
        self.collectionView.register(ChatViewCell.self, forCellWithReuseIdentifier: cellID)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    // Method to send the typed messages to the database
    @objc fileprivate func handleSendButton(){
        let database = Database.database().reference().child("messages")
        let childRef = database.childByAutoId()
        let toID = user!.userid!
        let fromID = Auth.auth().currentUser!.uid
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let values = ["text" : textField.text!, "toID" : toID, "fromID" : fromID, "timeStamp" : timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, reference) in
            if error != nil{
                print("Error \(String(describing: error))")
                return
            }
            
            // Clear the text once enter is hit
            self.textField.text = nil
            
            let fromMessagesRef = Database.database().reference().root.child("user-messages").child(fromID).child(toID)
            let messageID = childRef.key!
            fromMessagesRef.updateChildValues([messageID : 1])
            
            let toMessagesRef = Database.database().reference().root.child("user-messages").child(toID).child(fromID)
            toMessagesRef.updateChildValues([messageID : 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.handleSendButton()
        return true
    }
    
    // MARK:- CollectionView Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatViewCell
        let messages = message[indexPath.row]
        cell.textView.text = messages.text
        self.setupCell(cell: cell, messages: messages)
        
        cell.bubbleWidthConstraint?.constant = getEstimatedRowHeight(text: messages.text!).width + 30
        return cell
    }
    
    // Method to setup cells and adjust the color of text message
    private func setupCell(cell: ChatViewCell, messages: Message){
        if messages.fromID == Auth.auth().currentUser?.uid{
            // Outgoing message
            cell.bubbleView.backgroundColor = ChatViewCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        }else{
            // Incoming message
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 0
        let width = UIScreen.main.bounds.width
        if let text = message[indexPath.row].text{
            height = getEstimatedRowHeight(text: text).height + 20
        }
        return CGSize(width: width, height: height)
    }
    
    // Method to get the bubble height based on text entered
    fileprivate func getEstimatedRowHeight(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    // Layout adjustment based on app transition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
