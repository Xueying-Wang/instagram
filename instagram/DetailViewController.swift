//
//  DetailViewController.swift
//  instagram
//
//  Created by Xueying Wang on 6/28/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DetailViewController: UIViewController {
    
    @IBOutlet weak var photoView: PFImageView!
    
    @IBOutlet weak var avatarView: PFImageView!
    
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    var feed = PFObject(className: "Post")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if PFUser.current()!.object(forKey: "avatar") as? PFFile != nil {
            avatarView.file = PFUser.current()!.object(forKey: "avatar") as? PFFile
            avatarView.loadInBackground()
        } else {
            avatarView.image = UIImage(named: "profile_tab")
        }
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 15
        avatarView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        avatarView.layer.borderWidth = 1
        
        photoView.file = feed["media"] as? PFFile
        photoView.loadInBackground()
        
        captionLabel.text = feed["caption"] as? String
        likesLabel.text = "❤️ \(feed["likesCount"] as! Int) likes"
        
        let author = (feed["author"] as! PFUser).username
        self.authorLabel.text = author
        
        let time = (feed.createdAt!).description
        let index = time.index(time.startIndex, offsetBy: 19)
        self.timeLabel.text = "Time: " + time.substring(to: index)
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
