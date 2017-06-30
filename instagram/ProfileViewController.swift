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

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    class InfiniteScrollActivityView: UIView {
        var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        static let defaultHeight:CGFloat = 40
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupActivityIndicator()
        }
        
        override init(frame aRect: CGRect) {
            super.init(frame: aRect)
            setupActivityIndicator()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
        
        func setupActivityIndicator() {
            activityIndicatorView.activityIndicatorViewStyle = .gray
            activityIndicatorView.hidesWhenStopped = true
            self.addSubview(activityIndicatorView)
        }
        
        func stopAnimating() {
            self.activityIndicatorView.stopAnimating()
            self.isHidden = true
        }
        
        func startAnimating() {
            self.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    @IBOutlet weak var avatarView: PFImageView!
    
    @IBOutlet weak var username: UILabel!

    @IBOutlet weak var postsCount: UILabel!
    
    @IBOutlet weak var likesCount: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var refreshControl: UIRefreshControl!

    
    
    var feeds: [PFObject] = []
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading){
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && (tableView.isDragging || collectionView.isDragging)) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchPosts()
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isHidden = true
        collectionView.isHidden = false
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 4
        layout.minimumInteritemSpacing = 1
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width)
        
        if let avatarfile = PFUser.current()?["avatar"] as? PFFile {
            avatarView.file = avatarfile
            avatarView.loadInBackground()
        } else {
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
        didPullToRefresh(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let feed = feeds[indexPath.item]
        cell.instagramPost = feed
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! PhotoCell
        let feed = feeds[indexPath.section]
        cell.instagramPost = feed
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = PFImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        let feed = feeds[section]
        profileView.file = (feed["author"] as! PFUser).object(forKey: "avatar") as? PFFile
        profileView.loadInBackground()
        if profileView.file == nil {
            profileView.image = UIImage(named: "profile_tab")
        }
        
        headerView.addSubview(profileView)
        
        let author = (feed["author"] as! PFUser).username
        let nameLabel = UILabel(frame: CGRect(x: 40, y: 5, width: 70, height: 30))
        nameLabel.text = author
        nameLabel.textColor = UIColor.black
        
        headerView.addSubview(nameLabel)
        
        let time = (feed.createdAt!).description
        let index = time.index(time.startIndex, offsetBy: 10)
        let date = time.substring(to: index)
        let dateLabel = UILabel(frame: CGRect(x: 140, y: 5, width: 150, height: 30))
        dateLabel.text = "Date: " + date
        dateLabel.textColor = UIColor.black
        dateLabel.font = UIFont (name: "HelveticaNeue-Light", size: 15)
        headerView.addSubview(dateLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }


    func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchPosts()
    }
    
    func fetchPosts(){
        // construct query
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.whereKey("author", equalTo: PFUser.current()!)
        query.addDescendingOrder("createdAt")
        
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
                
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription ?? "error")
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
        if let image = Post.getPFFileFromImage(image: editedImage) {
            PFUser.current()!.setObject(image as PFFile, forKey: "avatar")
            PFUser.current()!.saveInBackground()
        }
        
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
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error: Error?) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSegmentedChange(_ sender: Any) {
        let index = segmentedControl.selectedSegmentIndex
        if index == 0 {
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
        } else {
            tableView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableviewSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                let feed = feeds[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.feed = feed
            }
        }
        if segue.identifier == "collectionSegue" {
            let cell = sender as! UICollectionViewCell
            if let indexPath = collectionView.indexPath(for: cell){
                let feed = feeds[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.feed = feed
            }
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
