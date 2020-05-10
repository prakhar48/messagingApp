//
//  UsersViewController.swift
//  MessagingApp
//
//  Class provides list of all the registered users in the database
//
//  Created by Prakhar on 06/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UITableViewController {
    
    // MARK:- Variables and outlets
    var users = [User]()
    var cellID = "usersCellID"
    var ownViewController: OwnTableViewController?
    var timer: Timer?
    
    // MARK:- LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsersData()
        self.setupView()
    }
    
    // MARK:- TableViewDelegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        
        // Feed the user's data into cells
        cell.textLabel?.text = (user.firstname ?? " ") + " " + (user.lastname ?? " ")
        cell.detailTextLabel?.text = user.email
        cell.profileImageView.image = UIImage(systemName: "person.circle.fill")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
            let user = self.users[indexPath.row]
            
            //Sending user data back to OwnViewController then navigate it to ChatViewController via OwnViewController
            
            self.ownViewController?.showChatViewControllerForUser(user: user)
        })        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.rowHeight)
    }
    
    // MARK:- Business logic
    
    // Setup basic view
    fileprivate func setupView(){
        self.title = "New Message"
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    // Fetch user's data from firebase database
    fileprivate func fetchUsersData(){
        let activityIndicator = self.showActivityIndicator()
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        Database.database().reference().child("users").observe(.childAdded, with: { (dataSnap) in
            if let dictionary = dataSnap.value as? [String : AnyObject]{
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                user.userid = dataSnap.key
                
                // Timer is invalidate each time and rescheduled, selector is invoked when  last iteration of method call is complete
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableReload), userInfo: nil, repeats: false)
                
                activityIndicator.stopAnimating()
            }
            
        }, withCancel: nil)
    }
    
    // Selector method of scheduled timer
    @objc private func handleTableReload(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK:- Utility methods
    
    fileprivate func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
        // Place the activity indicator on the center of your current screen
        activityIndicator.center = view.center
        
        // In most cases this will be set to true, so the indicator hides when it stops spinning
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
}
