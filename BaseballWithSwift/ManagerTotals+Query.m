//
//  ManagerTotals+Query.m
//  BaseballQuery
//
//  Created by Mark Knopper on 6/21/14.
//  Copyright (c) 2014-2017 Bulbous Ventures LLC. All rights reserved.
//

@import Foundation;
#import "ManagerTotals+Query.h"
#import "StatsFormatter.h"
#import "Master+Query.h"

@implementation ManagerTotals (Query)

-(NSString *)displayStringForStat:(NSString *)statName
{
    NSString *displayStringToReturn = nil;
    if ([statName isEqualToString:@"seasons"]) {
        //displayStringToReturn = [NSString stringWithFormat:@"%lu",(unsigned long)[(NSArray *)[(Master *)self.player valueForKeyPath:@"battingSeasons.@distinctUnionOfObjects.yearID"] count]];
        displayStringToReturn = [NSString stringWithFormat:@"%lu",(unsigned long)[(NSArray *)[(Master *)self.player valueForKeyPath:@"managerSeasons.@distinctUnionOfObjects.yearID"] count]];
    } else if ([statName isEqualToString:@"percentage"]) {
        NSInteger total_W = [self.w integerValue];
        NSInteger total_L = [self.l integerValue];
        CGFloat total_percentage = 0;
        if (total_W + total_L > 0) total_percentage = (1000.0*(((float)total_W/((float)total_W+(float)total_L))+.0005));
        // Need rounded value for displaying.
         displayStringToReturn = [StatsFormatter percentagePaddedToFiveChars:total_percentage];
    } else
        displayStringToReturn =[[self valueForKeyPath:statName] description];
    return displayStringToReturn;
}

-(NSNumber *)percentage
{
    NSInteger total_W = [self.w integerValue];
    NSInteger total_L = [self.l integerValue];
    CGFloat total_percentage = 0;
    // Don't round this.
    if (total_W + total_L > 0) total_percentage = (float)total_W/((float)total_W+(float)total_L);
    return [NSNumber numberWithFloat:total_percentage];
}

@end

