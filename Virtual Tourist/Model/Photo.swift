//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/22/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(imageURL: String, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.dateCreated = NSDate()
            self.imageURL = imageURL
        }else{
            fatalError("Unable to find Entity Name!")
        }
    }
    
}
