//
//  PhotoMapViewController.swift
//  instagram
//
//  Created by Xueying Wang on 6/27/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PhotoMapViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
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

    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var feeds :[PFObject] = []
    
    var currentFeed = PFObject(className: "Post")
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading){
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchPosts()
            }
        }
    }
    
    func fetchPosts(){
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.addDescendingOrder("createdAt")
        query.limit = 20

        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                self.feeds = posts
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let feed = feeds[indexPath.section]
        cell.instagramPost = feed
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = PFImageView(frame: CGRect(x: 10, y: 5, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        
        let feed = feeds[section]
        
        // Set the avatar
        if let avatarfile = (feed["author"] as! PFUser)["avatar"] as? PFFile {
            profileView.file = avatarfile
            profileView.loadInBackground()
        } else {
            profileView.image = UIImage(named: "profile_tab")
        }
        
        
        headerView.addSubview(profileView)
        
        let author = (feed["author"] as! PFUser).username
        let nameLabel = UILabel(frame: CGRect(x: 45, y: 5, width: 70, height: 30))
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
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
        PFUser.logOutInBackground { (error: Error?) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset.bottom = 0
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotoMapViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchPosts()
        didPullToRefresh(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
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
