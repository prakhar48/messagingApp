//
//  MessageModel.swift
//  MessagingApp
//
//  Class is responsible to store messages data from server
//
//  Created by Prakhar on 07/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import Firebase

@objcMembers
class Message: NSObject {
    
    var toID: String?
    var fromID: String?
    var text: String?
    var timeStamp: NSNumber?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    // Method to return the chat partner ID based on currentUser
    func chatPartnerID() -> String?{
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
    init(dictionary: [String: AnyObject]){
        super.init()
        toID = dictionary["toID"] as? String
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
}
