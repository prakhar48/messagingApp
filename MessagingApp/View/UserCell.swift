//
//  UserCell.swift
//  MessagingApp
//
//  Class to manage the cell layout for tableView
//
//  Created by Prakhar on 07/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message?{
        didSet{
            self.setupProfile()
            self.detailTextLabel?.text = message?.text
            self.timeLabel.text = getTimeStamp(message: message!)
        }
    }
    
    // MARK: - Business Logic
    // Method responsible to setup user profile in the view
    private func setupProfile(){
        if let id = message?.chatPartnerID(){
            let database = Database.database().reference().child("users").child(id)
            database.observe(.value, with: { (snapShot) in
                if let dictionary = snapShot.value as? [String : AnyObject]{
                    let firstname = dictionary["firstname"] as! String
                    let lastname = dictionary["lastname"] as! String
                    self.textLabel?.text = firstname + " " + lastname
                    self.profileImageView.loadImageFromServerUsingUrl(urlString: dictionary["profileImageUrl"] as! String)
                }
            }, withCancel: nil)
        }
    }
    
    // Fetch the current time based on the timezone provided
    fileprivate func getTimeStamp(message: Message) -> String{
        var dateString: String = ""
        if let seconds = message.timeStamp?.doubleValue{
            let timeStampData = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            dateString = dateFormatter.string(from: timeStampData as Date )
        }
        return dateString
    }
    
    // MARK: - UIElements design
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .thin)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
