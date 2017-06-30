//
//  PhotoCollectionViewCell.swift
//  instagram
//
//  Created by Xueying Wang on 6/29/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: PFImageView!
    
    var instagramPost: PFObject! {
        didSet {
            self.photoView.file = instagramPost["media"] as? PFFile
            self.photoView.loadInBackground()
        }
    }
    
    
}
