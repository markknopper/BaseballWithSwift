//
//  FieldingPost+CoreDataProperties.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 1/25/17.
//  Copyright © 2017 Bulbous Ventures LLC. All rights reserved.
//

import Foundation
import CoreData


extension FieldingPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FieldingPost> {
        return NSFetchRequest<FieldingPost>(entityName: "FieldingPost");
    }

    @NSManaged public var a: NSNumber?
    @NSManaged public var cS: NSNumber?
    @NSManaged public var dP: NSNumber?
    @NSManaged public var e: NSNumber?
    @NSManaged public var fPct: NSNumber?
    @NSManaged public var g: NSNumber?
    @NSManaged public var gS: NSNumber?
    @NSManaged public var innOuts: NSNumber?
    @NSManaged public var lgID: String?
    @NSManaged public var pB: NSNumber?
    @NSManaged public var playerID: String?
    @NSManaged public var pO: NSNumber?
    @NSManaged public var pos: String?
    @NSManaged public var round: String?
    @NSManaged public var sB: NSNumber?
    @NSManaged public var teamID: String?
    @NSManaged public var tP: NSNumber?
    @NSManaged public var yearID: NSNumber?
    @NSManaged public var player: Master?
    @NSManaged public var teamSeason: Teams?

}
