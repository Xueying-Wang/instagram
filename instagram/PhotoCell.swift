//
//  PhotoCell.swift
//  instagram
//
//  Created by Xueying Wang on 6/27/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoView: PFImageView!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    
    var instagramPost: PFObject! {
        didSet {
            self.photoView.file = instagramPost["media"] as? PFFile
            self.photoView.loadInBackground()
            self.captionLabel.text = instagramPost["caption"] as? String
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
