//
//  FlickrClientManager.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/18/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation

class FlickrClientManager
{
    //MARK: - Initilization
    static let sharedInstance = FlickrClientManager()
 
    var session = NSURLSession.sharedSession()
    
    private init()
    {
        //super.init()
    }
    
    
    func getListFlickrPhotosForPin(pin: Pin!, completionHandlerForGetListFlickrPhotosForLocation: (result: AnyObject!, error: NSError?) -> Void)
    {
        var parameters: [String : AnyObject] = [FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod, FlickrParameterKeys.Latitude : pin.latitude!, FlickrParameterKeys.Longitude : pin.longitude!, FlickrParameterKeys.Accuracy : FlickrParameterValues.Accuracy]
        
        //Will randomize the page that is returned for flicker to get new collections
        if pin.pages != nil {
            let randomPage = Int(arc4random_uniform(UInt32((min((pin.pages?.intValue)!,Int32(30)))))) + 1
            parameters[FlickrParameterKeys.Page] = randomPage
        }
                
        taskForGetMethod(nil, parameters: parameters, completionHanderForGet: completionHandlerForGetListFlickrPhotosForLocation)
        
    }
   
    func getListFlickrPhotosForLocation(lat: Double!, long: Double!, completionHandlerForGetListFlickrPhotosForLocation: (result: AnyObject!, error: NSError?) -> Void)
    {
        let parameters = [FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod, FlickrParameterKeys.Latitude : lat, FlickrParameterKeys.Longitude : long]
        
        taskForGetMethod(nil, parameters: parameters as? [String : AnyObject], completionHanderForGet: completionHandlerForGetListFlickrPhotosForLocation)
        
    }
    
    func getImageURL(flickrImageDict: [String : AnyObject]) -> String
    {
        let imageURL = "https://farm\(flickrImageDict[FlickrImageParameterKeys.FarmID]!).staticflickr.com/\(flickrImageDict[FlickrImageParameterKeys.ServerID]!)/\(flickrImageDict[FlickrImageParameterKeys.ImageID]!)_\(flickrImageDict[FlickrImageParameterKeys.Secret]!)_z.jpg"
        return imageURL
    }

}


//MARK: Network Convinience Methods

extension FlickrClientManager
{
    // MARK: Network Convinience Methods
    
    func taskForGetMethod(method: String?, parameters: [String : AnyObject]?, completionHanderForGet: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask
    {
        let request = NSMutableURLRequest(URL: flickrURLFromParameters(parameters, withPathExtension: method))
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHanderForGet(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                sendError("Your Request returned a status code other then 2xx!")
                return
            }
            
            guard data != nil else{
                sendError("No data was returned by the request")
                return
            }
            
            self.convertDataWithCompletionHander(data!, completionHanderForConvertData: completionHanderForGet)
            
        
        }
        
        task.resume()
        return task
    }
    
    
    
    
    private func flickrURLFromParameters(parameters: [String : AnyObject]?, withPathExtension: String? = nil) -> NSURL
    {
        let components = NSURLComponents()
        
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.API_KEY, value: FlickrParameterValues.API_KEY))
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.NoJSONCallBack, value: FlickrParameterValues.NoJSONCallBack))
         components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.Format, value: FlickrParameterValues.Format))
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.LimitPerPage, value: FlickrParameterValues.LimitPerPage))
        

        if let parameters = parameters {
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        
        return components.URL!
    }
    
    func downloadFlickrImageFromURL(url: String, completionHandlerForDownloadFlickrImage:(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)
    {
        let imageURL = NSURL(string: url)
        
        NSURLSession.sharedSession().dataTaskWithURL(imageURL!) { (data, response, error) in
            
            completionHandlerForDownloadFlickrImage(data: data,response: response, error: error)
        
        }.resume()
        
    }

    private func convertDataWithCompletionHander(data: NSData, completionHanderForConvertData:(resutl: AnyObject!, error: NSError?) -> Void)
    {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse data as JSON: '\(data)'"]
            completionHanderForConvertData(resutl: nil, error: NSError(domain: "convertDataWithCompletionHander", code: 1, userInfo: userInfo))
        }
        
        completionHanderForConvertData(resutl: parsedResult, error: nil)
    }
    

}