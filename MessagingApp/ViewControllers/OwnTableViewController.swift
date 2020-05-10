//
//  OwnTableViewController.swift
//  MessagingApp
//
//  Class is responsible to fetch the active user messages from server and to display, it also provides feature acccess to logout and start new chat
//
//  Created by Prakhar on 06/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class OwnTableViewController: UITableViewController{
    
    //MARK:- Outlets
    var message = [Message]()
    var messageDictionary = [String : Message]()
    var cellID = "cellID"
    var timer: Timer?
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    // MARK:- LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ManageFunctionCalls()
    }
    
    //MARK:- Business logic
    // Manage all the method calls during view load
    fileprivate func ManageFunctionCalls(){
        self.setupView()
        message.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        self.observeNewMessage()
    }
    
    // Set basic components and register table view cell
    fileprivate func setupView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        self.emptyMessage(message: "Fetching messages...")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "message"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        // Get the current user from server
        let userId = Auth.auth().currentUser?.uid
        
        if userId == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            // Display navigation title name of current user from server
            Database.database().reference().child("users").child(userId!).observeSingleEvent(of: .value) { (snapShot) in
                if let dictionary = snapShot.value as? [String : AnyObject]{
                    self.navigationItem.title = (dictionary["firstname"] as? String ?? "") + " " + (dictionary["lastname"] as? String ?? "")
                }
            }
        }
    }
    
    // Method to handle signout from server and navigate to home
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        } catch{
            print("Logout unsuccessful")
        }
        let mainNavigationController = storyboard?.instantiateViewController(identifier: Constants.StroyBoards.mainNavigationController)
        view.window?.rootViewController = mainNavigationController
        view.window?.makeKeyAndVisible()
    }
    
    // NewMessage button click handle method, it helps in navigation to new page, also register the delegate of UsersViewController
    @objc func handleNewMessage(){
        let usersViewController = UsersViewController()
        usersViewController.ownViewController = self
        self.navigationController!.pushViewController(usersViewController, animated: true)
    }
    
    // Method is responsible for navigating to chat view page
    func showChatViewControllerForUser(user: User){
        let chatViewController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatViewController.user = user
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    // Listen to all the messages of a particular user
    fileprivate func observeNewMessage(){
        self.showActivityIndicator()
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let dataBaseRef = Database.database().reference().child("user-messages").child(uid)
        dataBaseRef.observe(.childAdded, with: { (snapShot) in
            
            let userID = snapShot.key
            let ref = Database.database().reference().child("user-messages").child(uid).child(userID)
            ref.observeSingleEvent(of: .childAdded, with: { (snapShot) in
                let messageID = snapShot.key
                self.fetchUserMessageOnRequest(messageID: messageID)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // Fetch all the messages from server based on messageID
    private func fetchUserMessageOnRequest(messageID: String){
        let messageRef = Database.database().reference().child("messages").child(messageID)
        messageRef.observeSingleEvent(of: .value, with: { (messageSnapShot) in
            if let dictionary = messageSnapShot.value as? [String : AnyObject]{
                let localMessage = Message()
                localMessage.setValuesForKeys(dictionary)
                if let chatPartnerID = localMessage.chatPartnerID(){
                    self.messageDictionary[chatPartnerID] = localMessage
                }
                self.attemptTableReload()
                self.activityIndicator.stopAnimating()
            }
        }, withCancel: nil)
    }
    
    // Method to attempt tableView reload only based on timer
    private func attemptTableReload(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableReload), userInfo: nil, repeats: false)
    }
    
    // Sort the message array based on message timestamp and reload table data
    @objc private func handleTableReload(){
        self.message = Array(self.messageDictionary.values)
        self.message.sort { (message1, message2) -> Bool in
            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var messageTimer: Timer?
    
    // MARK:- Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return setNumberOfSections()
    }
    
    // Set number of sections based on message count and display error message
    private func setNumberOfSections() -> Int{
        if message.count > 0{
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = .singleLine;
            messageTimer?.invalidate()
            return 1
        }else{
            self.activityIndicator.stopAnimating()
            messageTimer?.invalidate()
            messageTimer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(setErrorMessage), userInfo: nil, repeats: false)
            return 0
        }
    }
    
    // Feed error message data
    @objc func setErrorMessage(){
        self.emptyMessage(message: "No messages found")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let messages = message[indexPath.row]
        cell.message = messages
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.rowHeight)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loaclMessage = message[indexPath.row]
        guard let chatPartnerId = loaclMessage.chatPartnerID() else {
            return
        }
        
        // Navigate the chat view controller based on cell click
        let dataBaseRef = Database.database().reference().child("users").child(chatPartnerId)
        dataBaseRef.observeSingleEvent(of: .value, with: { (snapShot) in
            
            guard let dictionary = snapShot.value as? [String: AnyObject] else{
                return
            }
            let user  = User()
            user.userid = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatViewControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    // MARK:- Utility methods
    
    // Update Table view for error label
    private func emptyMessage(message: String) {
        self.tableView.backgroundView = Utilities.designErrorLabel(message: message, view: self.view)
        self.tableView.separatorStyle = .none;
    }
    
    // Design activity indicator
    fileprivate func showActivityIndicator(){
        // Place the activity indicator on the center of your current screen
        activityIndicator.center = self.view.center
        
        // In most cases this will be set to true, so the indicator hides when it stops spinning
        activityIndicator.hidesWhenStopped = true
    }
}
