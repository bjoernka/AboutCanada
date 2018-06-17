//
//  Extensions.swift
//  CanadaApp
//
//  Created by Björn Kaczmarek on 16.06.18.
//  Copyright © 2018 Björn Kaczmarek. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        var image = UIImage()
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 {
                if let mimeType = response?.mimeType, mimeType.hasPrefix("image") {
                    if let data = data {
                        image = UIImage(data: data)!
                    } else {
                        print("Data Error")
                    }
                } else {
                    print("mineType Error")
                }
            } else {
                print("Data: " + String(describing: data))
                print("httpURLResponse")
                image = UIImage(named: "image_not_downloaded")!
            }
            
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func downloadImageLazyFrom(link:String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async() {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

