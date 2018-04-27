//
//  PitchingTotals+CoreDataClass.swift
//  BaseballWithSwift
//
//  Created by Mark Knopper on 3/8/18.
//  Copyright © 2018 Bulbous Ventures LLC. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PitchingTotals)
public class PitchingTotals: NSManagedObject {

    @objc func displayStringForStat(_ statName: String) -> String {
        var displayStringToReturn: String = ""
        let statsNeedingToBeInThousandForm = ["bAOpp","percentage"]
        if statsNeedingToBeInThousandForm.contains(statName) {
            displayStringToReturn = StatsFormatter.averageInThousandForm(for: self.value(forKey: statName) as! NSNumber)
        } else if statName=="eRA" {
            displayStringToReturn = StatsFormatter.standardERAForm(self.value(forKeyPath: statName) as! Double)
        } else if statName=="iPOuts" {
            displayStringToReturn = StatsFormatter.inningsInDecimalForm(fromInningOuts: self.value(forKeyPath: statName) as! Int)
        } else if statName == "wHIP" {
            displayStringToReturn = StatsFormatter.standardWHIPForm(self.value(forKeyPath: statName) as! Double)
        } else if statName=="seasons" {
            // This actually does a computation, ie not just a formatter. Needs to be done
            // elsewhere, ie to actually rank on seasons.
            let ourMaster = self.player
            let ourPitchingSeasons = ourMaster?.value(forKeyPath: "pitchingSeasons.@distinctUnionOfObjects.yearID") as! Set<Pitching>
            let howManyPitchingSeasons = ourPitchingSeasons.count
            displayStringToReturn = String(format: "%lu", howManyPitchingSeasons)
        }
        else if self.value(forKeyPath: statName) is NSNumber {
            // Many pitching stats are just integers, like W, L, G, GS etc.
            displayStringToReturn = (self.value(forKeyPath: statName) as! NSNumber).stringValue
        } else {
            displayStringToReturn = self.value(forKeyPath: statName) as! String
        }
        return displayStringToReturn
    }
    
}
