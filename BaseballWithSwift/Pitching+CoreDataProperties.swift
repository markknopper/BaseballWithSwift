//
//  Pitching+CoreDataProperties.swift
//  BaseballWithSwift
//
//  Created by Mark Knopper on 3/8/18.
//  Copyright © 2018 Bulbous Ventures LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Pitching {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pitching> {
        return NSFetchRequest<Pitching>(entityName: "Pitching")
    }

    @NSManaged public var bAOpp: NSNumber?
    @NSManaged public var bB: NSNumber?
    @NSManaged public var bFP: NSNumber?
    @NSManaged public var bK: NSNumber?
    @NSManaged public var cG: NSNumber?
    @NSManaged public var eR: NSNumber?
    @NSManaged public var eRA: NSNumber?
    @NSManaged public var g: NSNumber?
    @NSManaged public var gF: NSNumber?
    @NSManaged public var gIDP: NSNumber?
    @NSManaged public var gS: NSNumber?
    @NSManaged public var h: NSNumber?
    @NSManaged public var hBP: NSNumber?
    @NSManaged public var hR: NSNumber?
    @NSManaged public var iBB: NSNumber?
    @NSManaged public var iPOuts: NSNumber?
    @NSManaged public var l: NSNumber?
    @NSManaged public var lgID: String?
    @NSManaged public var percentage: NSNumber?
    @NSManaged public var playerID: String?
    @NSManaged public var r: NSNumber?
    @NSManaged public var sF: NSNumber?
    @NSManaged public var sH: NSNumber?
    @NSManaged public var sHO: NSNumber?
    @NSManaged public var sO: NSNumber?
    @NSManaged public var stint: NSNumber?
    @NSManaged public var sV: NSNumber?
    @NSManaged public var teamID: String?
    @NSManaged public var w: NSNumber?
    @NSManaged public var wHIP: NSNumber?
    @NSManaged public var wP: NSNumber?
    @NSManaged public var yearID: NSNumber?
    @NSManaged public var player: Master?
    @NSManaged public var teamSeason: Teams?

}
