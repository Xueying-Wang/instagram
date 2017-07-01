//
//  SearchViewController.swift
//  instagram
//
//  Created by Xueying Wang on 6/29/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    class InfiniteScrollActivityView: UIView {
        var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        static let defaultHeight:CGFloat = 40.0
        
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
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var refreshControl: UIRefreshControl!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var feeds: [PFObject] = []
    
    var filteredFeeds: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 64)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        collectionView.addSubview(loadingMoreView!)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 4
        layout.minimumInteritemSpacing = 1
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width)
        
        
        // Setup Search bar
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 340, height: 200))
        searchBar.delegate = self
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        navigationItem.leftBarButtonItem = leftNavBarButton
        
        fetchPosts()
        collectionView.reloadData()
        didPullToRefresh(refreshControl)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFeeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        let feed = filteredFeeds[indexPath.item]
        cell.instagramPost = feed
        return cell
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchPosts()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading){
            let scrollViewContentHeight = collectionView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchPosts()
            }
        }
    }
    
    
    func fetchPosts(){
        // construct query
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView?.stopAnimating()
                
                self.feeds = posts
                self.filteredFeeds = posts
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if (kind == UICollectionElementKindSectionHeader) {
//            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchHeader", for: indexPath)
//            
//            return headerView
//        }
//        
//        return UICollectionReusableView()
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFeeds = self.feeds
        if !searchText.isEmpty {
            filteredFeeds = []
            for feed in self.feeds {
                let author = (feed["author"] as! PFUser).username
                let caption = feed["caption"] as? String ?? ""
                if author?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                    filteredFeeds.append(feed)
                } else if caption.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                    filteredFeeds.append(feed)
                }
            }
        }
        
            self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        filteredFeeds = self.feeds
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filteredFeeds = self.feeds
        searchBar.resignFirstResponder()
        self.collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell){
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
