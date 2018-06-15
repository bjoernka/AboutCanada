//
//  ViewController.swift
//  CanadaApp
//
//  Created by Björn Kaczmarek on 12.06.18.
//  Copyright © 2018 Björn Kaczmarek. All rights reserved.
//

import UIKit

struct jsonObject: Decodable {
    let title: String
    let rows: [rowObject]
}

struct rowObject: Decodable {
    let title: String?
    let description: String?
    let imageHref: String?
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        self.collectionView.reloadData()
    }
    
    var rowObjects = [rowObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let jsonUrl = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
        guard let url = URL(string: jsonUrl) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            // TODO: replace guard with if let
            guard let data = data else {return}
            
            let dataAsIsoLatin = String(data: data, encoding: .isoLatin1)
            let dataUTF8 = dataAsIsoLatin?.data(using: .utf8)
            
            do {
                let decodedData = try
                    JSONDecoder().decode(jsonObject.self, from: dataUTF8!)
                print(decodedData)
                self.rowObjects = decodedData.rows
            } catch let jsonErr {
                print(jsonErr)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowObjects.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        if let rowObjectsTitle = rowObjects[indexPath.row].title {
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.text = rowObjectsTitle
            cell.titleLabel.lineBreakMode = .byWordWrapping
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        } else {
            cell.titleLabel.text = "null"
        }
        
        if let rowObjectsDescription = rowObjects[indexPath.row].description {
            cell.descriptionLabel.numberOfLines = 0
            cell.descriptionLabel.text = rowObjectsDescription
            cell.descriptionLabel.lineBreakMode = .byWordWrapping
        } else {
            cell.descriptionLabel.text = "null"
        }
        
        if let rowObjectsImageLink = rowObjects[indexPath.row].imageHref {
            cell.imageView.image = UIImage(named: "image_not_downloaded")
            cell.imageView.downloadImageLazyFrom(link: rowObjectsImageLink, contentMode: .scaleAspectFit)
        } else {
            cell.imageView.image = UIImage(named: "imagehref_is_null")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailPage")
        let detailPage = vc as! DetailViewController
        
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            detailPage.title = cell.titleLabel.text
            detailPage.text = cell.descriptionLabel.text!
        } else {
            detailPage.title = "Null"
            detailPage.text = "Null"
        }
        
        if let rowObjectsImageLink = rowObjects[indexPath.row].imageHref {
            detailPage.imageName = rowObjectsImageLink
        } else {
            detailPage.imageName = "imagehref_is_null"
        }

        if let navCon = self.navigationController {
            navCon.pushViewController(detailPage, animated: true)
        } else {
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let realScreenHeight = (self.collectionView.bounds.height - (self.navigationController?.navigationBar.bounds.height)! - UIApplication.shared.statusBarFrame.height)
        return CGSize(width: self.collectionView.frame.width, height: (self.collectionView.frame.height / 5))
    }
    
}

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

