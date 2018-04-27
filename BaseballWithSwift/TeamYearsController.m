//
//  TeamYearsController.m
//
//  Created by Mark Knopper on 8/11/09.
//  Copyright 2009-2015 Bulbous Ventures LLC. All rights reserved.
//

/* Display years for team or franchise.
   Called from selecting a team in AllTeams view, or recursively
   in franchise view.
 */

#import "TeamYearsController.h"
#import "Teams.h"
#import "RosterViewController.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"
#import "ThisYear.h"

@implementation TeamYearsController

- (void)viewWillAppear:(BOOL)animated
{
	// Nav bar may have been hidden if coming here from years search results.
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[super viewWillAppear:animated];
}

// 
// viewDidLoad - build data in tableSectionData, which is an array of sections, whose objects are arrays
//    of rows for each section.
//
- (void)viewDidLoad {
    [super viewDidLoad];
	// Allocate global variables used in various cases. These are all released in -dealloc.
	_teamList = [[NSMutableArray alloc] init];
	self.tableSectionData = [[NSMutableArray alloc] init];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *franchiseNames;
	if (_franchise) { // means we are to do Franchise View, a list of franchises. This is the recursive version.
		number_of_franchises = 1;
		self.title = _franchise;
	} else { // one team view, ie. a list of years.
		if (!_teamName) return;
		self.title = _teamName; 
		// Fetch all franchise IDs with any team with this name (eg. will get CNR and CIN for Cincinnati Reds).
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
		[fetchRequest setEntity:entity];
        NSString *namePredicate = @"name == %@";
        if ([appDel excludeLatestYear]) namePredicate = @"name == %@ AND yearID<%d";
		NSPredicate *predicate = [NSPredicate predicateWithFormat:namePredicate, _teamName, LATEST_DATA_YEAR];
		[fetchRequest setPredicate:predicate];
		NSDictionary *entityProperties = [entity propertiesByName];
		[fetchRequest setPropertiesToFetch:@[entityProperties[@"franchID"]]];
		[fetchRequest setResultType:NSDictionaryResultType]; // Have to do this or setReturnsDistinctResults will be ignored.
		[fetchRequest setReturnsDistinctResults:YES];
		NSError *error = nil;
		franchiseNames = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
		self.franchise = [franchiseNames[0] valueForKey:@"franchID"]; // remember the first one, in case it's the only one.
		// So franchiseNames is an array of dictionaries each with one key "franchID" and value string.
		// If there is only one franchise for the requested team, generate a plain table with all the years
		// and scroll to the first occurrence of the requested team name.
		number_of_franchises = [franchiseNames count];
	}
	if (number_of_franchises == 1) {
		self.title = _franchise;
		// Now fetch all team/year objects for the (only) franchise. The result in this case is that
		// teamList is actually a list (array) of Teams.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
		[fetchRequest setEntity:entity];
        NSString *franchPredString = @"franchID == %@";
        if ([appDel excludeLatestYear]) franchPredString = [NSString stringWithFormat:@"%@ AND yearID<%d",franchPredString, LATEST_DATA_YEAR];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:franchPredString, _franchise];
		[fetchRequest setPredicate:predicate];
		NSSortDescriptor *yearSort = [[NSSortDescriptor alloc] initWithKey:@"yearID" ascending:YES];
		[fetchRequest setSortDescriptors:@[yearSort]];
		NSError *error = nil;
		[_teamList addObjectsFromArray:[_managedObjectContext executeFetchRequest:fetchRequest error:&error]];
        if ([_teamList count] >=20) { // Indices don't always make sense.
		NSInteger this_decade_number, current_decade_number = 0;
		NSMutableArray *currentDecadeArray=nil;
		for (Teams *aTeam in _teamList) {
			NSInteger this_year = [aTeam.yearID integerValue];
			this_decade_number = this_year/10;
			if (this_decade_number > current_decade_number) {
				// if no index with this decade yet, add one with a new array with 
				// this starting decade year (eg. 1913 for first yankees year, 
				// otherwise 1920, 1930, etc..
				// Actually first add last one that we have built up.
				if (currentDecadeArray) {
					[_tableSectionData addObject:currentDecadeArray];
					currentDecadeArray = nil;
				}
				current_decade_number = this_decade_number;
			}
			if (!currentDecadeArray) currentDecadeArray = [[NSMutableArray alloc] init];
			[currentDecadeArray addObject:aTeam];
		}
		[_tableSectionData addObject:currentDecadeArray];
		// Scroll to row with requested team. (eg. if Anaheim Angels was selected, scroll to 1997).
		if (![[_tableSectionData[0][0] valueForKey:@"name"] isEqualToString:_teamName]) {
			NSInteger current_row, current_section;
			for (current_section=0; current_section<[_tableSectionData count]; current_section++) {
				for (current_row=0; current_row<[_tableSectionData[current_section] count]; current_row++) {
					if ([[_tableSectionData[current_section][current_row] valueForKey:@"name"] isEqualToString:_teamName]) {
						[self.tableView reloadData];
                        // I think it crashed here once. "*** Terminating app due to uncaught exception 'NSRangeException', reason: '-[UITableView _contentOffsetForScrollingToRowAtIndexPath:atScrollPosition:]: row (23) beyond bounds (20) for section (0).'" How can this happen? Can't reproduce. Maybe it's not really here. ***
						[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:current_row inSection:current_section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
						return;
					}
				}
			}
		}
    }
	} else {
		// More than one franchise for this name. 
		// ( franchiseNames is an array of dictionaries each with one key "franchID" and value string.)
		// Make table rows be year-year. Could also have the second line of the row be a list
		// of team names.
		// teamList is array of franchiseDicts.
		// Each franchiseDict has key=namesPlayedAs (string of names), key=teams (array of Teams objects), key=franchID.
		for (NSDictionary *aFranchiseNameDict in franchiseNames) {
			NSString *aFranchiseName = [aFranchiseNameDict valueForKey:@"franchID"];
			// Do a fetch to get all Teams objects for this franchise.
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
			[fetchRequest setEntity:entity];
            NSString *franchPredString = @"franchID == %@";
            BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([appDel excludeLatestYear]) franchPredString = [NSString stringWithFormat:@"%@ AND yearID<%d",franchPredString, LATEST_DATA_YEAR];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:franchPredString, aFranchiseName];
			[fetchRequest setPredicate:predicate];
			NSSortDescriptor *yearSort = [[NSSortDescriptor alloc] initWithKey:@"yearID" ascending:YES];
			[fetchRequest setSortDescriptors:@[yearSort]];
			NSError *error;
			NSArray *thisTeamList = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
			NSMutableDictionary *aFranchiseDict = [[NSMutableDictionary alloc] init];
			aFranchiseDict[@"franchID"] = aFranchiseName;
			aFranchiseDict[@"teams"] = thisTeamList;
			// Build list of team names in order.
			NSMutableString *teamNameList = [[NSMutableString alloc] init];
			NSString *currentTeam = nil;
			for (Teams *aTeam in thisTeamList) {
				if (!currentTeam) {
					currentTeam = aTeam.name;
					[teamNameList appendString:currentTeam];
					continue;
				}
				if (![currentTeam isEqualToString:aTeam.name]) {
					currentTeam = aTeam.name;
					[teamNameList appendString:@", "];
					[teamNameList appendString:currentTeam];
				}
			}
			aFranchiseDict[@"namesPlayedAs"] = teamNameList;
			[_teamList addObject:aFranchiseDict];
		}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
//http://stackoverflow.com/questions/18570907/should-i-fix-xcode-5-semantic-issue-undeclared-selector
		[_teamList sortUsingSelector:@selector(compareYearOfFirstTeam:)]; // Sort teamList by first team yearID.
#pragma clang diagnostic pop

	}
}

#pragma mark Handle year up/down buttons from RosterTVController

-(NSMutableArray *)cachedRosterControllers
{
    if (!_cachedRosterControllers)
        _cachedRosterControllers = [[NSMutableArray alloc] initWithCapacity:5]; // should do this in INIT actually.
    return _cachedRosterControllers;
}

-(void)pushRosterForTeam:(Teams *)thisTeam animated:(BOOL)animated
{
	// Implement roster caching: save last 5 rosters displayed. 
	// First, see if the year we need is already there.
	NSInteger cache_count = [self.cachedRosterControllers count];
	for (NSInteger i=0; i<cache_count; i++) {
		RosterViewController *thisCachedRoster = _cachedRosterControllers[i];
		if ([thisCachedRoster.team.yearID isEqualToNumber:thisTeam.yearID]) {
			// Hey, we already have it. Display it immediatamente!
			// But first remove from the list and add it on the end.
			[_cachedRosterControllers removeObjectAtIndex:i]; // Remove, which releases it.
			[_cachedRosterControllers addObject:thisCachedRoster]; // Add it back, which retains.
			 // Give up our ownership.
			[[self navigationController] pushViewController:thisCachedRoster animated:animated];
			return;
		}
	}
	// Our year's roster was not already cached. Need to create a new one.
	RosterViewController *rosterTV = [[RosterViewController alloc] initWithNibName:@"TeamViewController" bundle:nil];
	rosterTV.team = thisTeam;
	if ([_cachedRosterControllers count] == 5) {
		// There are already 5 of them. Delete the first (oldest), and add the new one to the end.
		[_cachedRosterControllers removeObjectAtIndex:0];
	}
	[_cachedRosterControllers addObject:rosterTV];
	[[self navigationController] pushViewController:rosterTV animated:animated];
}

-(void)pushRosterForYear:(NSInteger)this_year animated:(BOOL)animated
{
	// Look through yearList to find team because we don't have it.
	Teams *aTeam;
	NSInteger year_erator=0;
	do {
		aTeam = _teamList[year_erator];
		if ([aTeam.yearID integerValue]==this_year) {
			[self pushRosterForTeam:aTeam animated:animated];
			return;
		}
	} while (++year_erator < [_teamList count]);
}

//
// segmentAction - target for segmented control. 0 means up/previous, 1 means down/next.
//   This is for the up/down buttons on the RosterTVController.
//
- (void)segmentAction:(id)sender
{
	NSInteger new_year;
	
	UINavigationController *ourNavController = (UINavigationController *)[self parentViewController];
	NSArray *theViewControllers = ourNavController.viewControllers;
	RosterViewController *currentRosterController = [theViewControllers lastObject];
	new_year = [self yearFrom:[currentRosterController.team.yearID integerValue] plusOffset:[sender selectedSegmentIndex]];
	[ourNavController popViewControllerAnimated:NO]; // remove roster.
	[self pushRosterForYear:new_year animated:NO];
}

// return next or previous year in list from given current_year, or zero if
// none, ie. already at end or beginning.
-(NSInteger)yearFrom:(NSInteger)current_year plusOffset:(NSInteger)zero_or_one
{
	NSInteger new_year_index, current_year_index=0, year_erator=0;
	Teams *aTeam;
	do {
		aTeam = _teamList[year_erator];
		if ([aTeam.yearID integerValue]==current_year) {
			current_year_index = year_erator;
			break;
		}
	} while (++year_erator < [_teamList count]);
	if (year_erator==[_teamList count]) return 0; // shouldn't happen.
	if (zero_or_one == 0) {
		new_year_index = current_year_index - 1;
		if (new_year_index < 0) return 0; // at first year.
	}
	else {
		new_year_index = current_year_index + 1;
		if (new_year_index >= [_teamList count]) return 0; // at last year.
	}
	return [[_teamList[new_year_index] valueForKey:@"yearID"] integerValue];
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat row_height=44.0;
	if (number_of_franchises > 1) {
		row_height = 100.0;
	}
		return row_height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (number_of_franchises > 1 || [_tableSectionData count]==0)  return 1;

	return [_tableSectionData count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (number_of_franchises > 1 || [_tableSectionData count]==0) return nil;
	NSMutableArray *sectionIndexTitles = [[NSMutableArray alloc] init];
	for (NSArray *aDecadeArray in _tableSectionData) {
		[sectionIndexTitles addObject:[[aDecadeArray[0] valueForKey:@"yearID"] description]];
	}
	NSArray *sectionIndexTitlesToReturn = [NSArray arrayWithArray:sectionIndexTitles];
	if ([sectionIndexTitlesToReturn count] == 1) return nil; // Don't do indexing for only one index.
	return sectionIndexTitlesToReturn;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (number_of_franchises > 1 || [_tableSectionData count]==0) return [_teamList count];
	return [_tableSectionData[section] count];
}

// 
// cellForRowAtIndexPath - Display year (with league and W-L stats) or franchise years and team names played as.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TeamYearsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (number_of_franchises > 1) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		NSArray *teamListForFranchise = [_teamList[indexPath.row] valueForKey:@"teams"];
		NSInteger number_of_teams_in_franchise = [teamListForFranchise count];
		Teams *firstTeam = teamListForFranchise[0];
		Teams *lastTeam = teamListForFranchise[number_of_teams_in_franchise-1];
		if ([firstTeam.yearID compare:lastTeam.yearID]!=NSOrderedSame) {
			cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",firstTeam.yearID,lastTeam.yearID, [_teamList[indexPath.row] valueForKey:@"franchID"]];
		} else {
			cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",firstTeam.yearID, [_teamList[indexPath.row] valueForKey:@"franchID"]];
		}
		cell.detailTextLabel.text = [_teamList[indexPath.row] valueForKey:@"namesPlayedAs"];
	} else { // number_of_franchises==1
		cell.accessoryType = UITableViewCellAccessoryNone;
        Teams *ourTeam;
        if ([_tableSectionData count] > 0)
            ourTeam = _tableSectionData[indexPath.section][indexPath.row];
        else
            ourTeam = _teamList[indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[ourTeam.yearID description], ourTeam.name];
        NSString *myDivision = [StatHead divisionNameFromDivisionID:ourTeam.divID];
		NSString *finalInfo=@" ";
		if ([ourTeam.wSWin boolValue])
			finalInfo = @"World Series winner";
		else if ([ourTeam.lgWin boolValue])
			finalInfo = @"LCS winner";
		if ([ourTeam.wCWin boolValue]) {
			if (finalInfo) {
				finalInfo = [NSString stringWithFormat:@"%@ %@",finalInfo,@"WC"]; // cryptic but fits on the line.
			} else {
				finalInfo = @"Wild Card";	
			}
		}
        if ([finalInfo isEqualToString:@" "] && [ourTeam.divWin boolValue]) {
            finalInfo = @"Division Winner";
        }
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@-%@ %@",ourTeam.lgID,myDivision,ourTeam.w,ourTeam.l,finalInfo];
	}
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"franchiseToRoster"]) {
        if ([_tableSectionData count]>0)
            [[segue destinationViewController] setValue:_tableSectionData[indexPath.section][indexPath.row] forKey:@"team"];
        else
            [[segue destinationViewController] setValue:_teamList[indexPath.row] forKey:@"team"];
    } else if ([[segue identifier] isEqualToString:@"multipleFranchises"]) {
        [[segue destinationViewController] setValue:[_teamList[indexPath.row] valueForKey:@"franchID"] forKey:@"franchise"];
    }
    // Provide MOC to either destination VC.
    [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL whether_to_perform = YES;
    // There is a conditional segue here, ie. row selected produces the "franchiseToRoster" segue but if there is more than one franchise we should switch to the other segue, "multipleFranchises" and do the recursive segue.
    if ([identifier isEqualToString:@"franchiseToRoster"] && number_of_franchises>1) {
        whether_to_perform = NO;
        // Instead, do the other segue (the recursive one).
        [self performSegueWithIdentifier:@"multipleFranchises" sender:self];
    }
    return whether_to_perform;
}

@end

@implementation NSDictionary (sortCategory)

-(NSComparisonResult)compareYearOfFirstTeam:(NSArray *)team2
{
	NSNumber *selfYear = [[self valueForKey:@"teams"][0] valueForKey:@"yearID"];
	NSNumber *team2Year = [[team2 valueForKey:@"teams"][0] valueForKey:@"yearID"];
	return [team2Year compare:selfYear];
}

@end

