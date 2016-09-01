//
//  FlickrImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/25/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

class FlickrImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flickrImageView: UIImageView!
    
    @IBOutlet weak var selectedView: UIView!
    
    var overlayView: UIView?
    
    override var selected : Bool {
        didSet {
            if overlayView == nil {
                overlayView = UIView(frame: self.flickrImageView.bounds)
                overlayView?.backgroundColor = UIColor.whiteColor()
                overlayView?.alpha = 0.5
                overlayView?.opaque = true
                self.flickrImageView.addSubview(overlayView!)
            }
            self.flickrImageView.bringSubviewToFront(overlayView!)
            if selected {
                self.overlayView?.hidden = false
            } else {
                self.overlayView?.hidden = true
            }

        }
    }
    
}
