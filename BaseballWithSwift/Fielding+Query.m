//
//  Fielding+Query.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/15/10.
//  Copyright 2010-14 Bulbous Ventures LLC. All rights reserved.
//

#import "Fielding+Query.h"
#import "StatsFormatter.h"
#import "StatHead.h"
#import "Master+Query.h"

@implementation Fielding (Query)

-(NSString *)displayStringForStat:(NSString *)statName
{
    if ([statName isEqualToString:@"stint"]) { // first some exceptions.
        return [self displayStint];
    }
    if ([statName isEqualToString:@"innOuts"]) { // first some exceptions.
        return [self displayInnings];
    }
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn = [[self valueForKeyPath:statName] description];
    // However, it might need to be in thousands form. Here is the list.
    NSArray *statsNeedingToBeInThousandForm = @[@"fPct"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    }
    return displayStringToReturn;
}

-(BOOL)justSayNoToRanking
{
    return FALSE; // Set in StatsDisplayFactory eg. for Position.
}

- (NSString *)displayInnings { return [[StatsFormatter inningsInDecimalFormFromInningOuts:[self.innOuts integerValue]] description]; }

- (NSString *)displayStint
{
	NSString *displayedStint = [self.stint description];
	if ([self.stint integerValue] == 1) {
		// If there is just one stint, don't display it.
		Master *ourMaster = self.player;
		NSArray *ourFieldingRecordsThisYear = [ourMaster fieldingRecordsForYear:self.yearID];
		for (Fielding *thisFieldingRecord in ourFieldingRecordsThisYear) {
			// Check for any fielding records for this year with non-one stint.
			if ([thisFieldingRecord.stint integerValue] > 1) {
				return displayedStint; // There is more than one stint.
			}
		}
		displayedStint = @"-1";
	}
	return displayedStint;
}

- (Teams *)aTeamSeason { return self.teamSeason; }

-(NSString *)kindName {return @"Fielding"; }

@end
