//
//  PhotoAlbumViewController.swift
//  BrokenPhotoAlbum
//
//  Created by Tomzach Inc. on 9/26/19.
//  Copyright © 2019 Tomzach Inc. All rights reserved.
//

import Foundation
import UIKit
import Photos
import PhotosUI

class  PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {

    
    var assets:[PHAsset]? = [PHAsset](){
        willSet{
            if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
                print("not authorized to acces photos")
                return
            }
            
            imageManager.stopCachingImagesForAllAssets()
        }
        didSet{
            if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
                print("not authorized to acces photos")
                return
            }
            
            print("Did set called")
            if let assets = assets{
                let imageOptions = PHImageRequestOptions()
                imageOptions.deliveryMode = .fastFormat
                imageOptions.progressHandler = { (progress, error, stop, info) in
                    print("progress: \(progress)")
                }
                
                imageManager.startCachingImages(for: assets, targetSize: CGSize(width: 2/3 * view.bounds.width * 0.75 , height: 2/3 * view.bounds.width * 0.75), contentMode: .aspectFill, options: nil)
            }else{
                print("Assets are nil")
            }
        }
    }
    var fetchResult: PHFetchResult<PHAsset>?
    var collectionView:UICollectionView!
    
    
    lazy var imageManager = PHCachingImageManager()
    
//    var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    
    
    var titleBar:UIView!
    var titleLabel:UILabel!
    var downArrowImageView:UIImageView!
    var mosaicLayout:MosaicLayout = MosaicLayout()
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        self.view.addSubview(titleBar)
        //UIColor(red: 56/255, green: 217/255, blue: 169/255, alpha: 1.0)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.titleBar.bounds.width/2, height: 50))
        titleBar.addSubview(titleLabel)
        
        downArrowImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.titleBar.bounds.width/2, height: 50))
        titleBar.addSubview(downArrowImageView)
   
        //New Greedo Stuff
//        let mosaicLayout = MosaicLayout()
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: self.mosaicLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        
        
        

        collectionView.register(customPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        //Add to the official project
        
//        PHPhotoLibrary.shared().register(self)
        
   
        
        setUpLayout()

        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            print("photo authorization status: \(status)")
            if status == .authorized && self.fetchResult == nil {
                print("authorized")
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                //self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                //results.enumerateObjects({asset, index, stop in
                //    self.assets.append(asset)
                //})
                var tempArr:[PHAsset] = []
                self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                guard let fetchResult = self.fetchResult else{
                    print("Fetch result is empty")
                    return
                }
                
                fetchResult.enumerateObjects({asset, index, stop in
                    tempArr.append(asset)
                })
//                self.assets = tempArr
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .fastFormat
                requestOptions.isNetworkAccessAllowed = true
                requestOptions.isSynchronous = false
                let maxCellWidth =  2 * UIScreen.main.bounds.width/3
                let targetSize = CGSize(width: maxCellWidth, height: maxCellWidth)

                self.imageManager.startCachingImages(for: tempArr, targetSize: targetSize, contentMode: .aspectFill, options: nil)
                
                tempArr.removeAll()
                print("Asset count after initial fetch: \(self.assets?.count)")
                
                DispatchQueue.main.async {
                    // Reload collection view once we've determined our Photos permissions.
                    print("inside of main queue reload")
                    PHPhotoLibrary.shared().register(self)
                    self.collectionView.delegate = self
                    self.collectionView.dataSource = self
                    self.collectionView.reloadData()
                }
            } else {
                print("photo access denied")
                self.displayPhotoAccessDeniedAlert()
            }
        }
        
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    
    func setUpLayout(){
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        titleBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        titleBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        titleBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        titleBar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        titleBar.backgroundColor = .backgroundColor
        
        collectionView.topAnchor.constraint(equalTo: self.titleBar.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.titleBar.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.titleBar.centerYAnchor, constant: 10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        titleLabel.textColor = .tileColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.text = "Photo Album"
        
        downArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        downArrowImageView.bottomAnchor.constraint(equalTo: titleBar.bottomAnchor, constant: 0).isActive = true
        downArrowImageView.centerXAnchor.constraint(equalTo: titleBar.centerXAnchor, constant: 0).isActive = true
        downArrowImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        downArrowImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        downArrowImageView.image = #imageLiteral(resourceName: "icons8-expand-arrow-96")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! customPhotoCell

        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
             return UICollectionViewCell()
        }
        
        guard let fetchResult = self.fetchResult else{
            print("Fetch Result is empty")
            return UICollectionViewCell()
        }
        
        if let requestID = cell.requestIdentifier{
            imageManager.cancelImageRequest(requestID)
        }
        
        //        let asset = assets[indexPath.item]
        let asset = fetchResult.object(at: indexPath.item)
        let assetIdentifier = asset.localIdentifier
        
        cell.representedAssetIdentifier = assetIdentifier
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        requestOptions.progressHandler = { (progress, error, stop, info) in
            print("progresss: \(progress)")
            if progress == 0.0{
              cell.startAnimator()
            } else if progress == 1.0{
              cell.endAnimator()
            }
          }
        //let scale = min(2.0, UIScreen.main.scale)
        let scale = UIScreen.main.scale * 0.75
        let targetSize = CGSize(width: cell.bounds.width * scale, height: cell.bounds.height * scale)
        

        cell.requestIdentifier = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier{
                cell.imageView.image = image
            }else{
                print("info: \(info)")
            }
        })

        
//        imageManager.requestImage(for: asset, targetSize: cell.frame.size,
//                                              contentMode: .aspectFill, options: requestOptions) { (image, hashable)  in
//                                                if let loadedImage = image, let cellIdentifier = cell.representedAssetIdentifier {
//
//                                                    // Verify that the cell still has the same asset identifier,
//                                                    // so the image in a reused cell is not overwritten.
//                                                    if cellIdentifier == assetIdentifier {
//                                                        cell.imageView.image = loadedImage
//                                                    }
//                                                }
//        }
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchResult = fetchResult, PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized else{
            return 0
        }
        return fetchResult.count
        // return self.photosAsset.count
       // print("assets.count: \(assets.count)")
       // return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item was tapped")
       
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
            return
        }
        
        guard let fetchResult = self.fetchResult else{
            print("Fetch Result is empty")
            return
        }
        let asset = fetchResult.object(at: indexPath.item)//assets[indexPath.item]
        let assetIdentifier = asset.localIdentifier
        let targetSize = UIScreen.main.bounds.size
        let image = UIImage()
//        self.previewSegueDelegate?.previewSegueDelegate(image: nil, device: nil, albumTypeSender:nil,  cameraTypeSender:nil, asset: asset)
//            self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: {(image,hashable) in
//                if let image = image{
//                    print("previewSegueDelegateCalled")
////                        self.previewSegueDelegate?.previewSegueDelegate(image: nil, device: nil, albumTypeSender:nil,  cameraTypeSender:nil, asset: asset)
//    //                     self.previewSegueDelegate?.previewSegueDelegate(image: #imageLiteral(resourceName: "85154-rininger_2.jpg"), device: nil, albumTypeSender: nil, cameraTypeSender: nil)
//                    }
//            })
       // self.previewSegueDelegate?.previewSegueDelegate(image: #imageLiteral(resourceName: "85154-rininger_2.jpg"), device: nil, albumTypeSender: nil, cameraTypeSender: nil)
    }
    
    var lastOffsetY:CGFloat = 0
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        if(scrollView.contentOffset.y > self.lastOffsetY){
//            UIView.animate(withDuration: 1.0, animations: {
//                self.collectionView.transform = CGAffineTransform(translationX: 0, y: -50)
//            }, completion: nil)
//        }
    }
    
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    

    
    private func displayPhotoAccessDeniedAlert() {
        let message = "Access to photos has been previously denied by the user. Please enable photo access for this app in Settings -> Privacy."
        let alertController = UIAlertController(title: "Photo Access",
                                                message: message,
                                                preferredStyle: .alert)
        let openSettingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openSettingsAction)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}






extension PhotoAlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized{
            print("not authorized to acces photos")
            return
        }
        
        guard let fetchResult = self.fetchResult else{
            print("Fetch Result does not exist")
            return
        }
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            
            print("Inside of dispatch main")
            
//            self.fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
//            if let removed = changes.removedIndexes, !removed.isEmpty {
//                print("removedIndexes.count: \(removed.count)")
//            }
//
//            if let inserted = changes.insertedIndexes, !inserted.isEmpty {
//                print("insertedIndexes.count: \(inserted.count)")
//            }
            
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    self.fetchResult = changes.fetchResultAfterChanges
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        print("removedIndexes.count: \(removed.count)")
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                   
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        print("insertedIndexes.count: \(inserted.count)")
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }else{
                        print("Inserted indexes is empty: \(changes.insertedIndexes), => changes: \(changes)")
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                },completion: {(completed) in
                    if completed{
                        print("completed batch updates sucessfully")
                    }else{
                        collectionView.reloadData()
                    }
                })
                
                self.fetchResult = changes.fetchResultAfterChanges
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                self.fetchResult = changes.fetchResultAfterChanges
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}



