//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/22/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(latitude: NSNumber, longitude: NSNumber, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
            self.dateCreated = NSDate()
        }else{
            fatalError("Unable to find Entity Name!")
        }
    }

}
