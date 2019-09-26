//
//  CustomPhotoAlbumCell.swift
//  BrokenPhotoAlbum
//
//  Created by Tomzach Inc. on 9/26/19.
//  Copyright © 2019 Tomzach Inc. All rights reserved.
//

import Foundation
import Photos
import UIKit
class customPhotoCell:UICollectionViewCell{
    
    var activityIndicator:UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        return activityIndicator
    }()
    
    var representedAssetIdentifier: String!
    var requestIdentifier:PHImageRequestID!
    
    var imageView:UIImageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("Inside of init")
        
         layer.shouldRasterize = true
         layer.rasterizationScale = UIScreen.main.scale
         isOpaque = true
        
        imageView.backgroundColor = .orange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
        
        self.layer.cornerRadius = 10.0
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
//        self.addSubview(activityIndicator)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
         imageView.image = nil
         representedAssetIdentifier = ""
         requestIdentifier = nil
         activityIndicator.isHidden = true
         activityIndicator.stopAnimating()
    }
    
    /// Shows The Activity Indicator When Downloading From The Cloud
    func startAnimator(){
      DispatchQueue.main.async {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
      }
    }


    /// Hides The Activity Indicator After The ICloud Asset Has Downloaded
    func endAnimator(){
      DispatchQueue.main.async {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
      }
    }
    
    
}
