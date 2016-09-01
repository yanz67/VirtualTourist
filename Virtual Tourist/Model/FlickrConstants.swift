//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/18/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

extension FlickrClientManager
{
    struct Constants
    {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct FlickrParameterKeys
    {
        static let Method = "method"
        static let API_KEY = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let LimitPerPage = "per_page"
        static let Page = "page"
        static let Accuracy = "accuracy"
    }
    
    struct FlickrParameterValues
    {
        static let SearchMethod = "flickr.photos.search"
        static let API_KEY = "532f72195edd7c284733fb888c464a2d"
        static let Format = "json"
        static let NoJSONCallBack = "1"
        static let LimitPerPage = "27"
        static let Page = "10"
        static let Accuracy = "12"
    }
    
    struct FlickrImageParameterKeys
    {
        static let FarmID = "farm"
        static let ImageID = "id"
        static let ServerID = "server"
        static let Secret = "secret"
    }
    
    
}
