//
//  Batting+Query.m
//  BaseballQuery
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
#import "StatsFormatter.h"
#import "StatHead.h"
#import "Batting+Query.h"
#import "Master+Query.h"
#import "Managers+Query.h"

@implementation Batting (Query)


-(NSString *)displayStringForStat:(NSString *)statName
{
    if ([statName isEqualToString:@"stint"]) { // first some exceptions.
        return [self displayStint];
    }
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn = [[self valueForKeyPath:statName] description];
    // However, it might need to be in thousands form. Here is the list.
    NSArray *statsNeedingToBeInThousandForm = @[@"bA",@"oBP",@"sLG",@"oPS"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    }
    return displayStringToReturn;
}

// Let's not assume that we have the teamSeason relationship here. We have enough info to get the Team object.
//-(Teams *)aTeamSeason { return self.teamSeason; }
-(Teams *)aTeamSeason {
    return [Teams teamWithTeamID:self.teamID andYear:self.yearID inManagedObjectContext:self.managedObjectContext];
}

- (NSString *) displayStint {
	NSString *displayedStint = @"-1";
	// Only display stint if there are more than one of them for this player/year.
	Master *ourMaster = self.player;
    if ([self isKindOfClass:[Managers class]]) {
        //NSLog(@"trying to get stint for a Managers object - would crash");
        return displayedStint;
    }
	if ([[ourMaster battingSeasonsForYear:self.yearID] count] > 1) displayedStint = [self.stint description]; 
	return displayedStint;
}

//
//  Appeal to rules of baseball.    For a player to be considered for the
//  batting title, they must have had a certain number of at-bats.
//
-(NSNumber *) shouldRankForBattingAverage {
	NSInteger at_bats = [self.aB integerValue];
	BOOL enough_at_bats = FALSE;
	/*
	// Loose interpretation of http://en.wikipedia.org/wiki/Batting_average
	 NSInteger year = [self.yearID integerValue];
	if ((year < 1920 && at_bats >= 90) || (year >= 1920 && year <= 1949 && at_bats >= 100) || (year >= 1950 && year <= 1956 && at_bats >= 400) || (year >= 1957 && at_bats >= 477))
		enough_at_bats = TRUE;
	 */
	if (at_bats >= 100) enough_at_bats = TRUE;
	return @(enough_at_bats);
}

-(NSString *)kindName
{
    return @"Batting";
}

@end


