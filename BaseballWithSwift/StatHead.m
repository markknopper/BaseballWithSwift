//
//  StatHead.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/29/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "StatHead.h"
#import "Master.h"
#import "Teams.h"
#import "BaseballQueryAppDelegate.h"

@implementation StatHead

// statNameForStatsDisplayStatType - this is beautiful now that we use bit fields for stat type and scope.
+(NSString *)statNameForStatsDisplayStatType:(StatsDisplayStatType)stat_type
{
    NSString *statNameToReturn = @"";
    NSArray *typeNames = @[@"Personal",@"Batting",@"Pitching",@"Fielding",@"Managing"];
    NSString *ourTypeName = typeNames[stat_type & StatsDisplayStatTypeMask]; // low 4 bits
    NSArray *scopeNames = @[@"Info",@"",@"Career",@"Team",@"Post"];
    NSString *ourScopeName = scopeNames[(stat_type & StatsDisplayStatScopeMask) >> 4]; // high 4 bits
    if ([ourScopeName isEqualToString:@"Team"] && [ourTypeName isEqualToString:@"Personal"])
        ourTypeName = @"Info"; // Team Personal isn't right.
    statNameToReturn = [NSString stringWithFormat:@"%@ %@",ourScopeName,ourTypeName];
    return statNameToReturn;
}

// statsDisplayStatTypeForTypeName:scopeName. Obvious thing to have here.
+(StatsDisplayStatType)statsDisplayStatTypeForTypeName:(NSString *)typeName scopeName:(NSString *)scopeName {
    NSArray *typeNames = @[@"Personal",@"Batting",@"Pitching",@"Fielding",@"Managing"];
    NSUInteger stat_code = [typeNames indexOfObject:typeName];
    NSArray *scopeNames = @[@"Info",@"",@"Career",@"Team",@"Post"];
    NSUInteger scope_code = [scopeNames indexOfObject:scopeName];
    return stat_code || scope_code<<4; // Whoa that was easy to write.
}

+(NSInteger)battingAverageWithHits:(NSNumber *)H atBats:(NSNumber *)AB {
	NSInteger batting_average = 0;
	NSInteger at_bats = [AB integerValue];
	if (at_bats > 0) {
		NSInteger hits = [H integerValue];
		batting_average = 1000.0*(float)hits/(float)at_bats+.5;
	}
	return batting_average;
}

+(NSInteger)on_BasePctWithHits:(NSNumber *)H atBats:(NSNumber *)AB walks:(NSNumber *)BB hitByPitch:(NSNumber *)HBP sacFlies:(NSNumber *)SF {
	NSInteger on_base_percentage=0;
	NSInteger at_bats = [AB integerValue];
    if (at_bats > 0) {
        NSInteger hits = [H integerValue];
        NSInteger walks = [BB integerValue];
        NSInteger hit_by_pitch = [HBP integerValue];
        NSInteger sacrifice_flies = [SF integerValue];
        if (at_bats + walks + hit_by_pitch + sacrifice_flies != 0) {
            on_base_percentage = 1000.0*(float)(hits + walks + hit_by_pitch)/(float)(at_bats + walks + hit_by_pitch + sacrifice_flies) + .5;
        }
    }
	return on_base_percentage;
}

+(NSInteger)sluggingPctWithHits:(NSNumber *)H atBats:(NSNumber *)AB doubles:(NSNumber *)doubles_2B triples:(NSNumber *)triples_3B homeRuns:(NSNumber *)HR {
	NSInteger slugging_percentage=0;
	NSInteger hits = [H integerValue];
	NSInteger doubles = [doubles_2B integerValue];
	NSInteger triples = [triples_3B integerValue];
	NSInteger home_runs = [HR integerValue];
	NSInteger total_bases = hits + doubles + 2*triples + 3*home_runs;
	//SLG - Slugging Percentage TB/AB
	NSInteger at_bats = [AB integerValue];
	if (at_bats > 0) {
		slugging_percentage = 1000.0*(float)total_bases/(float)at_bats+.5;
	}
	return slugging_percentage;
}

+(double)WHIPWithWalks:(NSNumber *)BB hits:(NSNumber *)H outsPitched:(NSNumber *)IPouts {
	NSInteger outs_pitched = [IPouts integerValue];
	double whip = 0.0;
	if (outs_pitched > 0) {
		NSInteger walks = [BB integerValue];
		NSInteger hits = [H integerValue];
		whip = ((double)(walks + hits)/((double)outs_pitched/3.0));
	}
	return whip;
}

+(NSInteger)inningsPitchedWithOutsPitched:(NSNumber *)IPouts {
	NSInteger outs_pitched = [IPouts integerValue];
	NSInteger innings_pitched = ((float)outs_pitched/(float)3)+.5;
	return innings_pitched;
}

//#define MIN_AT_BATS_FOR_BATTING_AVERAGE_RANK 500
//*** See http://en.wikipedia.org/wiki/Batting_average  qualifications for batting title. Consider
//*** changing this to be conditional on year range. Eg. no one qualifies on 1884 Altoona Mountain Citys.

+(BOOL)enoughAtBatsForBattingAverageRanking:(NSNumber *)AB {
	return YES;
	//NSInteger numberOfAtBats = [AB intValue];
	
	//return (numberOfAtBats >= MIN_AT_BATS_FOR_BATTING_AVERAGE_RANK);
}

//#define MIN_INNINGS_PITCHED_FOR_ERA_RANK 162
// This affects team, season and franchise ERA rankings.
#define MIN_INNINGS_PITCHED_FOR_ERA_RANK 40

+(BOOL)enoughOutsPitchedForERARank:(NSNumber *)IPouts {
	NSInteger inningsPitched = [StatHead inningsPitchedWithOutsPitched:IPouts];
	return (inningsPitched >= MIN_INNINGS_PITCHED_FOR_ERA_RANK);
}

//
//  If at least 1/3 of the game appearances are starts, then pitcher is a Starter
//  If pitcher has more saves than starts, then pitcher is a Closer
//  If pitcher has fewer than 1/3 of game appearances are starts and
//  less than 1/10 of appearances are saves, then middle reliever.
//
+(NSString *)pitcherKindDeducedFromGames:(NSNumber *)G starts:(NSNumber *)GS saves:(NSNumber *)SV {
	NSString *pitcherKind = @" ";
	NSInteger games = [G intValue];
	NSInteger saves = [SV intValue];
	NSInteger starts = [GS intValue];
	if (starts >= games/3.0) {
		pitcherKind = @"Starter";
	} else if (saves > starts) {
		pitcherKind = @"Closer";
	} else // if ((starts <= games/3) && (saves <= games/10)) {
		pitcherKind = @"Reliever";
	//}
	return pitcherKind;
}

// Still need this for per-position stats, which aren't precomputed.
+(NSInteger)fieldingPercentageWithPutouts:(NSNumber *)putouts assists:(NSNumber *)assists errors:(NSNumber *)errors {
	NSInteger fielding_percentage = -1;
    NSInteger putouts_int = [putouts integerValue];
    NSInteger assists_int = [assists integerValue];
    NSInteger errors_int = [errors integerValue];
    if (putouts_int>=0 && assists_int>=0 && errors_int>=0 && (putouts_int+assists_int+errors_int)>0) {
        if (errors_int == 0) {
            fielding_percentage = 1000; // flashing some leather.
        } else {
            fielding_percentage = (1000.0*(((float)(putouts_int+assists_int)/(float)(putouts_int+assists_int+errors_int))+.0005));
        }
    }
	return fielding_percentage;
}

+(NSString *)leagueNameFromLeagueID:(NSString *)leagueID
{
	NSString *leagueName = leagueID; // leave it alone if it doesn't match anything.
	// Put in longer league names for way old leagues.
	if ([leagueName isEqualToString:@"NL"])
		leagueName = @"National League";
	else if ([leagueName isEqualToString:@"AL"])
		leagueName = @"American League";
	else if ([leagueName isEqualToString:@"UA"])
		leagueName = @"Union Association";
	else if ([leagueName isEqualToString:@"AA"])
		leagueName = @"American Association";
	else if ([leagueName isEqualToString:@"PL"])
		leagueName = @"Players League";
	else if ([leagueName isEqualToString:@"FL"])
		leagueName = @"Federal League";
	else if ([leagueName isEqualToString:@"NA"])
		leagueName = @"National Association";
	return leagueName;
}

+(NSString *)divisionNameFromDivisionID:(NSString *)divisionID
{
    NSString *divisionName = divisionID; // leave it alone if it doesn't match anything.
    if ([divisionID isEqualToString:@"W"]) divisionName = @"West";
    else if ([divisionID isEqualToString:@"E"]) divisionName = @"East";
    else if ([divisionID isEqualToString:@"C"]) divisionName = @"Central";
    return divisionName;
}

+(NSString *)teamNameFromTeamID:(NSString *)teamID andYear:(NSNumber *)yearID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setResultType:NSDictionaryResultType];
	[fetchRequest setPropertiesToFetch:@[entityProperties[@"name"]]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teamID==%@ and yearID==%@",teamID,yearID];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
    NSArray *teamRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSString *teamNameToReturn = nil;
    if ([teamRecord count]>0) {
        Teams *ourTeam = teamRecord[0];
        teamNameToReturn = [ourTeam valueForKey:@"name"];
    }
	return teamNameToReturn;
}

+(NSString *)playerNameFromPlayerID:(NSString *)playerID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Master" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSDictionary *entityProperties = [entity propertiesByName];
	[fetchRequest setPropertiesToFetch:@[entityProperties[@"nameFirst"],entityProperties[@"nameLast"]]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerID==%@",playerID];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
    NSArray *masterRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSString *playerNameToReturn = nil;
    if ([masterRecord count]>0) {
        Master *theMaster = masterRecord[0]; // you will obey
        playerNameToReturn = [NSString stringWithFormat:@"%@ %@",theMaster.nameFirst,theMaster.nameLast];
    }
    return playerNameToReturn;
}

+(NSNumber *)firstYearInHistory
{
	return @1871;
}

+(NSNumber *)lastYearInHistory
{
	BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
	return @(appDel.latest_year_in_database);
}

+(NSString *)positionNameFromPositionNumber:(NSNumber *)positionNumber
{
     NSArray *positionNames = @[@"P",@"C",@"1B",@"2B",@"3B",@"SS",@"LF",@"CF",@"RF", @"DH"];
    return positionNames[[positionNumber integerValue]-1];
}

+(BOOL)isCurrentTeam:(NSString *)teamName
{
    // Please distract yourself from looking at the following statement.
    NSArray *currentTeams = @[@"Arizona Diamondbacks", @"Atlanta Braves", @"Baltimore Orioles", @"Boston Red Sox", @"Chicago Cubs", @"Chicago White Sox", @"Cincinnati Reds", @"Cleveland Indians", @"Colorado Rockies", @"Detroit Tigers", @"Florida Marlins", @"Miami Marlins", @"Houston Astros", @"Kansas City Royals", @"Los Angeles Angels of Anaheim", @"Los Angeles Dodgers", @"Milwaukee Brewers", @"Minnesota Twins", @"New York Mets", @"New York Yankees", @"Oakland Athletics", @"Philadelphia Phillies", @"Pittsburgh Pirates", @"San Diego Padres",  @"San Francisco Giants", @"Seattle Mariners", @"St. Louis Cardinals", @"Tampa Bay Rays", @"Texas Rangers", @"Toronto Blue Jays", @"Washington Nationals"];
    return  [currentTeams containsObject:teamName];
}

@end
