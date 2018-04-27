//
//  PlayerRankOperation.m
//  BaseballQuery
//
//  Created by Mark Knopper on 3/18/11.
//  Copyright 2011-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "PlayerRankOperation.h"
#import "Teams+Query.h"
#import "StatDescriptor.h"
#import "NSArray+BV.h"
#import "BaseballQueryAppDelegate.h"
#import "ThisYear.h"

@implementation PlayerRankOperation

// Newish modern approach using NSOperation.
// Do database searching and sorting in a background thread to allow the UI to function. This should be fine
// if the user switches to another tab since we are still active. But if the user pulls the rug out by pressing
// the Back button, we are gone. The thread has to check for cancellation so it doesn't do unnecessary computations. 
// We cancel in viewDidDisappear and its friends.
// Main thread needs to set up an observer to wait for thread to be done (or be cancelled perhaps). When secondary 
// thread finishes, there is a chance that the main thread (view controller) is no longer alive. Nothing to do with results in this
// case.
//
// Parameters sent to thread are: statsDisplay, descriptorIndex, statObj/toSelect, predicate, MOC.
// Return values from thread are: toSelectIndex, section0Roster and section1Roster (arrays of objectID's).

// Safest way is to subclass NSOperation because the operation needs to check for isCancelled. NSInvocationOperation can do this using
// KVO but this seems cumbersome.
//
// All parameters passed in have to be guaranteed not to be modified by the client thread.

-(id)initWithStatsDisplay:(StatsDisplay *)statsDisp descriptorIndex:(NSNumber *)descriptor_index showAll:(BOOL)show_all statObj:(id)ourStatObject predicate:(NSPredicate *)ourPredicate managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        self.statsDisplay = statsDisp;
        self.descriptorIndex = descriptor_index;
        self.statsSource = ourStatObject;
        self.predicate = ourPredicate;
        self.managedObjectContext = managedObjectContext;
        showAll = show_all;
    }
    return self;
}

-(NSString *)statTypeNameForStatsDisplayType
{
    NSString *typeRelationshipNameToReturn;
    if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypeBatting) {
        typeRelationshipNameToReturn = @"batters";
    } else if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypePitching) {
        typeRelationshipNameToReturn = @"pitchers";
    } else if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypeFielding) {
        typeRelationshipNameToReturn = @"fielders";
    } else
        typeRelationshipNameToReturn = @"managers";
    return typeRelationshipNameToReturn;
}

//
// rosterFromTeamsForYear
// Return array of all player stat records (either batting/pitching etc as selected by statTypeName) from teamsForYear.
// Prune out any missing stats.
// But if ranking on Fielding, filter on the desired position.
//
-(NSArray *)rosterFromTeamsForYear:(NSArray *)teamsForYear
{
    //
    //  TODO - consolidate multi-stint player totals into a single player. Eg. Edwin Jackson 2010 on ARI and DET.
    //
    StatDescriptor *sD = _statsDisplay.statDescriptors[[_descriptorIndex integerValue]];
    NSMutableArray *statsForYear = [[NSMutableArray alloc] init];
    for (Teams *eachTeam in teamsForYear) {
        // Add, eg. each batter from each team to statsForYear.
        NSString *typeRelationshipName = [self statTypeNameForStatsDisplayType];
        NSSet *relationshipSet = [eachTeam valueForKey:typeRelationshipName];
        if ([typeRelationshipName isEqualToString:@"fielders"]) {
            // Filter this on just this position.
            NSString *thisPosition = [_statsSource valueForKey:@"pos"];
            NSSet *filteredPositionSet = [relationshipSet objectsPassingTest:^(id obj,BOOL *stop) {
                return [[obj valueForKey:@"pos"] isEqualToString:thisPosition];
            }];
            relationshipSet = filteredPositionSet;
        }
        for (id statObject in relationshipSet) {
            StatDescriptor *sD = _statsDisplay.statDescriptors[[_descriptorIndex integerValue]];
            NSString *displayValue = [_statsSource displayStringForStat:sD.key];
            if (![displayValue isEqualToString:@"-1"])
                // prune out -1s. *** hope the assumption that this is a string and -1 is bad isn't too specific here.
                [statsForYear addObject:statObject];
        }
    }
    //
    //  Consult the stats descriptor to get baseball stats knowledge about whether or not the statObject
    //  qualifies for ranking on the stat. Build the selector and then the predicate to select only
    //  the objects that are rankable. Always include the selected element, even if it doesn't qualify
    //  for ranking. Then filter and sort.
    //
    NSArray *roster;
    if (sD.isRankableSelectorName != nil) {
        NSPredicate *isRankableForStatPredicate = [NSPredicate predicateWithFormat:@"(%K == YES) || (SELF == %@)", sD.isRankableSelectorName, _statsSource];
        // *** This has a weird and wrong effect. Comparing a key to YES is just test for !=0.
        // *** For example go to 1970 Dusty Baker (on the Braves) and tap BA. It ranks all players who have batting records in 1970 but filters out anyone with .000 averages. I guess that is ok but can't really be the intention!
        NSArray *rankableArray = [statsForYear filteredArrayUsingPredicate:isRankableForStatPredicate];
        roster = [rankableArray sortedArrayUsingKey:sD.key ascending:sD.ascending];
    } else {
        roster = [statsForYear sortedArrayUsingKey:sD.key ascending:sD.ascending];
    }
    return roster;
}

- (void)main
{
    @autoreleasepool {
        [_managedObjectContext performBlock:^{
            StatDescriptor *sD = _statsDisplay.statDescriptors[[_descriptorIndex integerValue]];
            /* If this is career fielding, there are some manual
             computations necessary, possibly too slow for actual use.
             We have statObject, an array of all fielding records this
             player had for this position. So his career total of this
             stat for this position has to be summed across these records.
             Then all other players fielding records matching this position
             need to be fetched, and summed per player. Then sorted with
             our guy's total. What data structure should be used for these
             totals? Maybe a dummy FieldingTotals record? Or maybe
             the importer should be changed and model should have a to-many
             relationship FieldingTotalsPerPosition with precomputed
             totals. Then fetch here would be a little easier. It would
             require getting all FTPPs for this position and sorting, with our guy's FTPP.
             Not sure what the average number of positions per player is,
             but I'm guessing it is 2-3 so the FTPP table might be rather large.
             */
            NSArray *teamsForYear = nil;
            NSArray *roster=nil;
            if (_predicate) {
                if ([[_predicate predicateFormat] isEqualToString:@"TRUEPREDICATE"]) {
                    // All Time.
                    // If we got all Teams, can do single fetch to get sorted "roster" for ranking.
                    // No looping through teams,
                    // or explicit sort. (Optimization for time & space.)
                    NSFetchRequest *getAllRecordsOfType = [[NSFetchRequest alloc] init];
                    NSString *entityName = @"Batting"; // to make analyzer happy that it can't be null.
                    NSInteger mininum_games = 25; // Set this here specific to stat type.
                    NSString *minimumPredicateKey = @"g";
                    // Probably hide this in a separate method, or under a chair.
                    // Minimum games is pretty arbitrary. Not sure how to get
                    // perfect values.
                    switch (_statsDisplay.type) {
                        case (StatsDisplayStatTypeBatting|StatsDisplayStatScopePlayer) :
                            entityName = @"Batting";
                            mininum_games = 125;
                            break;
                        case (StatsDisplayStatTypeBatting|StatsDisplayStatScopeCareer) :
                            minimumPredicateKey = @"aB"; // cheat
                            mininum_games = 1000;
                            entityName = @"BattingTotals";
                            break;
                        case (StatsDisplayStatTypePitching|StatsDisplayStatScopePlayer) :
                            entityName = @"Pitching";
                            break;
                        case (StatsDisplayStatTypePitching|StatsDisplayStatScopeCareer) :
                            entityName = @"PitchingTotals";
                            mininum_games = 100;
                            break;
                        case (StatsDisplayStatTypeFielding|StatsDisplayStatScopePlayer) :
                            entityName = @"Fielding";
                            mininum_games = 50;
                            break;
                        case (StatsDisplayStatTypeFielding|StatsDisplayStatScopeCareer) :
                            entityName = @"FieldingTotals";
                            mininum_games = 500;
                            break;
                        case (StatsDisplayStatTypeManaging|StatsDisplayStatScopePlayer) :
                            entityName = @"Managers";
                            break;
                        case (StatsDisplayStatTypeManaging|StatsDisplayStatScopeCareer) :
                            entityName = @"ManagerTotals";
                            break;
                    }
                    NSEntityDescription *ourEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
                    NSDictionary *entityProperties = [ourEntity propertiesByName];
                    [getAllRecordsOfType setEntity:ourEntity];
                    BOOL can_combine_fetch_with_sort = TRUE;
                    NSPredicate *getAllRecordsOfTypePredicate;
                    // Stats-specific optimizations and error checks could go here. Or not.
                    // *** uh, shouldn't we check for what kind of percentage?
                    // *** what about fielding percentage?
                    // Fielding percentage is actually fPct and is pre-computed now. 'percentage' still exists in Career Manager stats.
                    if ([sD.key isEqualToString:@"percentage"]) { // Computed attribute.
                        // Fetch W and L for percentage.
                        [getAllRecordsOfType setPropertiesToFetch:@[entityProperties[@"w"],entityProperties[@"l"]]];
                        // Can't use transient property with sort descriptors in fetch. :(
                        can_combine_fetch_with_sort = FALSE;
                        // Create predicate format string like g>%d or aB>%d.
                        // Minimum_games might actually be minimum_aB or something else.
                        NSString *noQuotesFormatString = [NSString stringWithFormat:@"%@>%%d",minimumPredicateKey];
                        getAllRecordsOfTypePredicate = [NSPredicate predicateWithFormat:noQuotesFormatString,mininum_games];
                    } else if (_statsDisplay.type == (StatsDisplayStatScopeCareer|StatsDisplayStatTypeFielding)){
                        // Need to AND in position to predicate.
                        // Checking now *** for the case of specific fielding position career total ranking. 
                        [getAllRecordsOfType setPropertiesToFetch:@[entityProperties[sD.key]]];
                        NSString *noQuotesFormatString = [NSString stringWithFormat:@"%%K != -1 AND %@>%%d and pos=='%@'",minimumPredicateKey,[_statsSource valueForKey:@"pos"]];
                        getAllRecordsOfTypePredicate = [NSPredicate predicateWithFormat:noQuotesFormatString,sD.key,mininum_games];
                    }
                    else if ([sD.key isEqualToString:@"seasons"]) {
                        // Set up to get all not-totals records of this type (Batting/ Pitching/Fielding/Managing).
                        // So, need to get all Masters, then sort by *Records uniqueSeasons count.
                        NSEntityDescription *regularEntity = [NSEntityDescription entityForName:@"Master" inManagedObjectContext:_managedObjectContext];
                        [getAllRecordsOfType setEntity:regularEntity];
                        [getAllRecordsOfType setPropertiesToFetch:nil];
                        [getAllRecordsOfType setPredicate:nil];
                        [getAllRecordsOfType setSortDescriptors:nil];
                        NSError *error = nil;
                        NSArray *allMasters = [_managedObjectContext executeFetchRequest:getAllRecordsOfType error:&error];
                        // Need to create the roster array as dictionaries with keys "fullName", and "seasons", then sort it. Do the section0 and section1 roster here. Probably the former. Then notify and exit. Also need a small check in configureCell in PlayerRankTVC for 'seasons' to treat roster as dictionary rather than Pitchers etc. type object.
                        // allSeasons is array of dictionaries for each player with at least one season of this type.
                        NSMutableArray *allSeasons = [NSMutableArray new];
                        NSDictionary *ourGuy = nil;
                        for (Master *aMaster in allMasters) {
                            NSString *typeRelationshipName;
                            if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypeBatting) {
                                typeRelationshipName = @"batting";
                            } else if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypePitching) {
                                typeRelationshipName = @"pitching";
                            } else if ((_statsDisplay.type & StatsDisplayStatTypeMask) == StatsDisplayStatTypeFielding) {
                                typeRelationshipName = @"fielding";
                            } else
                                typeRelationshipName = @"manager";
                            NSString *typeRelationshipKeyPath = [NSString stringWithFormat:@"%@Seasons.@distinctUnionOfObjects.yearID",typeRelationshipName];
                            NSSet *typeRelationshipSet = [aMaster valueForKeyPath:typeRelationshipKeyPath];
                            NSNumber *seasonsCount = [NSNumber numberWithInteger:[typeRelationshipSet count]];
                            if ([seasonsCount integerValue]>0) {
                                NSDictionary *guyToAdd = @{@"fullName":[aMaster fullName],@"seasons":seasonsCount,@"playerID":aMaster.playerID};
                                [allSeasons addObject:guyToAdd];
                                if ([aMaster.playerID isEqualToString:[_statsSource valueForKey:@"playerID"]]) ourGuy = guyToAdd;
                            }
                        }
                        // Sort by seasons count, high to low.
                        [allSeasons sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
                            NSDictionary *p1 = (NSDictionary *)obj1;
                            NSDictionary *p2 = (NSDictionary *)obj2;
                            // Putting p2 first creates a reverse sort (high to low).
                            return [(NSNumber *)p2[@"seasons"] compare:(NSNumber *)p1[@"seasons"]];
                        }];
                        // Find our guy, or suitable insertion point.
                        [self computeSectionsandNotifyDoneForRoster:allSeasons sourceObject:ourGuy];
                        return;
                    } else {
                        [getAllRecordsOfType setPropertiesToFetch:@[entityProperties[sD.key]]];
                        NSString *noQuotesFormatString = [NSString stringWithFormat:@"%%K != -1 AND %@>%%d",minimumPredicateKey];
                        getAllRecordsOfTypePredicate = [NSPredicate predicateWithFormat:noQuotesFormatString,sD.key,mininum_games];
                    }
                    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
                    if (appDel.latest_year_in_database < LATEST_DATA_YEAR && ![entityName hasSuffix:@"Totals"]) {
                        // If haven't purchased the latest,
                        NSString *allTimePredicateString = [getAllRecordsOfTypePredicate predicateFormat];
                        allTimePredicateString = [NSString stringWithFormat:@"%@ AND yearID < %d",allTimePredicateString,LATEST_DATA_YEAR];
                        getAllRecordsOfTypePredicate = [NSPredicate predicateWithFormat:allTimePredicateString];
                    }
                    [getAllRecordsOfType setPredicate:getAllRecordsOfTypePredicate];
                    NSSortDescriptor *sortByKey = [[NSSortDescriptor alloc] initWithKey:sD.key ascending:sD.ascending];
                    NSArray *descriptors = @[sortByKey];
                    NSError *getAllRecordsError = nil;
                    if (can_combine_fetch_with_sort)
                        [getAllRecordsOfType setSortDescriptors:descriptors];
                    // Boom. This gets ALL batting/pitching/etc. records, ie. could be 90K results.
                    roster = [_managedObjectContext executeFetchRequest:getAllRecordsOfType error:&getAllRecordsError];
                    if (!can_combine_fetch_with_sort) {
                        roster = [roster sortedArrayUsingDescriptors:descriptors];
                    }
                } else { // predicate != TRUEPREDICATE.
                    // Season or Franchise. (not always really getTeamsForYear)
                    NSFetchRequest *getTeamsForYear = [[NSFetchRequest alloc] init];
                    [getTeamsForYear setEntity:[NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext]];
                    NSPredicate *modifiedPredicate = [_predicate copy];
                    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
                    if (appDel.latest_year_in_database < LATEST_DATA_YEAR) {
                        // If haven't purchased the latest,
                        NSString *modifiedPredicateString = [modifiedPredicate predicateFormat];
                        modifiedPredicateString = [NSString stringWithFormat:@"%@ AND yearID < %d",modifiedPredicateString,LATEST_DATA_YEAR];
                        modifiedPredicate = [NSPredicate predicateWithFormat:modifiedPredicateString];
                    }
                    [getTeamsForYear setPredicate:modifiedPredicate];
                    NSError *fetchError = nil;
                    teamsForYear = [_managedObjectContext executeFetchRequest:getTeamsForYear error:&fetchError];
                    roster = [self rosterFromTeamsForYear:teamsForYear];
                }
            } else { // predicate==nil.
                // Team, ie. this team this year.
                teamsForYear = @[[_statsSource valueForKeyPath:@"aTeamSeason"]];
                roster = [self rosterFromTeamsForYear:teamsForYear];
            }
            // We have sorted 'roster'. Roster is array of Batting/Pitching/Fielding/Manager records.
            // Now produce section0Roster, section1Roster (in this case section 0 has max 20 entries, and section 1 has 0-7 entries),
            // and toSelectIndex (either 0-19 if in section0 or 20-26 if in section1).
            // Get first 20 of them for first section, or all if showAll.
            // Use custom binary search method. Finds object or a decent place to insert it.
            [self computeSectionsandNotifyDoneForRoster:roster sourceObject:_statsSource];
        }
         ];
    }
}

// Produces section0Roster and section1Roster
-(void)computeSectionsandNotifyDoneForRoster:(NSArray *)roster sourceObject:(id)sourceObject
{
    StatDescriptor *sD = _statsDisplay.statDescriptors[[_descriptorIndex integerValue]];
    NSInteger insertion_point = [roster binarySearchForObject:sourceObject compareKey:sD.key ascending:sD.ascending];
    NSMutableArray *section0ArrayStaging;
    NSMutableArray *section1ArrayStaging = [[NSMutableArray alloc] init];
    if (showAll) {
        section0ArrayStaging = [roster mutableCopy]; // Could be really big! *** Maybe just pass first 30-40 elements to this thing?
    } else {
        section0ArrayStaging = [[NSMutableArray alloc] init];
        // Construct a proposed section 0 array.
        [section0ArrayStaging addObjectsFromArray:[roster objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(20, [roster count]))]]];
        // Our guy might not have had enough AB's or Innings Pitched to be in there, so maybe add him.
        // See where he would go.
        if (insertion_point < 20) { // If we belong in section 0,
            // See if we are already there. If not, add us.
            // Compare managerIDs if managers, or playerIDs if players.
            NSComparisonResult id_compare;
            id_compare = [[roster[insertion_point] valueForKey:@"playerID"] compare:[sourceObject valueForKey:@"playerID"]];
            if (id_compare!=NSOrderedSame) { // If not already there, add it.
                [section0ArrayStaging insertObject:sourceObject atIndex:insertion_point];
                if ([section0ArrayStaging count] > 20)
                    [section0ArrayStaging removeLastObject];
            }
            // There is no section 1 in this case.
        } else { // Section 0 has 20 guys. Construct section 1.
            // Normally start 3 before, then our guy, then 3 after, total 7.
            NSInteger copy_start = insertion_point - 3;
            NSInteger copy_length = 7;
            // Adjust if that would go off the edge before or after.
            if (insertion_point < 23) copy_start = 20;
            if (copy_start + copy_length > [roster count]) copy_length = [roster count] - copy_start - 1;
            _section1_rank_start = copy_start;
            [section1ArrayStaging addObjectsFromArray:[roster objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(copy_start,copy_length)]]];
            insertion_point -= copy_start;
            if (insertion_point == [section1ArrayStaging count]) {
                // This guy has an ERA higher than any of the qualifiers (or BA lower etc.)
                // Add at the end.
                [section1ArrayStaging addObject:sourceObject];
                // Not sure if we have to do the remove one object if more than 7 thing?
            }
            else {
                // Compare managerIDs if managers, or playerIDs if players.
                NSComparisonResult id_compare;
                id_compare = [[section1ArrayStaging[insertion_point] valueForKey:@"playerID"] compare:[sourceObject valueForKey:@"playerID"]];
                if (id_compare!=NSOrderedSame) { // if our guy is not in there, put him in.
                    [section1ArrayStaging insertObject:sourceObject atIndex:insertion_point];
                    if ([section1ArrayStaging count] > 7)
                        [section1ArrayStaging removeLastObject];
                }
            }
            insertion_point += [section0ArrayStaging count]; // put selection in section 1.
        }
    }
    // Construct arrays of object id's only.
    self.section0Roster = [[NSMutableArray alloc] init];
    for (NSManagedObject *anObject in section0ArrayStaging) {
        if ([anObject isKindOfClass:[NSManagedObject class]])
            [_section0Roster addObject:[anObject objectID]];
        else
            [_section0Roster addObject:anObject];
    }
    self.section1Roster = [[NSMutableArray alloc] init];
    if ([section1ArrayStaging count] > 0) {
        for (NSManagedObject *anObject in section1ArrayStaging) {
            if ([anObject isKindOfClass:[NSManagedObject class]])
                [_section1Roster addObject:[anObject objectID]];
            else [_section1Roster addObject:anObject];
        }
    }
    self.toSelectIndex = insertion_point;
    // pass empty NSMutableArray _section1Roster if needed.
    NSDictionary *userInfoDict = @{@"section0Roster": _section0Roster,@"section1Roster": _section1Roster,@"section1_rank_start": @(_section1_rank_start),@"toSelectIndex": @(_toSelectIndex)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataIsReadyNotification" object:nil userInfo:userInfoDict];
}



@end
