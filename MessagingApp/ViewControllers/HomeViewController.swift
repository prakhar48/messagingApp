//
//  HomeViewController.swift
//  MessagingApp
//
//  Class is responsible to play an animation and provide user, the signup and the login access
//
//  Created by Prakhar on 02/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupVideoPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Business logic
    
    // Create player layer and assign path to video
    fileprivate func setupVideoPlayer(){
        let bundlePath = Bundle.main.path(forResource: "animation", ofType: "mp4")
        
        guard bundlePath != nil else{
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath!)
        let videoItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: videoItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.playerView.frame.width, height: self.playerView.frame.width)
        playerLayer.contentsScale = 1.5
        
        playerView.layer.insertSublayer(playerLayer, at: 0)
        player.play()
        
        // Observer to check if player reached end of item and restart player again
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) {_ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    //Design buttons and add message text
    fileprivate func setUpViews(){
        
        self.messageLabel.text = "Welcome to MessagingApp"
        
        Utilities.styleHollowButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
}

