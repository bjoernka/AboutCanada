//
//  DetailViewController.swift
//  CanadaApp
//
//  Created by Björn Kaczmarek on 13.06.18.
//  Copyright © 2018 Björn Kaczmarek. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var imageName = ""
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (imageName == "imagehref_is_null") {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = UIImage(named: "image_not_downloaded")
            imageView.downloadImageLazyFrom(link: imageName, contentMode: .scaleAspectFit)
        }
        
        textView.text = text
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
