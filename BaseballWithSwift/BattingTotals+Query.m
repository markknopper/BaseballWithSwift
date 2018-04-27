//
//  BattingTotals+Query.m
//  BaseballQuery
//
//  Created by Mark Knopper on 6/21/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BattingTotals+Query.h"
#import "StatsFormatter.h"
#import "Master+Query.h"

@implementation BattingTotals (Query)

-(NSString *)displayStringForStat:(NSString *)statName
{
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn;
    // However, it might need to be in thousands form. Here is the list.
    NSArray *statsNeedingToBeInThousandForm = @[@"bA",@"oBP",@"sLG",@"oPS"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    } else if ([statName isEqualToString:@"seasons"]) {
        displayStringToReturn = [NSString stringWithFormat:@"%lu",(unsigned long)[(NSArray *)[(Master *)self.player valueForKeyPath:@"battingSeasons.@distinctUnionOfObjects.yearID"] count]];
    } else
       displayStringToReturn = [[self valueForKeyPath:statName] description];
    return displayStringToReturn;
}

@end