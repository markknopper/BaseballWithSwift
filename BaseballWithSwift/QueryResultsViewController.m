//
//  QueryResultsViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 4/21/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "QueryResultsViewController.h"
#import "NSArray+BV.h"
#import "Managers.h"
#import "Master.h"
#import "BQPlayer.h"
#import "Batting+Query.h"
#import "PlayerTabBarController.h"
#import "BaseballQueryAppDelegate.h"
#import "NotifyTableView.h"
#import "StatsFormatter.h"
#import "BaseballWithSwift-Swift.h"
#import "StatsDisplay.h"
#import "StatHead.h"

@implementation QueryResultsViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.results = nil;
    [super viewDidLoad];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDel managedObjectContext];
    // Set up long press recognizer to Copy (image of) table to clipboard.
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.view addGestureRecognizer:longPress];
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *seasonOrCareer = @"Single Season";
    NSString *statKindToDisplay = _statKind;
    if ([[_statKind substringFromIndex:[_statKind length]-6] isEqualToString:@"Totals"])
    {
        seasonOrCareer = @"Career";
        statKindToDisplay = [statKindToDisplay substringToIndex:[_statKind length]-6];
    }
    // Add stat kind (Pitching, Manager etc.) to the name.
    seasonOrCareer = [NSString stringWithFormat:@"%@ %@",seasonOrCareer,statKindToDisplay];
    if (!_sectionTitleSuffix) self.sectionTitleSuffix = @" ";
    // WINS (TOP 10) SINGLE SEASON PITCHING YEARSTRING
    // where YEARSTRING is begin-end
    NSString *beginningYear = @"1871";
    if ([_variableBindings objectForKey:@"PICK000000"] != nil) {
        beginningYear = [_variableBindings objectForKey:@"PICK000000"];
    }
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *endingYear = [NSString stringWithFormat:@"%ld", (long)appDel.latest_year_in_database];
    if ([_variableBindings objectForKey:@"PICK000001"] != nil) {
        endingYear = [_variableBindings objectForKey:@"PICK000001"];
    }
    NSString *yearString = [NSString stringWithFormat:@"%@-%@", beginningYear, endingYear];
    self.sectionTitle = [NSString stringWithFormat:@"%@ (%@ %d) %@ %@ %@", _statDisplayName, [self.sortAscending boolValue] ? @"Bottom" : @"Top", [self.resultSize intValue],seasonOrCareer, _sectionTitleSuffix, yearString];
}

#pragma Long Press code for copy to pasteboard

-(void)longPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    // This fires multiple times so check state to only do once.
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[gestureRecognizer view]];
        /*
         Get the shared UIMenuController instance, and animate the menu onto the view
         */
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        [theMenu setTargetRect:CGRectMake(tapPoint.x, tapPoint.y, 0.0f, 0.0f) inView:[gestureRecognizer view]];
        [theMenu setMenuVisible:YES animated:YES];
    }
}

//
// copy - Create a whole separate table that is really long, and
// generate results (again) onto it. Use this for the view to copy
// to the pasteboard.
//
- (void)copy:(id)sender {
    // called when copy clicked in menu
    QueryResultsViewController *vc = [[QueryResultsViewController alloc] initWithNibName:@"QueryCoreDataView" bundle:nil];
    vc.resultSize = _resultSize;
    vc.predicates = _predicates;
    vc.variableBindings = _variableBindings;
    vc.statKind = _statKind;
    vc.statInternalName = _statInternalName;
    vc.statDisplayName = _statDisplayName;
    vc.sortAscending = _sortAscending;
    vc.managedObjectContext = _managedObjectContext;
	vc.results = self.results;
    UITableView *selfTable = (UITableView *)self.view;
    CGFloat total_height_in_points = selfTable.rowHeight * [vc.results count];
    CGFloat total_width = selfTable.frame.size.width;
    // Use special UITableView subclass that notifies on reloadData.
    NotifyTableView *noViewView = [[NotifyTableView alloc] initWithFrame:CGRectMake(0, 0, total_width, total_height_in_points)];
    noViewView.delegate = self;
    noViewView.dataSource = self;
    vc.view = noViewView;
    [noViewView reloadData];
}

//
// dataIsReloaded - NotifyTableView notification goes here on reloadData.
// Render to pasteboard.
//
-(void)dataIsReloaded:(UITableView *)offScreenTableView
{
    CGRect rect = [offScreenTableView bounds];
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[offScreenTableView.layer renderInContext:context];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
  	[gpBoard setValue:UIImageJPEGRepresentation(img,5) forPasteboardType:@"public.jpeg"];
}

- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

//
// results - Do fetch including possibly time consuming non-database calculations and sort. Returns 'results' property.

// ***There should probably be a request and response object for this thing. The processor thing should have the request and generate the response for the results displayer thing.
//
-(NSArray *)results
{
    SEL post_processing_method = nil;
    if (!_results) { // Data is static so results then are results now.
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSString *entityToFetch = _statKind;
        // Use new high tech tables.
        if ([_statKind isEqualToString:@"Batting"]) {
            entityToFetch = @"BattingCombinedStints";
        } else if ([_statKind isEqualToString:@"Pitching"]) {
            entityToFetch = @"PitchingCombinedStints";
        }
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityToFetch inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        // Set sort and predicate for non-transient properties.
        NSMutableArray *localPredicateArray = [NSMutableArray new];
        // Error check to prevent crash in executeFetchRequest later.
        if (_statInternalName && _statInternalName.length>0)
            [localPredicateArray addObject:[NSPredicate predicateWithFormat:@"%K != -1",_statInternalName]];
        if (!_career) {
            [localPredicateArray addObject:[NSPredicate predicateWithFormat:@"yearID > 1875"]];
        }
        // Set an array where each element is an array of:
        // Matching fields:
        // - "Season" or "Career" string, or @"" means match everything
        // - array of stat names that apply
        // Action fields:
        // - minimum pred string if any of these names apply or "" if none
        // - selector name for post-processing list that didn't have a result limit, or @"" if we should have a result limit and no selector (mutually exclusive)
        // - Entity name for fetch or "" for default
        
        // Go through this array to see if any of them apply.
        // Default is no minimums, no post-processing, therefore summable.
        NSArray *arraysOfControl = @[
                                     @[@"Season", @[@"bA",@"oBP",@"sLG",@"oPS"],@"aB > 200",@""],
                                     @[@"Season",@[@"eRA",@"bAOpp",@"wHIP"],@"",@"oneIPPerTeamGameThatSeason"],
                                     // For pitching percentage, do that method for both career and season.
                                     @[@"",@[@"percentage"],@"", @"oneDecisionForEveryTenTeamGames"],
                                     ];
        // See if we have anything in the arrayOfControl. Just use the first matching line, if any.
        // We have _statInternalName (bA), _career (bool), _statKind (Pitching).
        NSString *careerOrSeasonString = _career ? @"Career" : @"Season";
        NSString *minimumPredString = nil;
        BOOL minimum_predicate_exists = FALSE;
        for (NSArray *anArray in arraysOfControl) {
            BOOL career_or_season_match = FALSE;
            if ([anArray[0] isEqualToString:@""]) {
                career_or_season_match = TRUE;
            } else if ([anArray[0] isEqualToString:careerOrSeasonString]) {
                career_or_season_match = TRUE;
            }
            if (career_or_season_match && [anArray[1] containsObject:_statInternalName]) {
                minimumPredString = anArray[2];
                if (![minimumPredString isEqualToString:@""]) {
                    minimum_predicate_exists = TRUE;
                }
                if (![anArray[3] isEqualToString:@""]) {
                    post_processing_method = NSSelectorFromString(anArray[3]);
                }
                break;
            }
        }
        if ([_statKind isEqualToString:@"ManagerTotals"]) {
            [localPredicateArray addObject:[NSPredicate predicateWithFormat:@"g > 315"]];
        }

        // Baseball-reference.com says this about minimum decisions for pitching percentage leaders: The minimum number of decisions is the number of team games that season multiplied by 0.098 rounded up to the nearest integer. For seasons with 162 games this will require 16 decisions.
        
        // For season pitching W-L%, since they are only valid if W+L>=16, just don't include result size here and filter the result array later since we can't figure out how to include that math in the predicate. Similarly for career pitching, min is W+L>=100.
        // This would break for PitchingPost***
        
        if (minimum_predicate_exists) {
            [localPredicateArray addObject:[NSPredicate predicateWithFormat:minimumPredString]];
        }
        NSCompoundPredicate *andAll = nil;
        // localPredicateArray is either nil or an array of predicates.
        // _predicates is either nil or an NSCompoundPredicate
        if (localPredicateArray != nil) {
            if (_predicates) {
                NSArray *biggerPred = [@[_predicates] arrayByAddingObjectsFromArray:localPredicateArray];
                andAll = [NSCompoundPredicate andPredicateWithSubpredicates:biggerPred];
            } else { // localPredArray!=nil but _pred==nil
                andAll = [NSCompoundPredicate andPredicateWithSubpredicates:localPredicateArray];
            }
        } else if (_predicates)
            andAll = _predicates;
        fetchRequest.predicate = [andAll predicateWithSubstitutionVariables:_variableBindings];
        // This will crash on fetch predicate syntax error. But
        // we don't know what the syntax was! It's not in the crash logs. So at least don't crash.
        // do something that might throw an exception
        
        // For single season this needs add up the stints for that year!
        // Give me all records of type x with strikeouts descending but group records with same playerid and year and sum the strikeouts.
        
        // Need array of stat names for each stat type that can be summed, eg. W or sO but not eRA or fPct or percentage or bA.
        // So if it's a stat that can be summed, create an expression that will allow stints to be grouped.
        
        // If the stat is summable! The arraysOfControl should tell us this.
        // Also only do this if single season!
        // If not summable, just skip all of the groupBy and do the regular fetch.
        // Now, for pitchers single season we need to check if this stat is in a special list indicating to look up in the new improved PitchingCombinedStints table for leader results.

        /* 4 RULES:
        1-  @[@"Batting", @"Season", @[@"bA",@"oBP",@"sLG",@"oPS"],@"aB > 200",@"" ],
                - regular fetch, not summable, BattingCombinedStints entity. Regular fetch limit.
         Stints need to be grouped together so probably need a BattingCombinedStints table! *** Not to mention a Fielding one except that has to be by position? *** How about managing?
         Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks.
         2- @[@"Pitching",@"Season",@[@"eRA",@"bAOpp",@"wHIP"],@"",@"oneIPPerTeamGameThatSeason"],
                - regular fetch but use PitchingCombinedStints stat record type. No fetch limit.
         Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks.
         
         3- @[@"Pitching",@"",@[@"percentage"],@"", @"oneDecisionForEveryTenTeamGames"],
         single season: regular fetch with PitchingCombinedStints. No fetch limit.
         career: regular fetch with PitchingTotals. No fetch limit. Special way of looking up # of team games for multiple years in career I guess.
         Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks.
         
         4- Otherwise it's a summable stat. Use given stat record type, use fetch limit, no post-processing, default minimum predicate (or none?). But stints need to be combined so use expression and groupBY method.
         Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks.
         
         */
        
        /* Batting minimum rules:
         Statistic Description: Hits/At Bats For recent years, leaders need 3.1 PA per team game played
         
         Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks.
         
         Only players who finished in the top 40 for the majors in a season will appear on this list. (?)
         
         For batting rate stats, generally a minimum of 3.1 Plate Appearances/G, 1.0 IP/G, 0.67 Gm and Chances/Team Game (fielding), 0.2 SB att/Team Game (catchers), and 0.1 SB att/Team Game (baserunners only since 1951), and 0.1 decision/G for single-season leaderboards generally needed for rate statistics. For pitcher fielding the minimums are reduced by a third. For LF, CF, RF fielding stats, we only have reliable data since 1908, so all leaders are since 1908.
         
         PA = AB + BB + HBP + SH + SF + Times Reached on Defensive Interference
         
         Batting Average, OBP, Slugging Percentage, OPS
         
         This is outrageous. Just leave it AB>200 like above. ***
         Prior to 1920, a player must have appeared in 60% of the team's games to qualify for a title. This number was rounded to the nearest integer.
         From 1920-1937 (unclear, and previously thought to be until 1944), a player must have appeared in 100 games.
         From 1938-1944, the AL used 400 at bats and the NL stayed with 100 games, as discovered by Paul Rivard of SABR.
         From 1945-1956, a player must have 2.6 at bats per team game. Note, however, that from 1951-1954 a player could lead if they still led after the necessary number of hitless at bats were added to their at bat total.
         From 1957 to the present, a player must have 3.1 plate appearances per team game. Note, however, that from 1967 to the present a player could lead if they still led after the necessary number of hitless plate appearances were added to their at bat total.

         
         */
        NSError *error = nil;
        if (!post_processing_method) { // post-processing will take care of result limit. It needs the full results for filtering first.
            fetchRequest.fetchLimit = [_resultSize integerValue];
        }

        //if (minimum_predicate_exists || post_processing_method) {
            NSSortDescriptor *statSort = [NSSortDescriptor sortDescriptorWithKey:_statInternalName ascending:[_sortAscending boolValue]];
            fetchRequest.sortDescriptors = @[statSort];
            @try {
                _results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
            }
            @catch (NSException *exception) {
                // deal with the exception
                // ET phone home with bad fetch syntax *** ?
                _results = [NSArray new]; // return empty array
            }
        /*
        } else {
            // Maybe don't need this s*** since we have {Batting|Pitching|CombinedStints table which already sums everything.
            fetchRequest.resultType = NSDictionaryResultType;

            fetchRequest.propertiesToGroupBy = @[@"playerID", @"yearID"];
            NSExpression *stintExpression = [NSExpression expressionForKeyPath:_statInternalName];
            NSExpression *sumOfStints = [NSExpression expressionForFunction:@"sum:" arguments:@[stintExpression]];
            NSExpressionDescription *sumDesc = [NSExpressionDescription new];
            sumDesc.expression = sumOfStints;
            sumDesc.name = @"sum";
            sumDesc.expressionResultType = NSInteger16AttributeType;
            // Define one for objectID so we can get the actual core data object later.
            NSExpression *selfExp = [NSExpression expressionForEvaluatedObject];
            NSExpressionDescription *selfED = [[NSExpressionDescription alloc] init];
            selfED.name = @"objID";
            selfED.expression = selfExp;
            selfED.expressionResultType = NSObjectIDAttributeType;
            fetchRequest.propertiesToFetch = @[sumDesc, selfED, @"playerID", @"yearID"];
            @try {
                _results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
                NSArray<NSSortDescriptor *> *sumSort = @[[NSSortDescriptor sortDescriptorWithKey:@"sum" ascending:[_sortAscending boolValue]]];
                NSArray *resultsSorted = [_results sortedArrayUsingDescriptors:sumSort];
                if (resultsSorted.count > [_resultSize integerValue]) {
                    _results = [resultsSorted subarrayWithRange:NSMakeRange(0, [_resultSize integerValue])];
                } else {
                    _results = resultsSorted;
                }
            }
            @catch (NSException *exception) {
                // deal with the exception
                // ET phone home with bad fetch syntax *** ?
                _results = [NSArray new]; // return empty array
            }
        }
         */
    }
    if (post_processing_method != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // "performSelector may cause a leak because its selector is unknown"
        _results = [self performSelector:post_processing_method]; // That's it.
#pragma clang diagnostic pop
    }
    return _results;
}

// Methods from the arraysOfControl
//                                       @[@"Pitching",@"Season",@[@"eRA",@"bAOpp",@"wHIP"],@"",@"oneIPPerTeamGameThatSeason"],
-(NSArray *)oneIPPerTeamGameThatSeason {
    // Go through _results (sorted) and return the first _resultSize objects that match g>=one iPOuts per 162 (or however many games that team played that year).
    NSInteger i = 0;
    NSInteger result_count = 0;
    NSMutableArray *thePitchingRecords = [NSMutableArray new];
    do {
        id result = _results[i]; // This may now be a dictionary.
        // But it might also be a PitchingCombinedStints record which means the team will be nil! Need to make up a number or guess or what? Yeah how about just finding any team that year and using the number of games.
        NSNumber *yearID = [result valueForKey:@"yearID"];
        if (yearID.integerValue >= 1876) { // because baseball-reference says.
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"yearID == %@", yearID];
            [fetchRequest setPredicate:predicate];
            fetchRequest.fetchLimit = 1;
            NSError *error = nil;
            NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
            NSInteger team_games_that_season = [[fetchedObjects[0] valueForKey:@"g"] integerValue];
            //[self teamGamesWithResultsRecord:result];
            if ([[result valueForKey:@"iPOuts"] integerValue] >= team_games_that_season*3) {
                // Do sanity check. Dan Casey led the league in ERA in 1884 with 54 innings pitched. And in 2 games! But the team only played 18 games that year. Let's increase the minimum number to 50 innings arbitrarily.
                // Btw this is the famous "Casey at the Bat". https://sabr.org/bioproj/person/ec4f55fc
                if ([[result valueForKey:@"iPOuts"] integerValue] >= 50*3) {
                    [thePitchingRecords addObject:_results[i]];
                    result_count++;
                    if (result_count == [_resultSize integerValue]) break;
                }
            }
        }
        i++;
    } while (i < _results.count);
    return thePitchingRecords;
}

// Here for percentage (both season and career), which is not a summable stat therefore the results list is made up of Pitching records, not dictionaries.
-(NSArray *)oneDecisionForEveryTenTeamGames {
    // This means at least 16 decisions for modern teams.
    NSInteger i = 0;
    NSInteger result_count = 0;
    NSMutableArray *thePitchingRecords = [NSMutableArray new];
    // This may take a long time. Consider improving the minimums on fetch to make the sum of w + l > 5 or something to limit this loop. *** In addition, need to sum w and l for multiple stints. Even more complicated fetch expressions than normal ones above! ***
    do {
        id aPitchingRecord = _results[i];
        NSInteger w = [[aPitchingRecord valueForKey:@"w"] integerValue];
        NSInteger l = [[aPitchingRecord valueForKey:@"l"] integerValue];
        if (_career) {
            // In this case these are PitchingTotals records. How can we get number of seasons played? Decisions >= seasons * 162 / 10.
            // OK first get Master.
            Master *ourMaster = [aPitchingRecord valueForKey:@"player"];
            // Now get set of all years represented in pitchingSeasons.
            NSSet *uniqueYears = [ourMaster.pitchingSeasons valueForKey:@"yearID"];
            // *** Have to add up all years????
            if (w + l >= uniqueYears.count * 16.2) {
                [thePitchingRecords addObject:_results[i]];
                result_count++;
                if (result_count == [_resultSize integerValue]) break;
            }
        } else { // Single season requires 162/10 = 16 decisions for modern teams.
            // Baseball-reference.com says: "Note that seasons prior to 1876 are not included in single-season marks, but are included in career marks." https://www.baseball-reference.com/leaders/earned_run_avg_season.shtml
            if ([[aPitchingRecord valueForKey:@"yearID"] integerValue] >= 1876) {
                NSInteger team_games_that_season;
                if ([aPitchingRecord valueForKey:@"teamID"] == nil) {
                    // Guess in this case.
                    NSNumber *yearID = [aPitchingRecord valueForKey:@"yearID"];
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"yearID == %@", yearID];
                    [fetchRequest setPredicate:predicate];
                    fetchRequest.fetchLimit = 1;
                    NSError *error = nil;
                    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    team_games_that_season = [[fetchedObjects[0] valueForKey:@"g"] integerValue];
                } else {
                    team_games_that_season = [self teamGamesWithResultsRecord:aPitchingRecord];
                }
                NSInteger games_times_dot098_rounded_up = ceil(team_games_that_season * .098);
                if (w + l >= games_times_dot098_rounded_up) {
                    if (w + l >= 5) { // sanity filter for lowball results. Eg. Ed Cushman, Cleveland Indians 1884 had a 4-0 record and the team only had 12 games that year.
                        [thePitchingRecords addObject:_results[i]];
                        result_count++;
                        if (result_count == [_resultSize integerValue]) break;
                    }
                }
            }
        }
        i++;
    } while (i < _results.count);
    return thePitchingRecords;
}

-(NSInteger)teamGamesWithResultsRecord:(id)resultsRecord {
    NSManagedObject *statObject;
    if (![resultsRecord isKindOfClass:[NSManagedObject class]]) { // if dictionary
        NSManagedObjectID *objID = [resultsRecord valueForKey:@"objID"];
        statObject = [_managedObjectContext objectWithID:objID];
    } else {
        statObject = resultsRecord;
    }
    // StatObject (Batting or Pitching) has teamID and yearID.
    Teams *ourTeamYear = [Teams teamWithTeamID:[statObject valueForKey:@"teamID"] andYear:[statObject valueForKey:@"yearID"] inManagedObjectContext:self.managedObjectContext];
    NSInteger team_games_that_season = [ourTeamYear.g integerValue];
    return team_games_that_season;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

// Put the title here so that it gets copied with long press.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sectionTitle;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"QueryResultsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    id result = _results[indexPath.row]; // This may now be a dictionary.
    NSManagedObject *statObject;
    NSString *detailToDisplay = nil;
    if (![result isKindOfClass:[NSManagedObject class]]) { // if dictionary
        NSManagedObjectID *objID = [result valueForKey:@"objID"];
        statObject = [_managedObjectContext objectWithID:objID];
        detailToDisplay = [result objectForKey:@"sum"];
    } else {
        statObject = result;
    }
    if (!detailToDisplay) {
        detailToDisplay = [[result valueForKey:_statInternalName] description];
    }
    // Don't assume we have a BQPlayer or Master object or anything, but we do have the playerID from the statObj even if it is a PitchingCombinedStints thing.
    NSString *playerFullName = [StatHead playerNameFromPlayerID:[statObject valueForKey:@"playerID"] managedObjectContext:_managedObjectContext];
    NSString *entityName = _statKind;
    if (![[entityName substringFromIndex:[entityName length]-6] isEqualToString:@"Totals"]) {
        NSNumber *playerYear = [result valueForKey:@"yearID"];
        if (playerYear != nil)
            playerFullName = [NSString stringWithFormat:@"%@ (%@)",playerFullName,playerYear];
    }
	cell.textLabel.text = playerFullName;
    NSArray *statNamesNeedingThousandsTreatment = @[@"bA",@"oBP",@"sLG",@"oPS",@"fPct",@"percentage",@"wHIP",@"bAOpp"];
    if ([statNamesNeedingThousandsTreatment containsObject:_statInternalName]) {
        int batting_average = (1000 * [detailToDisplay floatValue]) + .5;
        detailToDisplay = [StatsFormatter averageInThousandForm:batting_average];
    } else if ([_statInternalName isEqualToString:@"eRA"]) {
        detailToDisplay = [NSString stringWithFormat:@"%1.2f",[detailToDisplay floatValue]];
    } else if ([_statInternalName isEqualToString:@"iPOuts"]) {
        detailToDisplay = [StatsFormatter inningsInDecimalFormFromInningOuts:[detailToDisplay integerValue]];
    }
	cell.detailTextLabel.text = [detailToDisplay description];
    return cell;
}

// We have both didSelectRow and prepareForSegue. Why? Well there is no storyboard segue so it comes here first, then we do performSegue and it goes to prepareForSegue. This is because the destination controller is conditional on who we are.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id someObject = _results[indexPath.row];
    NSManagedObject *statObject;
    if (![someObject isKindOfClass:[NSManagedObject class]]) { // if dictionary
        NSManagedObjectID *objID = [someObject valueForKey:@"objID"];
        statObject = [_managedObjectContext objectWithID:objID];
    } else {
        statObject = someObject; // It's already a managed object.
    }
    if ([[statObject.entity propertiesByName] objectForKey:@"yearID"])
        [self performSegueWithIdentifier:@"queryResultsToPlayer" sender:self];
    else
        [self performSegueWithIdentifier:@"queryResultsToCareer" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    id result = _results[indexPath.row]; // This may now be a dictionary.
    NSManagedObject *statObject;
    if (![result isKindOfClass:[NSManagedObject class]]) { // if dictionary
        NSManagedObjectID *objID = [result valueForKey:@"objID"];
        statObject = [_managedObjectContext objectWithID:objID];
    } else {
        statObject = result;
    }
    Master *selectedMaster = [statObject valueForKey:@"player"];
    if (selectedMaster == nil) { // May happen on PitchingCombinedStints record.
        selectedMaster = [Master masterRecordWithPlayerID:[statObject valueForKey:@"playerID"]];
    }
    BQPlayer *thisPlayer;
    if ([[segue identifier] isEqualToString:@"queryResultsToPlayer"]) {
        NSNumber *playerYear = [statObject valueForKey:@"yearID"];
        thisPlayer = [[BQPlayer alloc] initWithPlayer:selectedMaster yearID:playerYear];
        [[segue destinationViewController] setValue:playerYear forKey:@"year"];
        [[segue destinationViewController] setValue:nil forKey:@"team"];
        [[segue destinationViewController] setValue:_statKind forKey:@"statKindToSelect"];
    } else if ([[segue identifier] isEqualToString:@"queryResultsToCareer"]) {
        thisPlayer = [[BQPlayer alloc] initWithPlayer:selectedMaster yearID:nil];
        // Select correct tab too.
        NSString *statKindRemovingTotals = [_statKind substringToIndex:[_statKind length]-6];
        [[segue destinationViewController] setValue:statKindRemovingTotals forKey:@"statKindToSelect"];
    }
    [[segue destinationViewController] setValue:thisPlayer forKey:@"player"];
}

@end

