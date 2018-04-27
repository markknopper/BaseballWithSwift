//
//  Teams+Query.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/12/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//

#import "StatsFormatter.h"
#import "StatHead.h"
#import "Teams+Query.h"
#import "Master.h"
#import "NSArray+BV.h"
#import "BQPlayer.h"

@implementation Teams (Query)

@dynamic oPS;

-(NSString *)displayStringForStat:(NSString *)statName statType:(StatsDisplayStatType)stat_type
{
    return [self displayStringForStat:statName];
}

-(NSString *)displayStringForStat:(NSString *)statName
{
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn = [[self valueForKey:statName] description];
    // However, it might need to be in thousands form. Here is the list.
    NSArray *statsNeedingToBeInThousandForm = @[@"eRA",@"fPct",@"oBP",@"oPS",@"sLG",@"bA",@"percentage"];
    if ([statsNeedingToBeInThousandForm containsObject:statName]) {
        displayStringToReturn = [StatsFormatter averageInThousandFormForNSNumber:[self valueForKey:statName]];
    } else if ([statName isEqualToString:@"attendance"]) {
        // Needs to be in comma form.
        displayStringToReturn = [StatsFormatter largeNumberInCommaFormWithNSNumber:self.attendance];
    } else if ([statName isEqualToString:@"iPOuts"]) {
        displayStringToReturn = [StatsFormatter inningsInDecimalFormFromInningOuts:[self.iPOuts integerValue]];
    }
    return displayStringToReturn;
}

-(NSNumber *)oPS
{
    return [NSNumber numberWithFloat:[self.oBP floatValue] + [self.sLG floatValue]];
}

//
//  Return a sorted array of the entire roster for this year's team.
//  This is a potentially expensive operation, so it should not be done
//  repeatedly.  (for example, do it in viewDidLoad and not in viewWillAppear
//  if possible).
//  *** This is pretty slow (up to 2 seconds) but it is *way* faster than doing our
//  *** own fetches rather than following relationships. 
//
//  This function creates a Player object for each member of the team, and
//  that creation loads the stats for each player.   To the extent that the players
//  are each lazily initialized, we still preserve lazy initialization.
//
- (NSArray *)rosterInNameOrder {
	NSMutableSet *allMasters = [[NSMutableSet alloc] init];
    // These lines cause a fault to fire, and trip to database, for each player.
    [allMasters setSet:[self.batters valueForKey:@"player"]];
	[allMasters unionSet:[self.pitchers valueForKey:@"player"]];
	[allMasters unionSet:[self.fielders valueForKey:@"player"]];
	[allMasters unionSet:[self.managers valueForKey:@"player"]];
	NSSortDescriptor *byLastName = [[NSSortDescriptor alloc] initWithKey:@"nameLast" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSSortDescriptor *byFirstName = [[NSSortDescriptor alloc] initWithKey:@"nameFirst" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = @[byLastName, byFirstName];
	
	NSArray *playerMasters = [[allMasters allObjects] sortedArrayUsingDescriptors:sortDescriptors];
	NSMutableArray *rosterPlayers = [[NSMutableArray alloc] initWithCapacity:[playerMasters count]];
	for (Master *eachPlayer in playerMasters) {
		BQPlayer *newPlayer = [[BQPlayer alloc] initWithPlayer:eachPlayer teamSeason:self];
		newPlayer.year = self.yearID;
		[rosterPlayers addObject:newPlayer];
	}
	return rosterPlayers;
}


//
//  Sort the specified Roster kind (Pitching, Batting, Fielding) on the specified stat
//  This generic function allows the trouble-free drilldown.
//
//  The returned array is an array of (Batting,Pitching,Fielding *)      This is important,
//  as it makes the drill-down lightweight in terms of memory allocation.
//
//  NSArray *battingRBIs = [aTeam rosterKind:@"Batting" inStatOrder@"RBI" ascending:NO];
//
//  Note:
//		Each statistic for each rosterKind must respond to the valueForKey:statKey and
//      return trivially sortable value.   If the stat is not
//      sortable (or not available), then take measures to ensure that the drill-down
//      feature on the stat is not enabled.
//
//  TODO filter out n/a values (-1) before doing the sort
//
-(NSArray *)rosterKind:(NSString *)rosterKind inStatOrder:(NSString *)statKey ascending:(BOOL)ascending {
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:statKey ascending:ascending];
	NSArray *sortByStat = @[desc];
	
	NSArray *players = [[self valueForKey:rosterKind] allObjects];
	NSArray *rankedPlayers = [players sortedArrayUsingDescriptors:sortByStat];
	return rankedPlayers;
}

+(Teams *)teamWithTeamID:(NSString *)teamID andYear:(NSNumber *)yearID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// Pretty similar to teamNameFromTeamID actually.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teamID==%@ and yearID==%@",teamID,yearID];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	Teams *ourTeam = [managedObjectContext executeFetchRequest:fetchRequest error:&error][0];
	return ourTeam;	
}

-(NSNumber *) shouldRankForBattingAverage
{
    return @(TRUE);
}


@end
