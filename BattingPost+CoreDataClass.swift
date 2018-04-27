//
//  BattingPost+CoreDataClass.swift
//  BaseballQueryStrippedTest
//
//  Created by Mark Knopper on 2/6/17.
//  Copyright © 2017 Bulbous Ventures LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(BattingPost)
public class BattingPost: NSManagedObject {

    @objc func displayStringForStat(_ forStat: String) -> String {
        if forStat == "aTeamName" {
            return self.aTeamName()
        }
        // Initial assumption is that its just a regular number.
        var displayStringToReturn = (self.value(forKey: forStat) as! NSObject).description
        // However, it might need to be in thousands form. Here is the list.
        let statsNeedingToBeInThousandForm = ["bA","oBP","sLG","oPS"]
        // Maybe it should be convertToThousandFormIfNecessary(statname, value) ***
        if statsNeedingToBeInThousandForm.contains(forStat) {
            displayStringToReturn = StatsFormatter.averageInThousandForm(for: self.value(forKey: forStat) as! NSNumber?)        }
        return displayStringToReturn
    }
    
    func aTeamName() -> String {
        let teamName = StatHead.teamName(fromTeamID: self.value(forKey: "teamID") as! String, andYear: self.value(forKey: "yearID") as! NSNumber, managedObjectContext: self.managedObjectContext)
        return teamName!
    }

}
