//
//  VirtualTouristManager.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/22/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VirtualTouristManager: NSObject {

    static let sharedInstance = VirtualTouristManager()
    
    let stack = CoreDataStack(modelName: "VirtualTouristModel")!
    
    var mapPins = [Pin]()
    
    override init()
    {
        super.init()
        getAllPins()
        resumePhotoDownload()
    }
    
    //MARK: appdelegate functions
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        return true;
        
    }
    
    
    func addMapPin(coord: CLLocationCoordinate2D) -> Bool
    {
        let  pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: VirtualTouristManager.sharedInstance.stack.context)
    
        mapPins.append(pin)
        saveModel()
        
        loadFlickrPhotosForPin(pin)
        
        return true
    }
    
    private func loadFlickrPhotosForPin(pin: Pin)
    {
        FlickrClientManager.sharedInstance.getListFlickrPhotosForPin(pin) { (result, error) in
            if error == nil {
                self.addFlickrPhotos(result, forPin: pin)
                self.downloadFlickrPhotosForPin(pin)
            }
        }
    }
    
    
    func newCollectionForPin(pin: Pin)
    {
        for photo in pin.photos! {
            stack.context.deleteObject(photo as! NSManagedObject)
        }
        
        do{
            try stack.saveContext()
        }catch let error as NSError{
            print("couldn't save model \(error.userInfo)")
        }
        
        loadFlickrPhotosForPin(pin)
    }
    
    private func addFlickrPhotos(flickrPhotos: AnyObject, forPin pin: Pin)
    {
        let imagesDict = flickrPhotos["photos"]! as! [String : AnyObject]
        let numPages = imagesDict["pages"] as! NSNumber
        pin.pages = numPages
        let imagesArray = imagesDict["photo"]!
        for imageDict in imagesArray as! Array<[String : AnyObject]> {
            let imageURL = FlickrClientManager.sharedInstance.getImageURL(imageDict)
            let photo = Photo(imageURL: imageURL, context: stack.context)
            photo.pin = pin
        }
       
        saveModel()
    }
    
    func downloadFlickrPhotosForPin(pin: Pin)
    {
        guard pin.managedObjectContext != nil else {
            return
        }
        
        guard pin.photos != nil else {
            return
        }
        
        guard pin.photos?.count > 0 else {
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("allPhotosDownloaded", object: pin)
            return
        }
        
        for photo in pin.photos!{
            let currentPhoto = photo as! Photo
            if currentPhoto.image == nil {
                FlickrClientManager.sharedInstance.downloadFlickrImageFromURL(currentPhoto.imageURL!, completionHandlerForDownloadFlickrImage: { (data, response, error) in
                    if error == nil && data != nil{
                        currentPhoto.image = data
                        if self.countPhotosDownloadedForPin(pin) == 0 {
                            let nc = NSNotificationCenter.defaultCenter()
                            nc.postNotificationName("allPhotosDownloaded", object: pin)
                        }
                    }
                    
                })
            }
        }
    }

    func countPhotosDownloadedForPin(pin: Pin) -> Int
    {
        let fr = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "image = nil && pin = %@", pin);
        fr.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        fr.predicate = predicate
        let error: NSErrorPointer = nil
        let count  = stack.context.countForFetchRequest(fr, error: error)
        if (error != nil){
            print("couldn't retrieve count for downloded images")
        }
        return count
    }
    
    private func getAllPins()
    {
        let fr = NSFetchRequest(entityName: "Pin")
        do {
            mapPins = try stack.context.executeFetchRequest(fr) as! [Pin]
        } catch {
          print("Cannot fetch from Pin Entity")
        }
        
    }
    
    private func resumePhotoDownload()
    {
        let fr = NSFetchRequest(entityName: "Pin")
        let predicate = NSPredicate(format: "ANY photos.image = nil")
        fr.predicate = predicate
        do {
            let pinsToProcess = try stack.context.executeFetchRequest(fr) as! [Pin]
            for pin in pinsToProcess {
                downloadFlickrPhotosForPin(pin)
            }
            
        } catch {
            print("Cannot fetch from Pin Entity")
        }
        
    }
    
    func getMapPinAtIndex(index: Int) -> Pin?
    {
        guard index >= 0 && index < mapPins.count else {
            return nil
        }
        return mapPins[index]
    }
    
    func removePinAtIndex(index: Int)
    {
        guard index >= 0 && index < mapPins.count else{
            return
        }
        let pin = mapPins.removeAtIndex(index)
        stack.context.deleteObject(pin)
        saveModel()

    }
    
    func mapPinsCount() -> Int
    {
        return mapPins.count
    }
    
    func removePhotos(photos: [Photo])
    {
        for photo in photos {
            stack.context.deleteObject(photo)
        }
        saveModel()
    }

    
    private func saveModel()
    {
        do{
            try stack.saveContext()
        }catch let error as NSError{
            print("couldn't save model \(error.userInfo)")
        }
    }
}