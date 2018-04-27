//
//  Manager+Query.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/2/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//
//@import CoreGraphics;

#import "Managers+Query.h"
#import "StatsFormatter.h"

@implementation Managers (Query)

-(NSString *)displayStringForStat:(NSString *)statName
{
    NSString *displayStringToReturn = nil;
    NSArray *statsNeedingToBeInThousandForm = @[@"fPct"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    } else if ([statName isEqualToString:@"percentage"]) {
        NSInteger total_W = [self.w integerValue];
        NSInteger total_L = [self.l integerValue];
        CGFloat total_percentage = 0;
        if (total_W + total_L > 0) total_percentage = (1000.0*(((float)total_W/((float)total_W+(float)total_L))+.0005));
        displayStringToReturn = [StatsFormatter percentagePaddedToFiveChars:total_percentage];
    } else if ([statName isEqualToString:@"plyrMgr"]) {
        displayStringToReturn = ([[self valueForKey:statName] boolValue] == TRUE) ? @"Yes" : @"No";
    } else
        displayStringToReturn = [[self valueForKeyPath:statName] description];
    return displayStringToReturn;
}

-(NSString *)percentage
{
    NSInteger total_W = [self.w integerValue];
    NSInteger total_L = [self.l integerValue];
    CGFloat total_percentage = 0;
    if (total_W + total_L > 0) total_percentage = (1000.0*(((float)total_W/((float)total_W+(float)total_L))+.0005));
    return [StatsFormatter percentagePaddedToFiveChars:total_percentage];
}

-(Teams *)aTeamSeason { return self.teamSeason; }

-(NSString *)kindName { return @"Managers"; }

@end
