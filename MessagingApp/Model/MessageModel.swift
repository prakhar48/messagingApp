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
    
    // Method to return the chat partner ID based on currentUser
    func chatPartnerID() -> String?{
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}
