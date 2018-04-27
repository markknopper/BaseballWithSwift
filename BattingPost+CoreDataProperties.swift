//
//  BattingPost+CoreDataProperties.swift
//  BaseballQueryStrippedTest
//
//  Created by Mark Knopper on 2/6/17.
//  Copyright © 2017 Bulbous Ventures LLC. All rights reserved.
//

import Foundation
import CoreData


extension BattingPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BattingPost> {
        return NSFetchRequest<BattingPost>(entityName: "BattingPost");
    }

    @NSManaged public var aB: NSNumber?
    @NSManaged public var bA: NSNumber?
    @NSManaged public var bB: NSNumber?
    @NSManaged public var cS: NSNumber?
    @NSManaged public var doubles_2B: NSNumber?
    @NSManaged public var g: NSNumber?
    @NSManaged public var gIDP: NSNumber?
    @NSManaged public var h: NSNumber?
    @NSManaged public var hBP: NSNumber?
    @NSManaged public var hR: NSNumber?
    @NSManaged public var iBB: NSNumber?
    @NSManaged public var lgID: String?
    @NSManaged public var playerID: String?
    @NSManaged public var r: NSNumber?
    @NSManaged public var rBI: NSNumber?
    @NSManaged public var round: String?
    @NSManaged public var sB: NSNumber?
    @NSManaged public var sF: NSNumber?
    @NSManaged public var sH: NSNumber?
    @NSManaged public var sO: NSNumber?
    @NSManaged public var teamID: String?
    @NSManaged public var triples_3B: NSNumber?
    @NSManaged public var yearID: NSNumber?
    @NSManaged public var player: Master?
    @NSManaged public var teamSeason: Teams?

}
