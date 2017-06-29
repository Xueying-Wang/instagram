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
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var feeds :[PFObject] = []
    
    var currentFeed = PFObject(className: "Post")
    
    func fetchPosts(){
        var query = PFQuery(className: "Post")
        query.includeKey("author")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.feeds = posts
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription)
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
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        let feed = feeds[section]
        profileView.image = UIImage(named: "profile_tab")
        headerView.addSubview(profileView)
        
        let author = (feed["author"] as! PFUser).username
        let nameLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 70, height: 30))
        nameLabel.text = author
        nameLabel.textColor = UIColor.black

        headerView.addSubview(nameLabel)
        
        let time = (feed.createdAt!).description
        let index = time.index(time.startIndex, offsetBy: 10)
        let date = time.substring(to: index)
        let dateLabel = UILabel(frame: CGRect(x: 140, y: 10, width: 150, height: 30))
        dateLabel.text = "Date: " + date
        dateLabel.textColor = UIColor.black
        dateLabel.font = UIFont (name: "HelveticaNeue-Light", size: 15)
        headerView.addSubview(dateLabel)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        // let label = ...
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchPosts()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error: Error?) in
            self.feeds = []
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell){
            let feed = feeds[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.feed = feed
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
