//
//  Master+Query.m
//  BaseballWithSwift
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "Batting+Query.h"
#import "NSArray+BV.h"
#import "Fielding+Query.h"
#import "StatDescriptor.h"
#import "BaseballQueryAppDelegate.h"
#import "HallOfFame.h"
#import "Master+Query.h"
#import "StatsFormatter.h"
#import "StatHead.h"
#import "ThisYear.h"
#import "BaseballWithSwift-Bridging-Header.h"  // Need this to refer to Swift objects.

@implementation Master (Query)

+(Master *)masterRecordWithPlayerID:(NSString *)aPlayerID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Master" inManagedObjectContext:appDel.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerID==%@",aPlayerID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *ourGuy = [appDel.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return ourGuy[0]; // hopefully only one of these.
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@",[self nameFirst],[self nameLast]];
}

//
//  General function to gather the stats from a master record that apply to
//  the specified teamSeason.   If multiple stats are returned, they are sorted
//  on the number of Games, descending.    This will make it easy enough to determine
//  the most common position played by a player, for example.
//
//  TODO filter out the duplicate OF fielding record when there are more specific
//       entries for the OF positions.  Or, perhaps better, offer the OF and a means
//       to unnest the OF into the specific positions.
//
-(NSArray *)stats:(SEL)statsSelector forTeamSeason:(Teams *)aTeamSeason {
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"G" ascending:NO];
	NSArray *gamesDescending = @[desc];
	NSPredicate *thisTeamSeason = [NSPredicate predicateWithFormat:@"teamID == %@ and yearID == %@", aTeamSeason.teamID, aTeamSeason.yearID];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	NSArray *stats = [[self performSelector:statsSelector] allObjects];
#pragma clang diagnostic pop
	NSArray *seasonStats = [stats filteredArrayUsingPredicate:thisTeamSeason];
	return [seasonStats sortedArrayUsingDescriptors:gamesDescending];
}

-(NSArray *)fieldingRecordsForTeamSeason:(Teams *)aTeamSeason {
	return [self stats:@selector(fieldingRecords) forTeamSeason:aTeamSeason];
}

-(NSArray *)battingSeasonsForTeamSeason:(Teams *)aTeamSeason {
	return [self stats:@selector(battingSeasons) forTeamSeason:aTeamSeason];
}

-(NSArray *)pitchingSeasonsForTeamSeason:(Teams *)aTeamSeason {
	return [self stats:@selector(pitchingSeasons) forTeamSeason:aTeamSeason];
}

-(NSArray *)managerSeasonsForTeamSeason:(Teams *)aTeamSeason {
	return [self stats:@selector(managerSeasons) forTeamSeason:aTeamSeason];	
}

//
//  sort on stint, sort on Games within each stint
-(NSArray *)stats:(SEL)statsSelector forYear:(NSNumber *)yearID {
	NSSortDescriptor *onStint = [[NSSortDescriptor alloc] initWithKey:@"stint" ascending:YES];
	NSSortDescriptor *onGames = [[NSSortDescriptor alloc] initWithKey:@"g" ascending:NO];
	NSArray *descriptors = @[onStint, onGames];
    if (statsSelector==@selector(managerSeasons))
        descriptors = @[onGames]; // NO STINT FOR MANAGERS
	NSPredicate *forYearID = [NSPredicate predicateWithFormat:@"yearID == %@", yearID];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	NSArray *stats = [[self performSelector:statsSelector] allObjects];
#pragma clang diagnostic pop
	NSArray *yearStats = [stats filteredArrayUsingPredicate:forYearID];
	return [yearStats sortedArrayUsingDescriptors:descriptors];
}

// These return the stints for that year, if there are multiple, sorted by games.

-(NSArray *)fieldingRecordsForYear:(NSNumber *)yearID {
	return [self stats:@selector(fieldingRecords) forYear:yearID];
}

-(NSArray *)battingSeasonsForYear:(NSNumber *)yearID {
	return [self stats:@selector(battingSeasons) forYear:yearID];
}

-(NSArray *)pitchingSeasonsForYear:(NSNumber *)yearID {
	return [self stats:@selector(pitchingSeasons) forYear:yearID];
}

-(NSArray *)managerSeasonsForYear:(NSNumber *)yearID {
	return [self stats:@selector(managerSeasons) forYear:yearID];
}

// Post-season records should be linked in to-many relationship. Since we haven't done that yet in the importer, write code here.
// These really should be sorted by "round" but not in alpha order - in order of something like:
// *WC (ALWC/NLWC), *DS* (AL/NL DS 1/2), *CS (AL/NL CS), WS

-(NSArray *)fieldingPostSeasonRecordsForYear:(NSNumber *)yearID {
    NSFetchRequest *fieldingPostRequest = [NSFetchRequest fetchRequestWithEntityName:@"FieldingPost"];
    fieldingPostRequest.predicate = [NSPredicate predicateWithFormat:@"playerID == %@ AND yearID == %@", self.playerID, yearID];
    NSError *error = nil;
    NSArray *fieldingPostsToReturn = [self.managedObjectContext executeFetchRequest:fieldingPostRequest error:&error];
    return [self sortedArrayByRound:fieldingPostsToReturn];
}

-(NSArray *)battingPostSeasonRecordsForYear:(NSNumber *)yearID {
    NSFetchRequest *battingPostRequest = [NSFetchRequest fetchRequestWithEntityName:@"BattingPost"];
    battingPostRequest.predicate = [NSPredicate predicateWithFormat:@"playerID == %@ AND yearID == %@", self.playerID, yearID];
    NSError *error = nil;
    NSArray *battingPostsUnsorted = [self.managedObjectContext executeFetchRequest:battingPostRequest error:&error];
    return [self sortedArrayByRound:battingPostsUnsorted];
}

// Given array of post (battingPost/pitchingPost/fieldingPost) records, sort by round based on rather arbitrary order. Sort of chronological order of the round within the season.
-(NSArray *)sortedArrayByRound:(NSArray *)postRecords {
    // Create parallel array of numbers to the fetched array of NSManagedObjects. The numbers are the sort id of the round name.
    // Interestingly, in 1981 there were two halves of the baseball season so we have AEDIV/AWDIV/NEDIV/NWDIV. Also in 1892 there was a CS because the season was split in two halves.
    NSArray *postRecordsToReturn = postRecords;
    NSInteger posts_count = postRecords.count;
    if (posts_count > 0) {
        NSMutableArray *indexDicts = [NSMutableArray new];
        NSArray *roundSortOrder = @[@"ALWC", @"NLWC", @"AEDIV", @"AWDIV", @"NEDIV", @"NWDIV", @"ALDS1", @"ALDS1", @"ALDS2", @"NLDS1", @"NLDS2", @"CS", @"ALCS", @"NLCS", @"WS"];
        for (NSInteger i=0; i<posts_count; i++) {
            NSManagedObject *aPostRecord = postRecords[i];
            [indexDicts addObject:@{@"seriesIndex": [NSNumber numberWithUnsignedInteger:[roundSortOrder indexOfObject: [aPostRecord valueForKey:@"round"]]], @"arrayIndex": [NSNumber numberWithInteger:i]}];
        }
        [indexDicts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"seriesIndex" ascending:YES]]];
        NSMutableArray *sortedPostRecords = [NSMutableArray new];
        for (NSInteger i=0; i<posts_count; i++) {
            NSDictionary *anIndexDict = indexDicts[i];
            NSInteger arrayIndex = [anIndexDict[@"arrayIndex"] integerValue];
            [sortedPostRecords addObject:postRecords[arrayIndex]];
        }
        postRecordsToReturn = [sortedPostRecords copy];
    }
    return postRecordsToReturn;
}

-(NSArray *)pitchingPostSeasonRecordsForYear:(NSNumber *)yearID {
    NSFetchRequest *pitchingPostRequest = [NSFetchRequest fetchRequestWithEntityName:@"PitchingPost"];
    pitchingPostRequest.predicate = [NSPredicate predicateWithFormat:@"playerID == %@ AND yearID == %@", self.playerID, yearID];
    NSError *error = nil;
    NSArray *pitchingPostsToReturn = [self.managedObjectContext executeFetchRequest:pitchingPostRequest error:&error];
    return [self sortedArrayByRound:pitchingPostsToReturn];
}

//
//  Instead of valueForKeyPath:@"battingSeasons.@sum.G"
//
//  use this function:
//
//         sumAllExceptMissingForStatKind:@"battingSeasons" stat:@"G"
//
//  because it filters out the missing data, which would otherwise make
//  the totals wrong (missing values are -1).
//
//  If nothing is left after the seasons with the stat missing are
//  stripped away, then return -1 (so the StatsViewer can know to strip
//  it out).
//
-(NSNumber *)sumAllExceptMissingForStatKind:(NSString *)statKind stat:(NSString *)statName
{
    NSSet *seasons = [self valueForKey:statKind];
    NSPredicate *allExceptMissing = [NSPredicate predicateWithFormat:@"%K != -1", statName];
    NSSet *seasonsWithMissingStatRemoved = [seasons filteredSetUsingPredicate:allExceptMissing];
    NSNumber *sumAll = @-1;
    if ([seasonsWithMissingStatRemoved count] > 0) {
        sumAll = [seasonsWithMissingStatRemoved valueForKeyPath:[NSString stringWithFormat:@"@sum.%@",statName]];
    }
    return sumAll;
}

//
// sumAllExceptMissingForStatSet - Like sumAllExceptMissingForStatKind
// except passing the set rather than giving set name.
//
-(NSNumber *)sumAllExceptMissingForStatArray:(NSArray *)statArray stat:(NSString *)statName {
	NSPredicate *allExceptMissing = [NSPredicate predicateWithFormat:@"%K != -1", statName];
	NSArray *seasonsWithMissingStatRemoved = [statArray filteredArrayUsingPredicate:allExceptMissing];
	NSNumber *sumAll = @-1;
	if ([seasonsWithMissingStatRemoved count] > 0) {
		sumAll = [seasonsWithMissingStatRemoved valueForKeyPath:[NSString stringWithFormat:@"@sum.%@",statName]];
	}
	return sumAll;
}

//
// addStatIfValid - do this
//     [aggregateFieldingRecord setValue:[self sumAllExceptMissingForStatArray:fieldingRecordsForThisPosition stat:@"InnOuts"] forKey:@"InnOuts"];
// But with checking for stat that is totally missing, ie. -1 in all records.
//
-(void)addStatIfValid:(NSString *)stat toMutableDictionary:(NSMutableDictionary *)dict fromStatArray:(NSArray *)statArray
{
	NSNumber *statTotal = [self sumAllExceptMissingForStatArray:statArray stat:stat];
	if ([statTotal integerValue] != -1) {
        if ([stat isEqualToString:@"innOuts"]) {
            [dict setValue:[StatsFormatter inningsInDecimalFormFromInningOuts:statTotal.integerValue] forKey:stat];
        } else
            [dict setValue:[statTotal description] forKey:stat];
	}
}

//
// fieldingRecordsByPosition -
// return array with one member per
// unique position player has played in his career.

// OLD WAY: Each member is
// a dictionary containing aggregate fieldingRecord-like stats for that 
// position. Positions are ordered
// in decreasing order of Games played.
// Make the values strings for display in user-visible table.

// NEW WAY: fieldingRecordsByPosition returns an array with one array per
// position played, sorted decending by total games for position. Each position array has all the fielding records for position.
//
-(NSArray *)fieldingRecordsByPosition
{
    // Get all positions the player ever played.
    NSSet *positions = [self valueForKeyPath:@"fieldingRecords.@distinctUnionOfObjects.pos"];
    NSMutableArray *fieldingRecordsByPosition = [[NSMutableArray alloc] initWithCapacity:[positions count]];
    for (NSString *aPosition in positions) { // For each pos,
        NSPredicate *positionPredicate = [NSPredicate predicateWithFormat:@"pos == %@",aPosition];
        // Get set of all records for this pos.
        NSArray *fieldingRecordsForThisPosition = [[self.fieldingRecords filteredSetUsingPredicate:positionPredicate] allObjects];
        // Hook it on.
        [fieldingRecordsByPosition addObject:fieldingRecordsForThisPosition];
    }
    NSArray *positionArrayToReturn; // = fieldingRecordsByPosition;
    // Create parallel array with dicts that have #games and array of fielding records for position.
    NSMutableArray *parallelThrowawayArray = [NSMutableArray arrayWithCapacity:fieldingRecordsByPosition.count];
    for (NSArray *aPositionArray in fieldingRecordsByPosition) {
        [parallelThrowawayArray addObject:@{@"games":[self sumAllExceptMissingForStatArray:aPositionArray stat:@"G"],@"fieldingRecords":aPositionArray}];
    }
    NSSortDescriptor *gamesSD = [[NSSortDescriptor alloc] initWithKey:@"games" ascending:NO];
    [parallelThrowawayArray sortUsingDescriptors:@[gamesSD]];
    NSMutableArray *sortedFieldingRecordsByPosition = [NSMutableArray arrayWithCapacity:fieldingRecordsByPosition.count];
    for (NSDictionary *aLittleGamesPositionDict in parallelThrowawayArray) {
        [sortedFieldingRecordsByPosition addObject:[aLittleGamesPositionDict valueForKey:@"fieldingRecords"]];
    }
    positionArrayToReturn = sortedFieldingRecordsByPosition;
    return positionArrayToReturn;
}

#pragma mark Formatting methods for general use.

-(NSString *)heightString
{
	NSString *returnedHeight = nil;
	NSInteger height_int = [self.height integerValue];
	if (height_int>0) {
		returnedHeight = [NSString stringWithFormat:@"%ld' %ld\"",(long)height_int/12,(long)height_int%12];
	}
	return returnedHeight;
}

-(NSString *)birthDateString
{
	NSString *returnedBirthDate = nil;
	NSInteger birth_day = [self.birthDay integerValue];
	NSString *birthDayString;
	if (birth_day > 0) birthDayString = [self.birthDay description];
	else birthDayString = @"?";
	if ([self.birthMonth integerValue]>0) {
		returnedBirthDate = [NSString stringWithFormat:@"%@-%@-%@",self.birthMonth,birthDayString,self.birthYear];
	} else {
		if ([self.birthYear integerValue]>0) {
			returnedBirthDate = [self.birthYear description];
		}
	}
	return returnedBirthDate;
}

-(NSString *)birthPlaceString
{
	NSString *returnedBirthPlace = nil;
    
	if ([self.birthCity length]>1 || [self.birthState length]>1 || [self.birthCountry length]>1) {
        // Sometimes the city and state name are the same like "Santiago de Cuba" so it would say "Santiago de Cuba, Santiago de Cuba Cuba". Oh well.
		returnedBirthPlace = [NSString stringWithFormat:@"%@, %@ %@",self.birthCity,self.birthState,self.birthCountry];		
	}
	return returnedBirthPlace;
}

-(NSString *)deathDateString
{
	NSString *returnedDeathDate = nil;
	if ([self.deathMonth integerValue]>0) {
		if ([self.deathDay integerValue]>0) {
			returnedDeathDate = [NSString stringWithFormat:@"%@-%@-%@",self.deathMonth,self.deathDay,self.deathYear];
		}
	} else {
		if ([self.deathYear integerValue]>0) {
			returnedDeathDate = [self.deathYear description];
		}
	}
	return returnedDeathDate;
}

-(NSString *)deathPlaceString
{
	NSString *returnedDeathPlace = nil;
	if ([self.deathCity length]>1 || [self.deathState length]>1 || [self.deathCountry length]>1) {
		returnedDeathPlace = [NSString stringWithFormat:@"%@ %@ %@",self.deathCity,self.deathState,self.deathCountry];
	}
	return returnedDeathPlace;
}

//
// allYearsForPlayer - The Relationship Version. Traverse relationships to return results rather than doing slow fetches.
//
-(NSArray *)allYearsForPlayer
{
	NSMutableSet *allTeamYearsForPlayer = [[NSMutableSet alloc] init];
	
	[allTeamYearsForPlayer unionSet:[self.battingSeasons valueForKey:@"yearID"]];
	[allTeamYearsForPlayer unionSet:[self.pitchingSeasons valueForKey:@"yearID"]];
	[allTeamYearsForPlayer unionSet:[self.fieldingRecords valueForKey:@"yearID"]];
	[allTeamYearsForPlayer unionSet:[self.managerSeasons valueForKey:@"yearID"]];
	NSArray *yearsInOrder = [[allTeamYearsForPlayer allObjects] sortedArrayUsingSelector:@selector(compare:)];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    // If <latest year> not paid up, remove that year.
    if (appDel.latest_year_in_database<LATEST_DATA_YEAR && ([[yearsInOrder lastObject] isEqualToNumber:[NSNumber numberWithInteger:LATEST_DATA_YEAR]]))
        yearsInOrder = [yearsInOrder subarrayWithRange:NSMakeRange(0, [yearsInOrder count]-1)];
	return yearsInOrder;	
}

-(BOOL)checkIfPlayedInLatestYear
{
    BOOL latest_to_return = NO;
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDel.latest_year_in_database==LATEST_DATA_YEAR)
        latest_to_return = [self.playedInLatestYear boolValue];
    else { // For cheapskates who haven't paid for LATEST_DATA_YEAR yet, it's a bit slower.
        NSPredicate *latestPredicate = [NSPredicate predicateWithFormat:@"(ANY battingSeasons.yearID == %d) OR (ANY pitchingSeasons.yearID == %d) OR (ANY fieldingRecords.yearID == %d) OR (ANY managerSeasons.yearID == %d)",LATEST_DATA_YEAR-1,LATEST_DATA_YEAR-1,LATEST_DATA_YEAR-1,LATEST_DATA_YEAR-1];
        if ([latestPredicate evaluateWithObject:self])
            latest_to_return = YES;
    }
    return latest_to_return;
}

-(NSString *)hofInductedYear
{
    NSString *hofInductedYearToReturn = nil;
    // Hall of fame - do in career stats only.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerID==%@ && inducted==TRUE", self.playerID];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HallOfFame" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *hallOfFameRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([hallOfFameRecords count]>0) {
        HallOfFame *aHallOfFameRecord = hallOfFameRecords[0]; // assume just one
        hofInductedYearToReturn = [NSString stringWithFormat:@"%@",aHallOfFameRecord.yearID];
    }
    return hofInductedYearToReturn;
}

//
// debutFinalYearsString - returns (year-year)
//
-(NSString *)debutFinalYearsString
{
    NSString *debutYear = [StatsFormatter yearStringFromDateField:self.debut];
    NSString *finalYear = [StatsFormatter yearStringFromDateField:self.finalGame];
    if (!debutYear) debutYear = @" ";
    if (!finalYear) finalYear = @" ";
    // If a manager, check for final managing year later than final game played.
    NSSet *managerSeasonsSet = self.managerSeasons;
    //[thisMaster valueForKey:@"managerSeasons"];
    if ([managerSeasonsSet count] > 1) {
        if ([self.battingSeasons count]==0) { // if never played, only managed.
            debutYear = [[managerSeasonsSet valueForKeyPath:@"@min.yearID"] description];
        }
        // *** yearid
        NSNumber *latestYearManaging = [managerSeasonsSet valueForKeyPath:@"@max.yearID"];
        if ([finalYear isEqualToString:@" "] || ([finalYear integerValue] < [latestYearManaging integerValue]))
            finalYear = [latestYearManaging description];
    }
    if ([debutYear isEqualToString:@" "] && [finalYear isEqualToString:@" "])
        return @"";
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDel.latest_year_in_database<LATEST_DATA_YEAR && [finalYear isEqualToString:LATEST_DATA_YEAR_STRING]) finalYear = @" ";
    return [NSString stringWithFormat:@"(%@-%@)",debutYear,finalYear];
}

#pragma mark Web URL calculator

// Never really sure what should go in BQPlayer and what should go in Master+Query. Maybe they should just be combined? Or rationalized I guess. *** Maybe if we ever have to do player.master then it should be moved to Master+Query.

// Called from playerYearsTBC as well as playerCareerTBC
-(NSURL *)urlOnWebSite:(NSString *)webSite // forPlayerID:(NSString *)playerID
{
    NSString *urlString = @""; // nil made the analyzer upset on the URLWithString.
    if ([webSite isEqualToString:@"Wikipedia"]) {
        // Make URL like this; http://en.m.wikipedia.org/wiki/Ty_Cobb
        NSString *underscoredName;
        if ([self.nameFirst isEqualToString:@" "]) // if no first name.
            underscoredName = self.nameLast;
        else
            underscoredName = [NSString stringWithFormat:@"%@_%@",self.nameFirst,self.nameLast];
        urlString =[NSString stringWithFormat:@"http://en.m.wikipedia.org/wiki/%@",underscoredName];
    } else if ([webSite isEqualToString:@"Baseball-Reference.com"]) {
        // 3-12-2017: now it's like this. Guess we need to test this stuff a lot since it keeps changing.
        // http://www.baseball-reference.com/players/b/butlero01.shtml
        // Use bbrefID
        urlString = [NSString stringWithFormat:@"http://baseball-reference.com/players/%@/%@.shtml",[self.bbrefID substringToIndex:1],self.bbrefID];
    } else if ([webSite isEqualToString:@"BaseballAlmanac.com"]) {
        // URL is like this: http://www.baseball-almanac.com/players/player.php?p=bautida01
        NSString *idToUse = self.bbrefID;
        urlString = [NSString stringWithFormat:@"http://www.baseball-almanac.com/players/player.php?p=%@",idToUse];
    } else if ([webSite isEqualToString:@"Retrosheet.org"]) {
        // URL is like this: http://www.retrosheet.org/boxesetc/V/Pverlj001.htm
        // Use retroID
        NSString *lastInitial = [self.nameLast substringToIndex:1];
        urlString = [NSString stringWithFormat:@"http://www.retrosheet.org/boxesetc/%@/P%@",lastInitial,self.retroID];
    }
    return [NSURL URLWithString:urlString];
}

@end


