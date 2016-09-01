//
//  FlickrImagesViewController.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/25/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class FlickrImagesViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var flickrImagesCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    private var blockOperations: [NSBlockOperation] = []
    
    var pin: Pin?
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController : NSFetchedResultsController? {
        didSet{
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
  
    var selectedPhotos = [Photo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if VirtualTouristManager.sharedInstance.countPhotosDownloadedForPin(pin!) > 0{
            actionButton.enabled = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(allPhotosDownloaded), name: "allPhotosDownloaded", object: nil)
        } else {
            actionButton.enabled = true
        }
        
        actionButton.setTitle("New Collection", forState: .Normal)
        
        
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0

        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(dimension, dimension)
        flickrImagesCollectionView.allowsMultipleSelection = true
        flickrImagesCollectionView.allowsSelection = true
        flickrImagesCollectionView.delegate = self
        flickrImagesCollectionView.dataSource = self
        
        if let pin = pin {
            setupMapView()
            let fr = NSFetchRequest(entityName: "Photo")
            let predicate = NSPredicate(format: "pin = %@", pin);
            fr.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]

            fr.predicate = predicate
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: pin.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        }
    }
    
    //MARK: - Photos Downloaded Notification
    func allPhotosDownloaded(notification: NSNotification)
    {        
        if let pinNotification = notification.object as? Pin {
            if pinNotification == pin! {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.actionButton.enabled = true
                })
            }
        }
    }
    
    //MARK: - Setup FetchedResultsController
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    //MARK: - Setup Map View
    func setupMapView()
    {
        let loc = CLLocationCoordinate2D(latitude: pin!.latitude!.doubleValue, longitude: pin!.longitude!.doubleValue)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: loc, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: false)
        mapView.regionThatFits(region)
    }
    
    //MARK: - Action Button
    @IBAction func actionButtonPressed(sender: UIButton)
    {
        if selectedPhotos.count > 0 {
            VirtualTouristManager.sharedInstance.removePhotos(selectedPhotos)
            actionButton.setTitle("New Collection", forState: .Normal)
            selectedPhotos.removeAll()
        } else {
            VirtualTouristManager.sharedInstance.newCollectionForPin(pin!)
            actionButton.enabled = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(allPhotosDownloaded), name: "allPhotosDownloaded", object: nil)
        }
        
    }
    
   
    
    //MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!
        }else{
            return 0
        }

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! FlickrImageCollectionViewCell
        
        let photo = fetchedResultsController!.objectAtIndexPath(indexPath) as! Photo
        
        if let photoData = photo.image {
            cell.flickrImageView.alpha = 0.0
            cell.flickrImageView.image = UIImage(data: photoData)
            cell.activityIndicator.stopAnimating()
            UIView.animateWithDuration(0.5, animations: {
                cell.flickrImageView.alpha = 1.0
            })
            
        } else {
            cell.flickrImageView.image = nil
            if !cell.activityIndicator.isAnimating() {
                cell.activityIndicator.startAnimating()
            }
        }
       
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedPhoto = fetchedResultsController?.objectAtIndexPath(indexPath) as! Photo
        selectedPhotos.append(selectedPhoto)
        actionButton.setTitle("Remove Selected Photos", forState: .Normal)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedPhoto = fetchedResultsController?.objectAtIndexPath(indexPath) as! Photo
        selectedPhotos.removeAtIndex(selectedPhotos.indexOf(selectedPhoto)!)
        if selectedPhotos.count == 0 {
            actionButton.setTitle("New Collection", forState: .Normal)
        }
    }
    
    // MARK: Deinit
    
    deinit {
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll(keepCapacity: false)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.insertItemsAtIndexPaths([newIndexPath]) }
            blockOperations.append(op)
            
        case .Update:
            guard let indexPath = indexPath else { return }
            let op = NSBlockOperation {
                [weak self] in self?.flickrImagesCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
            blockOperations.append(op)
            
        case .Move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath) }
            blockOperations.append(op)
            
        case .Delete:
            guard let indexPath = indexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.deleteItemsAtIndexPaths([indexPath]) }
            blockOperations.append(op)
            
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.insertSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        case .Update:
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.reloadSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        case .Delete:
            let op = NSBlockOperation { [weak self] in self?.flickrImagesCollectionView.deleteSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        default: break
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        flickrImagesCollectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
            }, completion: { finished in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }
    
}
