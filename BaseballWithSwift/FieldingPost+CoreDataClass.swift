//
//  FieldingPost+CoreDataClass.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 1/25/17.
//  Copyright © 2017-2018 Bulbous Ventures LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(FieldingPost)
public class FieldingPost: NSManagedObject {
    
    @objc func displayStringForStat(_ forStat: String) -> String {
        if forStat == "aTeamName" {
            return self.aTeamName()
        }
        // Initial assumption is that its just a regular number.
        var displayStringToReturn = (self.value(forKey: forStat) as! NSObject).description 
        // However, it might need to be in thousands form. Here is the list.
        let statsNeedingToBeInThousandForm = ["fPct"]
        if statsNeedingToBeInThousandForm.contains(forStat) {
            displayStringToReturn = StatsFormatter.averageInThousandForm(for: self.value(forKey: forStat) as! NSNumber?)
        }
        return displayStringToReturn
    }
    
    func aTeamName() -> String {
        let teamName = StatHead.teamName(fromTeamID: self.value(forKey: "teamID") as! String, andYear: self.value(forKey: "yearID") as! NSNumber, managedObjectContext: self.managedObjectContext)
        return teamName!
    }

}
