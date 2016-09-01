//
//  Pin+CoreDataProperties.swift
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

extension Pin {

    @NSManaged var dateCreated: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var pages: NSNumber?
    @NSManaged var photos: NSSet?

}
