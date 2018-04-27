//
//  Parks+CoreDataProperties.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 3/3/16.
//  Copyright © 2016 Bulbous Ventures LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Parks {

    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var parkAlias: String?
    @NSManaged var parkKey: String?
    @NSManaged var parkName: String?
    @NSManaged var state: String?

}
