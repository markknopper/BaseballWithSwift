//
//  QueryBuilderViewController.m
//  BaseballWithSwift
//
//  Created by Matthew Jones on 4/23/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "QueryBuilderViewController.h"
#import "RootTabBarController.h"
#import "BaseballQueryAppDelegate.h"
#import "QueryResultsViewController.h"
#import "StatsFormatter.h"
#import "ThisYear.h"
#import "StatHead.h"

@implementation QueryBuilderViewController

//
//     "queryTableContent" is an array of dictionaries, corresponding to sections.
//     Each section of the table view has a dictionary
//             sectionTitle - to display
//             action - to perform when a row in the section is selected
//             rows   - an array of labels or expressions
//			   displayRows - humanly readable strings to display in the table (if null, use rows value)
//              queryPart -
//              showinCareer - boolean NSNumber
//

#pragma mark -
#pragma mark View lifecycle

-(NSDictionary *) queryBuilderSectionWithTitle:(NSString *)sectionTitle action:(NSString *)action queryPart:(NSString *)queryPart rows:(NSArray *)rows {
	NSDictionary *queryBuilderSection = @{@"sectionTitle": sectionTitle,
			@"action": action,
			@"queryPart": queryPart,
			@"rows": rows};
	return queryBuilderSection;
}

-(void)setUpDefaultQuery
{
	//
	// TODO need a more systematic way to set and advertise default values
	// Perhaps could designate the default values in the dictionary (so they can be displayed somehow)
	//
	self.statKind = @"Batting";
	self.resultSize = @10;
	self.sortAscending = @NO;
	self.statInternalName = @"hR";
    self.statDisplayName = @"Home Runs";
    // predicates is never nil, though could be array of count zero.
	self.predicates = [[NSMutableArray alloc] init];
	self.variableBindings = [[NSMutableDictionary alloc] init];
    // Each stat is a dict with key displayNames=array of display names, and key internalNames=parallel array of internal names. If we want to get fancy, add key="default" with internal name of default stat. Otherwise first in the list is the default.
    // *** Better way: have a data structure for each stat with displayName/internalName/sortAscending. Well, we now have
    // *** displayName/internalName but ascending is set in method setSortAscendingBasedOnInternalStatName.
    
    // Batting lowest first: none
    NSDictionary *battingStats = @{@"displayNames":@[@"Home Runs",@"Batting Average",@"On-Base Percentage",@"Runs Batted In",@"More..."],@"internalNames":@[@"hR",@"bA",@"oBP",@"rBI",@"More..."]};
    // Pitching lowest first: BB, ERA
    NSDictionary *pitchingStats = @{@"displayNames":@[@"Strikeouts",@"Walks",@"Earned Run Average",@"More..."],@"internalNames":@[@"sO",@"bB",@"eRA",@"More..."]};
    // Fielding lowest first: E
    NSDictionary *fieldingStats = @{@"displayNames":@[@"Fielding Percentage",@"Errors",@"Assists",@"Putouts",@"More..."],@"internalNames":@[@"fPct",@"e",@"a",@"pO",@"More..."]};
    // Managing lowest first: L
    NSDictionary *managingStats = @{@"displayNames":@[@"Wins",@"Losses",@"Percentage",@"Games"],@"internalNames":@[@"w",@"l",@"percentage",@"g"]};
	self.statKinds = @{@"Batting": battingStats,
					  @"Pitching": pitchingStats,
					  @"Fielding": fieldingStats,
					  @"Managers": managingStats};
    // Complete lists of stats that can be selected for More...
    // batting stats that need sort lowest first: SO, CS
    NSDictionary *battingStatsMore = @{@"displayNames":@[@"Games",@"At Bats",@"Runs",@"Hits",@"Slugging Percentage",@"OPS",@"Strikeouts",@"Doubles",@"Triples",@"Stolen Bases",@"Caught Stealing",@"Walks"],@"internalNames":@[@"g",@"aB",@"r",@"h",@"sLG",@"oPS",@"sO",@"doubles_2B",@"triples_3B",@"sB",@"cS",@"bB"]};
    // Pitching lowest first: L, baOpp, H, R, ER, HR, HBP, WP, BK
    NSDictionary *pitchingStatsMore = @{@"displayNames":@[@"Wins",@"Losses",@"W-L%",@"Games",@"Innings Pitched",@"Opposing Batting Average",@"Games Started",@"Batters Faced",@"Hits",@"Runs",@"Earned Runs",@"Home Runs",@"Hit By Pitch",@"Intentional Walks",@"Wild Pitches",@"Shutouts",@"Saves",@"Complete Games",@"Games Finished",@"Balks",@"WHIP"],@"internalNames":@[@"w",@"l",@"percentage",@"g",@"iPOuts",@"bAOpp",@"gS",@"bFP",@"h",@"r",@"eR",@"hR",@"hBP",@"iBB",@"wP",@"sHO",@"sV",@"cG",@"gF",@"bK",@"wHIP"]};
    // Fielding More lowest first: PB
    NSDictionary *fieldingStatsMore = @{@"displayNames":@[@"Games",@"Games Started",@"Double Plays",@"Innings",@"Caught Stealing (C)",@"Passed Balls (C)"],@"internalNames":@[@"g",@"gS",@"dP",@"innOuts",@"cS",@"pB"]};
    self.statKindsMore = @{@"Batting": battingStatsMore,
                          @"Pitching": pitchingStatsMore,
                          @"Fielding": fieldingStatsMore};
	NSArray *statKindSectionRows = @[@"Batting",@"Pitching", @"Fielding", @"Managers"];
	NSDictionary *statKindSection = [self queryBuilderSectionWithTitle:@"Select Kind of Statistic" action:@"selectStatKind" queryPart:@"statKind" rows:statKindSectionRows];
    // Once kind of stat is selected, another section with individual
    // stat names is inserted.
    //
    // The yearPred's go away for Career.
	NSDictionary *yearPredSection1 = @{@"sectionTitle": @"Select Beginning Year of Range (Default 1871)",
									  @"action": @"addPredicate",
									  @"queryPart": @"predicates",
									  @"rows": @[@"yearID >= $PICK000000"],
									  @"displayRows": @[@"1871"],
                                       @"showInCareer": @NO};
    BaseballQueryAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSString *latestYearString = [NSString stringWithFormat:@"%ld",(long)appDel.latest_year_in_database];
    NSString *yearPred2Title = [NSString stringWithFormat:@"Select Ending Year of Range (Default %@)",latestYearString];
	NSDictionary *yearPredSection2 = @{@"sectionTitle": yearPred2Title,
									  @"action": @"addPredicate",
									  @"queryPart": @"predicates",
									  @"rows": @[@"yearID <= $PICK000001"],
                                       @"displayRows": @[latestYearString],
                                       @"showInCareer": @NO};
    // Once a result size is selected the section shrinks to just the one row.
	NSDictionary *resultSizeSection = @{@"sectionTitle": @"Select Number of Results \n(Default 10)",
									   @"action": @"setResultSize",
									   @"queryPart": @"resultSize",
									   @"rows": @[@10,@20,@50]};
    // Once sort order is selected the section shrinks to just the one row.
	NSDictionary *sortAscendingSection = @{@"sectionTitle": @"Select Sort Order (Default High to Low)",@"action": @"setSortAscending",@"queryPart": @"sortAscending",@"rows": @[@"High to Low",@"Low to High"]};
	self.queryTableContent = [NSMutableArray arrayWithObjects:
					statKindSection,
					yearPredSection1,
					yearPredSection2,
					resultSizeSection,
					sortAscendingSection,
					nil];
    self.originalContent = [self.queryTableContent copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setUpDefaultQuery];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Use buttons specified in storyboard.
    self.tabBarController.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
    self.tabBarController.navigationItem.titleView = self.navigationItem.titleView;
    self.tabBarController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_queryTableContent count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[_queryTableContent[section] valueForKeyPath:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_queryTableContent[section] valueForKeyPath:@"sectionTitle"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"QueryBuilderCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (_queryTableContent[indexPath.section][@"displayRows"]!=nil)
		cell.textLabel.text = [[_queryTableContent[indexPath.section] valueForKeyPath:@"displayRows"][indexPath.row] description];
	else
		cell.textLabel.text = [[_queryTableContent[indexPath.section] valueForKeyPath:@"rows"][indexPath.row] description];
    // Put a check mark by the default value. Or the value that is actually going to be used, ie. sortAscending corresponds to Low to High.
    // Selecting the stat to be used, ie. Fielding Errors, sets this correctly
    // so put a check mark by the right place.
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[_queryTableContent[indexPath.section] valueForKeyPath:@"sectionTitle"] hasPrefix:@"Select Sort Order"]) {
        if (([cell.textLabel.text isEqualToString:@"Low to High"] && [_sortAscending boolValue]) || ([cell.textLabel.text isEqualToString:@"High to Low"] && ![_sortAscending boolValue])) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    // Mark default for statKind
    if ([[_queryTableContent[indexPath.section] valueForKeyPath:@"sectionTitle"] hasPrefix:@"Select Kind of Statistic"]) {
        if ([cell.textLabel.text isEqualToString:_statKind]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    // Mark default for number of results
    if ([[_queryTableContent[indexPath.section] valueForKeyPath:@"sectionTitle"] hasPrefix:@"Select Number of Results"]) {
        if ([cell.textLabel.text isEqualToString:[NSString stringWithFormat:@"%@",_resultSize]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

#pragma mark Animated section expanding and compressing

- (void)compressSelectedSection {
    // Compress the number of rows in the section to 1, with just the selected choice.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger number_of_rows_in_section = [_queryTableContent[indexPath.section][@"rows"] count];
    NSInteger selected_row = indexPath.row;
    NSMutableDictionary *contentObject = [NSMutableDictionary dictionaryWithDictionary:_queryTableContent[indexPath.section]];
    contentObject[@"rows"] = @[_queryTableContent[indexPath.section][@"rows"][indexPath.row]];
    // First adjust the content property to reflect shrunken section.
    (self.queryTableContent)[indexPath.section] = contentObject;
    // Then compute table rows to delete.
    NSMutableArray *listOfIndexRowsToDelete = [[NSMutableArray alloc] initWithCapacity:number_of_rows_in_section-1];
    for (NSInteger this_row=0;this_row<number_of_rows_in_section;this_row++) {
        if (this_row != selected_row) {
            [listOfIndexRowsToDelete addObject:[NSIndexPath indexPathForRow:this_row inSection:indexPath.section]];
        }
    }
    // Animate row deletion.
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:listOfIndexRowsToDelete withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)expandSelectedSection {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger number_of_rows_to_delete = [_queryTableContent[indexPath.section][@"rows"] count];
    if ([_queryTableContent[indexPath.section][@"action"] isEqualToString:@"selectStat"]) {
        // This section is the stat list specific to this stat kind.
        _queryTableContent[indexPath.section] = _originalStatSection;
    } else if ([_queryTableContent[indexPath.section][@"action"] isEqualToString:@"selectFieldingPosition"]) {
        _queryTableContent[indexPath.section] = _originalFieldingPositionSection;
    } else // Go back to original content for this section.
        // But a new section was added (individual stat list section)! Can't assume original section number matches. Need to look for unique sectionTitle.
    {
        NSString *selectedSectionTitle = [_queryTableContent[indexPath.section] valueForKey:@"sectionTitle"];
        // Find this section in original content.
        NSUInteger original_section = [_originalContent indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj valueForKey:@"sectionTitle"] isEqualToString:selectedSectionTitle]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        _queryTableContent[indexPath.section] = _originalContent[original_section];
    }
    NSMutableArray *listOfIndexRowsToDelete = [[NSMutableArray alloc] initWithCapacity:number_of_rows_to_delete];
    NSInteger this_row;
    for (this_row=0;this_row<number_of_rows_to_delete;this_row++) {
        [listOfIndexRowsToDelete addObject:[NSIndexPath indexPathForRow:this_row inSection:indexPath.section]];
    }
    NSInteger number_of_rows_to_add = [_queryTableContent[indexPath.section][@"rows"] count];
    NSMutableArray *listofIndexRowsToAdd = [[NSMutableArray alloc] initWithCapacity:number_of_rows_to_add];
    for (this_row=0;this_row<number_of_rows_to_add;this_row++) {
        [listofIndexRowsToAdd addObject:[NSIndexPath indexPathForRow:this_row inSection:indexPath.section]];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:listOfIndexRowsToDelete withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:listofIndexRowsToAdd withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark Actions from content table

//
//  Permit the user to select the kind of statistic.
//  Install the proper list of stat choices when this is selected.
//
- (void)selectStatKind {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([_queryTableContent[indexPath.section][@"rows"] count]==1) {
        // Section already compressed, ie. chose Batting, Pitching, Fielding, Managers. So next section is already list of stats for that kind. In this case we want to let the user reset the stat kinds list, which involves deleting the following stat section.
        [self expandSelectedSection]; // Put stat kind choices back.
        if ([_queryTableContent[indexPath.section+1][@"action"] isEqualToString:@"selectFieldingPosition"]) {
            [_queryTableContent removeObjectAtIndex:indexPath.section+1];
            NSIndexSet *sectionToDelete = [NSIndexSet indexSetWithIndex:indexPath.section+1];
            [self.tableView beginUpdates];
            [self.tableView deleteSections:sectionToDelete withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        // See if the next section is stat choices.
        if ([_queryTableContent[indexPath.section+1][@"action"] isEqualToString:@"selectStat"]) {
            [_queryTableContent removeObjectAtIndex:indexPath.section+1];
            NSIndexSet *sectionToDelete = [NSIndexSet indexSetWithIndex:indexPath.section+1];
            [self.tableView beginUpdates];
            [self.tableView deleteSections:sectionToDelete withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    } else { // Choosing a stat kind.
        [self compressSelectedSection];
        // Add next section of stats particular to this stat kind.
        NSDictionary *section = _queryTableContent[indexPath.section];
        // There is just one row since we compressed the section.
        self.statKind = [section valueForKeyPath:@"rows"][0];
        if ([_statKind isEqualToString:@"Fielding"]) {
            // Well you know, fielding stats really only make sense
            // within a position. So, create a whole new section here
            // that allows selecting a position.
            NSArray *positionDisplayNames = @[@"Pitcher",@"Catcher",@"First Base",@"Second Base",@"Third Base",@"Shortstop",@"Left Field",@"Center Field", @"Right Field"];
            NSDictionary *fieldingPositionSection = [self queryBuilderSectionWithTitle:@"Select Fielding Position" action:@"selectFieldingPosition" queryPart:@"pOS" rows:positionDisplayNames];
            self.originalFieldingPositionSection = [fieldingPositionSection copy]; // Needs to be a copy because originalStatSection is mutable. Not sure that it has to be.
            [_queryTableContent insertObject:fieldingPositionSection atIndex:indexPath.section+1];
            [self.tableView beginUpdates];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section+1] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        } else
            [self addSectionToSelectStatisticForStatKind];
    }
}

-(void)addSectionToSelectStatisticForStatKind
{
    // _statKinds is a dictionary now.
    NSArray *statsSectionRows = [[self.statKinds valueForKeyPath:self.statKind] valueForKey:@"displayNames"];
    self.statDisplayName = statsSectionRows[0]; // Default stat is first in list for stat kind, eg. SO for Pitching.
    self.statInternalName = [[self.statKinds valueForKeyPath:self.statKind] valueForKey:@"internalNames"][0];
    [self setSortAscendingBasedOnInternalStatName];
    NSDictionary *statsSection = [self queryBuilderSectionWithTitle:[NSString stringWithFormat:@"Select %@ Statistic",_statKind] action:@"selectStat" queryPart:@"statInternalName" rows:statsSectionRows];
    self.originalStatSection = [statsSection copy]; // save this
    // Insert this after current section rather than replacing it.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [_queryTableContent insertObject:statsSection atIndex:indexPath.section+1];
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section+1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark StatPickerViewControllerDelegate

-(void)pickerDidSelectAStatAtRow:(NSInteger)selected_picker_row;
{
    // Need to replace "More..." in list with chosen stat,
    // so that when compressed to one row the chosen stat is displayed.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    self.statInternalName = _statKindsMore[_statKind][@"internalNames"][selected_picker_row];
    self.statDisplayName = _statKindsMore[_statKind][@"displayNames"][selected_picker_row];
    [self setSortAscendingBasedOnInternalStatName];
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithDictionary:_queryTableContent[indexPath.section]];
    NSMutableArray *rowsArray = [NSMutableArray arrayWithArray:sectionDict[@"rows"]];
    rowsArray[indexPath.row] = _statDisplayName;
    sectionDict[@"rows"] = rowsArray;
    _queryTableContent[indexPath.section] = sectionDict;
    [self compressSelectedSection];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

//
//  Permit the user to select the statistic to query for.
// User has clicked on a stat in the stat section.
//
- (void)selectStat {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSDictionary *section = _queryTableContent[indexPath.section];
	// section key "rows" has an array of stat choices, eg. HR, RBI, SB, SO, More...
    NSArray *statChoices = section[@"rows"];
    if ([statChoices count]==1) {
        // It's already chosen and compressed. Unchoose and decompress this section.
        [self expandSelectedSection];
        self.statDisplayName = nil;
        self.statInternalName = nil;
    } else {
        self.statDisplayName = statChoices[indexPath.row];
        self.statInternalName = [[_statKinds valueForKey:_statKind] valueForKey:@"internalNames"][indexPath.row];
        [self setSortAscendingBasedOnInternalStatName];
        // Check for "More..." which opens up a whole new picker of worms.
        if ([self.statDisplayName isEqualToString:@"More..."]) {
            [self performSegueWithIdentifier:@"queryToMore" sender:self];
        }
        else
            [self compressSelectedSection];
    }
}

-(void)selectFieldingPosition
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *section = _queryTableContent[indexPath.section];
    // section key "rows" has an array of fielding positions, eg. 1B, 2B, etc. Has one if user already selected, or all 9.
    NSArray *positionsInList = section[@"rows"];
    if ([positionsInList count]==1) {
        [self expandSelectedSection];
        self.fieldingPositionSelected = nil;
    } else {
        // Assumes positions are ordered in list!!
        self.fieldingPositionSelected = [StatHead positionNameFromPositionNumber:@(indexPath.row + 1)];
        [self setSortAscendingBasedOnInternalStatName];
        [self compressSelectedSection];
        [self addSectionToSelectStatisticForStatKind];
    }
}

//
// setSortAscendingBasedOnInternalStatName - Certain stats need to have sort order changed.
// Call this method to set the default appropriately.
// *** Should be driven by the tables above rather than a method. But it's not very much
// *** code and it's only called from two places so don't worry about it for now.
//
-(void)setSortAscendingBasedOnInternalStatName
{
    self.sortAscending = @NO; // Default is high to low.
    NSArray *statsNeedingLowToHigh;
    if ([_statKind isEqualToString:@"Batting"])
        statsNeedingLowToHigh = @[@"sO",@"cS"];
    else if ([_statKind isEqualToString:@"Pitching"])
        statsNeedingLowToHigh = @[@"bB", @"eRA",@"l", @"bAOpp", @"h", @"r", @"eR", @"hR", @"hBP", @"wP", @"bK",@"wHIP"];
    else if ([_statKind isEqualToString:@"Fielding"])
        statsNeedingLowToHigh = @[@"e",@"pB"];
    else if ([_statKind isEqualToString:@"Managers"])
        statsNeedingLowToHigh = @[@"l"];
    if ([statsNeedingLowToHigh containsObject:_statInternalName])
        self.sortAscending = @YES;
}

//
//  Add the selected predicate to the query. From Select Beginning Year ($PICK000000) or Select Ending Year ($PICK000001).
//
- (void)addPredicate {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSDictionary *section = _queryTableContent[indexPath.section];
	NSString *stringPred = [section valueForKeyPath:@"rows"][indexPath.row];
	NSRange subVariableRange = [stringPred rangeOfString:@"$PICK"];
	if (subVariableRange.location != NSNotFound) { // Would always have to be found, I think.
        // It's actually YearPicker, not NumberPicker, now.
        [self performSegueWithIdentifier:@"queryToNumberPicker" sender:self];
    }
}

#pragma mark Picker View Delegate (for YearPickerViewController)

-(void)yearPickerViewController:(UIViewController *)viewController didFinishWithSave:(BOOL)save {
	if (save) { // save==false means user cancelled.
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		YearPickerViewController *npvc = (YearPickerViewController *)viewController;
        // context is $PICK00000+0 or 1 for beginning or ending year, and pickedValue is the year value.
        // Seems like context could be a boolean (begin=true, end=false) maybe.
		NSString *variableName = (NSString *)npvc.context;
		_variableBindings[variableName] = npvc.pickedValue;
        // So variableBindings is a dictionary with key $PICK000000 having value of picked beginning year value, and $PICK000001 having value of picked ending year value.
        NSDictionary *section = _queryTableContent[indexPath.section];
        NSString *stringPred = [section valueForKeyPath:@"rows"][indexPath.row];
        // Only add predicate once. Doesn't help much to have multiples.
        if (![_predicates containsObject:stringPred]) [self.predicates addObject:stringPred];
        // Update content with picker result.
        NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithDictionary:_queryTableContent[indexPath.section]];
        sectionDict[@"displayRows"] = @[[npvc.pickedValue description]];
        _queryTableContent[indexPath.section] = sectionDict;
        [self compressSelectedSection];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setResultSize
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSDictionary *section = _queryTableContent[indexPath.section];
    if ([[section valueForKeyPath:@"rows"] count]==1) {
        // Already compressed. Expand.
        [self expandSelectedSection];
    } else {
        self.resultSize = [section valueForKeyPath:@"rows"][indexPath.row];
        [self compressSelectedSection];
    }
}

- (void)setSortAscending {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSDictionary *section = _queryTableContent[indexPath.section];
    if ([[section valueForKeyPath:@"rows"] count]==1) {
        // Already compressed. Expand.
        [self expandSelectedSection];
    } else {
        self.sortAscending = (indexPath.row == 0) ? @NO : @YES;
        [self compressSelectedSection];
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *buildAction = _queryTableContent[indexPath.section][@"action"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(buildAction) withObject:indexPath];
#pragma clang diagnostic pop
}

#pragma mark Submit

// Submit button goes here, for 'getResults' segue.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationController.topViewController.title = nil; // Make back button just say 'Back'.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"getResults"]) {
        // Pressed "Submit" button on query screen.
        // *** Consider creating a BaseballQueryRequest object and putting all this stuff in it: predicates, variableBindings(what are those), statInternalName, statDisplayName, statKind, isCareer, sortAscending, and how about beginYear & endYear so we can display that in results. Delegate=self. After request is populated we do -start and then the code which is currently in QueryResultsVC would get started and then it would do delegate method queryDidComplete
        
        /* protocol like this:
         @protocol SKProductsRequestDelegate <SKRequestDelegate>
         
         @required
         // Sent immediately before -requestDidFinish:
         - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0);
         
         @end
*/
        QueryResultsViewController *vc = [segue destinationViewController];
        vc.resultSize = _resultSize;
        // predicates is an array of strings in the Builder. But when passing to Results, it is an NSCompoundPredicate.
        NSMutableArray *subPredicateBuilder = [NSMutableArray new];
        // predicates is never nil but could be an empty array
        for (NSString *aPredicateString in _predicates) {
            [subPredicateBuilder addObject:[NSPredicate predicateWithFormat:aPredicateString]];
        }
        if ([_statKind hasPrefix:@"Fielding"]) {
            // If either Fielding or FieldingTotals, it's position specific.
            if (_fieldingPositionSelected) {
                [subPredicateBuilder addObject:[NSPredicate predicateWithFormat:@"pos==%@",_fieldingPositionSelected]];
            } else {
                // User did not select a position. Make one up with defaults!
                self.fieldingPositionSelected = @"CF";
                // These might have already been the default?
                self.statInternalName = @"fPct";
                self.statDisplayName = @"Fielding Percentage";
            }
            vc.sectionTitleSuffix = _fieldingPositionSelected;
        }
        vc.predicates = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicateBuilder];
        // "An AND predicate with no subpredicates evaluates to TRUE."
        vc.variableBindings = _variableBindings;
        vc.statInternalName = _statInternalName;
        vc.statDisplayName = _statDisplayName;
        vc.statKind = _statKind;
        vc.career = FALSE; // Tell resultsVC this. It's cheating.
        if (_seasonCareerChooser.selectedSegmentIndex==1) {
            vc.career = TRUE;
            // 1 means Career (all-time), ie. Totals
            if ([_statKind isEqualToString:@"Managers"])
                vc.statKind = @"ManagerTotals";
            else // BattingTotals etc
                vc.statKind = [NSString stringWithFormat:@"%@Totals",_statKind];
        }
        vc.sortAscending = _sortAscending;
    } else if ([[segue identifier] isEqualToString:@"queryToNumberPicker"]) {
        NSDictionary *section = _queryTableContent[indexPath.section];
        NSString *stringPred = [section valueForKeyPath:@"rows"][indexPath.row];
        YearPickerViewController *nPVC = (YearPickerViewController *)[(UINavigationController *)[segue destinationViewController] topViewController];
        // Can't just pass this through to the UILabel because it hasn't loaded yet.
        nPVC.titleLabelText = [section valueForKey:@"sectionTitle"];
        //
        //  TODO change the $PICK thing to a boolean or some simpler way since it's just the beginning or ending year we are talking about right here.
        //
        NSRange subVariableRange = [stringPred rangeOfString:@"$PICK"];
        subVariableRange.length = 10;
        subVariableRange.location = subVariableRange.location+1;
		NSString *subVariable = [stringPred substringWithRange:subVariableRange];
        nPVC.context = subVariable; // This is weird how we store our data here.
        nPVC.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"queryToMore"]) {
        // New modern way of passing parameters to more picker.
        StatPickerViewController *statPicker = (StatPickerViewController *)[(UINavigationController *)[segue destinationViewController] topViewController];
        statPicker.selected_section = indexPath.section;
        statPicker.delegate = self;
        // Get array of more choices for Batting/Pitching/Fielding or Managing. Maybe teams?
        statPicker.statsChoices = self.statKindsMore[_statKind][@"displayNames"];
        statPicker.titleLabelText = _statKind;
    }
}

#pragma mark Clear Button

-(IBAction)clear:(id)sender {
	[self setUpDefaultQuery];
	[self.tableView reloadData];
}

#pragma mark Season-Career Button

- (IBAction)tappedSeasonCareer:(id)sender {
    // Changed between season and career.
    // Probably need to check if changes are needed first.
    // If season there should be years, if career not.
    // Check "showInCareer" key in content dict. If that key
    // exists and it is no and we are on career, then erase this section.
    NSInteger selected_segment = [_seasonCareerChooser selectedSegmentIndex];
    // If switched from season to career, delete the sections corresponding
    // to yearPredSection1 and yearPredSection2. Ie. Delete any section with
    // showInCareer=@NO.
    NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
    if (selected_segment==1) { // career
        for (NSInteger section_index=0; section_index<[_queryTableContent count]; section_index++) {
            NSNumber *showInCareerBool = [_queryTableContent[section_index] objectForKey:@"showInCareer"];
            if (showInCareerBool && ![showInCareerBool boolValue]) {
                [sectionsToDelete addIndex:section_index];
            }
        }
        [_queryTableContent removeObjectsAtIndexes:sectionsToDelete];
        // Since we are on career, remove all predicates beginning with "year".
        // This is a parallel structure to the sections, so there should
        // be some easier linkage than just searching like this.
        NSIndexSet *yearPreds = [_predicates indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj hasPrefix:@"year"]) {
                return YES; // Don't *stop, find all of them.
            }
            return NO;
        }];
        [_predicates removeObjectsAtIndexes:yearPreds];
        [_tableView beginUpdates];
        // UITableViewRowAnimationFade is much more beautiful than UITableViewRowAnimationAutomatic
        [_tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else if (selected_segment==0) { // season
        // If switched from career to season, insert the yearPreds following
        // statKindSection.
        // First find the "Select Number of Results" section, then insert just before.
        NSUInteger select_number_of_results_section_index = [_queryTableContent indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj valueForKey:@"sectionTitle"] hasPrefix:@"Select Number of Results"]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        // Find the two sections (with showInCareer=False) from _originalContent and add before select_number_of_results_section_index
        NSIndexSet *twoSectionIndexesToBeAdded = [_originalContent indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *showInCareerBool = [_originalContent[idx] objectForKey:@"showInCareer"];
            if (showInCareerBool && ![[obj objectForKey:@"showInCareer"] boolValue]) {
                return YES;
            }
            return NO;
        }];
        NSArray *twoSectionsToInsert = [_originalContent objectsAtIndexes:twoSectionIndexesToBeAdded];
        NSIndexSet *whereToInsertThem = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(select_number_of_results_section_index, 2)];
        [_queryTableContent insertObjects:twoSectionsToInsert atIndexes:whereToInsertThem];
        [_tableView beginUpdates];
        [_tableView insertSections:whereToInsertThem withRowAnimation:UITableViewRowAnimationAutomatic];
        // Then have to insert rows in each section? Guess not since there is only one.
        [_tableView endUpdates];
    }
}

@end

