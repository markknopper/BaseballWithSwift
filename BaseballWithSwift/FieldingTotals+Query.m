//
//  FieldingTotals+Query.m
//  BaseballQuery
//
//  Created by Mark Knopper on 6/21/14.
//  Copyright (c) 2014-2018 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FieldingTotals+Query.h"
#import "StatsFormatter.h"
#import "Master+Query.h"

@implementation FieldingTotals (Query)

-(NSString *)displayStringForStat:(NSString *)statName
{
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn;
    // However, it might need to be in thousands form. Here is the list.
    NSArray *statsNeedingToBeInThousandForm = @[@"fPct"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    } else if ([statName isEqualToString:@"innOuts"]) {
        displayStringToReturn = [StatsFormatter inningsInDecimalFormFromInningOuts:[[self valueForKey:statName] integerValue]];
    } else
       displayStringToReturn = [[self valueForKeyPath:statName] description];
    return displayStringToReturn;
}

@end
