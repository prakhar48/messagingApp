//
//  Helpers.swift
//  MessagingApp
//
//  Class to cache the images downloaded from server
//
//  Created by Prakhar on 14/05/20.
//  Copyright © 2020 Prakhar. All rights reserved.
//

import UIKit

var imageCache = NSCache<NSString, AnyObject>()

extension UIImageView{
    func loadImageFromServerUsingUrl(urlString: String){
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString){
            self.image = cachedImage as? UIImage
            return
        }
        if let imageURL = URL(string: urlString){
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if error != nil{
                    print("Error \(String(describing: error))")
                    return
                }
                guard let imageData = data else{
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: imageData){
                        imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                        self.image = downloadedImage
                    }
                }
            }.resume()
        }else{
            self.image = UIImage(systemName: "person.crop.circle")
        }
    }
}
