//
//  FlickrMapViewController.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import MapKit

class FlickrMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var flickrMapView: MKMapView!
    
    @IBOutlet weak var flickrMapBottomConstraint: NSLayoutConstraint!
    
    var annotations = [MKPointAnnotation]()
    var isEditingPins = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrMapView.delegate = self
        reloadPins()
    }
    
    
    //MARK: - Loading Pins
    func reloadPins()
    {
        flickrMapView.removeAnnotations(annotations)
        annotations.removeAll()
        guard VirtualTouristManager.sharedInstance.mapPinsCount() != 0 else {
            return
        }
        for index in 0...VirtualTouristManager.sharedInstance.mapPinsCount()-1 {
            let lat = CLLocationDegrees(VirtualTouristManager.sharedInstance.getMapPinAtIndex(index)!.latitude!)
            let long = CLLocationDegrees(VirtualTouristManager.sharedInstance.getMapPinAtIndex(index)!.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.flickrMapView.addAnnotations(self.annotations)
    }

    
    @IBAction func hangleLongPress(getstureRecognizer: UILongPressGestureRecognizer) {
        
        if !isEditingPins {
            if getstureRecognizer.state != .Began { return }
            
            let touchPoint = getstureRecognizer.locationInView(flickrMapView)
            let touchMapCoordinate = flickrMapView.convertPoint(touchPoint, toCoordinateFromView: flickrMapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            
            flickrMapView.addAnnotation(annotation)
            VirtualTouristManager.sharedInstance.addMapPin(touchMapCoordinate)
            annotations.append(annotation)
        }
    }
    
    //MARK - Editing Pins

    
    @IBAction func editPins(sender: UIBarButtonItem) {
        if isEditingPins {
            hideDeleteButton()
        }else {
            showDeleteButton()
        }
        
    }
    
    func showDeleteButton()
    {
        view.removeConstraint(flickrMapBottomConstraint)
        flickrMapBottomConstraint = NSLayoutConstraint(item: flickrMapView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -60)
        self.view.addConstraint(self.flickrMapBottomConstraint)
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        isEditingPins = true
    }
    
    func hideDeleteButton()
    {
        view.removeConstraint(flickrMapBottomConstraint)
        flickrMapBottomConstraint = NSLayoutConstraint(item: flickrMapView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(flickrMapBottomConstraint)
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        isEditingPins = false
        
    }
    
    //MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let selectedAnnotation = mapView.selectedAnnotations.first as! MKPointAnnotation
        guard let index = annotations.indexOf(selectedAnnotation) else {
            return
        }

        if isEditingPins {
            VirtualTouristManager.sharedInstance.removePinAtIndex(index)
            self.flickrMapView.removeAnnotation(selectedAnnotation)
        } else {
            
            mapView.deselectAnnotation(selectedAnnotation, animated: true)
            if let mapPin = VirtualTouristManager.sharedInstance.getMapPinAtIndex(index) {
                performSegueWithIdentifier("showFlickrImages", sender: mapPin)
            }
        }
        
        
    }
    
    
    //MARK: - Prepare For Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFlickrImages" {
            let vc = segue.destinationViewController as! FlickrImagesViewController
            let pin = sender as? Pin
            vc.pin = pin
        }
    }
    
}