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

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatarView: PFImageView!
    
    @IBOutlet weak var username: UILabel!

    @IBOutlet weak var postsCount: UILabel!
    
    @IBOutlet weak var likesCount: UILabel!
    
    var feeds: [PFObject] = []
    
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
        
        username.text = PFUser.current()?.username
        postsCount.text = "📋Posts"
        likesCount.text = "❤️Likes"
        fetchPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPosts(){
        // construct query
        let query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: PFUser.current())
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                self.feeds = posts
                self.postsCount.text = "📋 \(self.feeds.count) Posts"
                
                var count = 0
                for post in posts{
                    count += post["likesCount"] as! Int
                }
                self.likesCount.text = "❤️ \(count) Likes"
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        self.avatarView.image = editedImage
        PFUser.current()?.setObject(editedImage, forKey: "avatar")
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeAvatarAlert(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Change Your Profile Picture", message: "Take a new photo or select one from your photo library", preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.camera
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                print("Camera is available 📸")
                vc.sourceType = .camera
            } else {
                print("Camera 🚫 available so we will use photo library instead")
                vc.sourceType = .photoLibrary
            }
            
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(libraryAction)
        
        present(alertController, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
        }
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
