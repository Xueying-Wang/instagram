//
//  ProfileViewController.swift
//  instagram
//
//  Created by Xueying Wang on 6/28/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarView: PFImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        avatarView.file = PFUser.current()?.object(forKey: "avatar") as? PFFile
        avatarView.loadInBackground()
        if avatarView.file == nil {
            avatarView.image = UIImage(named: "profile_tab")
        }
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 50
        avatarView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        avatarView.layer.borderWidth = 1
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
