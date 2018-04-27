//
//  Pitching+CoreDataClass.swift
//  BaseballWithSwift
//
//  Created by Mark Knopper on 3/8/18.
//  Copyright © 2018 Bulbous Ventures LLC. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pitching)
public class Pitching: NSManagedObject {

    @objc func aTeamSeason() -> Teams {
        return self.teamSeason!
    }
    
    @objc func displayStint() -> String {
        var displayedStint: String
        // Only display stint if there are more than one of them for this player/year.
        let ourMaster = self.player
        if (ourMaster?.pitchingSeasons(forYear: self.yearID).count)! > 1 {
            displayedStint = (self.stint?.description)!
        } else {
            displayedStint = "-1"
        }
        return displayedStint
    }
    
    //   TODO Beef this up, because the rules are different for starter,
    //   reliever, setup, and closer.   For now, we'll just let it be simple
    //   and add more to it as we more sophistication.
    @objc func shouldRankForERA() -> NSNumber {
        return NSNumber(value: StatHead.enoughOutsPitched(forERARank: self.iPOuts))
    }
    
    @objc func pitcherKind() -> String {
        return StatHead.pitcherKindDeduced(fromGames: self.g, starts: self.gS, saves: self.sV)
    }
    
    @objc func displayStringForStat(_ statName: String) -> String {
        if statName=="stint" { // first some exceptions.
            return self.displayStint()
        }
        // Initial assumption is that its just a regular number.
        var displayStringToReturn = self.value(forKeyPath: statName)  // .description not needed? ***
        // However, it might need to be in thousands form. Here is the list.
        let statsNeedingToBeInThousandForm = ["wHIP","bAOpp"]
        if statsNeedingToBeInThousandForm.contains(statName) {
            displayStringToReturn = StatsFormatter.averageInThousandForm(for: self.value(forKey: statName) as! NSNumber)
        } else if statName=="eRA" {
            // Wouldn't have been necessary except for *.00 ERA's need to be formatted with decimal digits. E.g. 4.00 rather than 4
            displayStringToReturn = StatsFormatter.standardERAForm((self.value(forKeyPath: statName) as! NSNumber).doubleValue)
        } else if statName=="iPOuts" {
            displayStringToReturn = StatsFormatter.inningsInDecimalForm(fromInningOuts: (self.value(forKey: statName) as! NSNumber).intValue)
        } else if statName=="percentage" {
            let total_W =  self.w?.intValue
            let total_L = self.l?.intValue
            var total_percentage = Float(0.0)
            if (total_W! + total_L! > 0) {
                total_percentage = (1000.0 * ((Float(total_W!)/(Float(total_W!)+Float(total_L!))+0.0005)))
            }
            displayStringToReturn = StatsFormatter.percentagePadded(toFiveChars: Int(total_percentage))
        }
        if displayStringToReturn! is NSNumber {
            displayStringToReturn = (displayStringToReturn as! NSNumber).stringValue
        }
        return displayStringToReturn as! String
    }

    @objc func kindName() -> String {
        return "Pitching"
    }
    
}
