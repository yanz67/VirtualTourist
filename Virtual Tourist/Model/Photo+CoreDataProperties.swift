//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/30/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var dateCreated: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var imageURL: String?
    @NSManaged var pin: Pin?

}
