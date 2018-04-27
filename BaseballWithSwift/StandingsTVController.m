//
//  StandingsTVController.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/7/09.
//  Copyright 2009-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "StandingsTVController.h"
#import "Teams.h"
#import "RosterViewController.h"
#import "StatHead.h"
#import "AllYears.h"

@implementation StandingsTVController

-(void)viewDidLoad
{
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
    [super viewDidLoad];
}

//
// prepareStandingsData - The goal of this is to display each division in a separate section,
//		with teams in each division ordered by rank. 
//
-(void)prepareStandingsData
{
	NSEntityDescription *teamEntity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"yearID==%@",_year];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:teamEntity];
	[fetchRequest setPredicate:predicate];
	NSError *error=nil;
	NSArray *teamListForYearArray = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    // These are released in -dealloc.
	self.leaguesThisYear = [[NSMutableArray alloc] initWithCapacity:2];
	self.divisionsThisYear = [[NSMutableArray alloc] initWithCapacity:6];
	for (Teams *aTeam in teamListForYearArray) {
		// add team to appropriate division and appropriate league.
		NSMutableDictionary *aDivisionDict, *aLeagueDict;
		// Create array leaguesThisYear with dictionaries for each league. Each dictionary
		// has a leagueName string and a teamsForLeague array. The teamsForLeague array
		// consists of Team objects.
		NSEnumerator *enumerator = [_leaguesThisYear objectEnumerator];
		while (TRUE) {
			aLeagueDict = [enumerator nextObject];
			if (!aLeagueDict) { // need to add this league.
				aLeagueDict = [[NSMutableDictionary alloc] init]; // create new league
				aLeagueDict[@"leagueName"] = aTeam.lgID; // set league name
				NSMutableArray *teamsForLeague = [[NSMutableArray alloc] init]; // put array in league for teams
				[teamsForLeague addObject:aTeam]; // add first item to array.
				aLeagueDict[@"teams"] = teamsForLeague; // put array in new league object
				[_leaguesThisYear addObject:aLeagueDict]; // add first league to league list.
				break;
			}
			if ([aLeagueDict[@"leagueName"] isEqualToString:aTeam.lgID]) {
				// league already in league list. Add team to it.
				NSMutableArray *teamsForLeague = aLeagueDict[@"teams"];
				[teamsForLeague addObject:aTeam];
				break;
			}
		}
		// divisionsThisYear: array of division dictionaries, each with keys for division name, league name, and rank-ordered list of teams in that division.
		if (aTeam.divID) {
			enumerator = [_divisionsThisYear objectEnumerator];
			while (TRUE) {
				aDivisionDict = [enumerator nextObject];
				if (!aDivisionDict) { // need to add this div.
					aDivisionDict = [[NSMutableDictionary alloc] init];
					aDivisionDict[@"divisionName"] = aTeam.divID;
					aDivisionDict[@"leagueName"] = aTeam.lgID;
					NSMutableArray *teamsForDivision = [[NSMutableArray alloc] init];
					[teamsForDivision addObject:aTeam]; // add first item to array.
					aDivisionDict[@"teams"] = teamsForDivision;
					[_divisionsThisYear addObject:aDivisionDict];
					break;
				}
				if ([aDivisionDict[@"divisionName"] isEqualToString:aTeam.divID] && [aDivisionDict[@"leagueName"] isEqualToString:aTeam.lgID]) {
					NSMutableArray *teamsForDivision = aDivisionDict[@"teams"];
					[teamsForDivision addObject:aTeam];
					break;
				}		
			}
		}
	}
	// OK we now have divisionsThisYear and leaguesThisYear set up. Sort league/divisions
	// for section order. But first sort within each division or league by number of wins.
	NSSortDescriptor *leagueSort = [[NSSortDescriptor alloc] initWithKey:@"leagueName" ascending:YES];
	NSSortDescriptor *winsSort = [[NSSortDescriptor alloc] initWithKey:@"w" ascending:NO];
	NSSortDescriptor *lossesSort = [[NSSortDescriptor alloc] initWithKey:@"l" ascending:YES];
	if ([_divisionsThisYear count]==0) { // if before divisions were invented,
		for (NSDictionary *aLeagueDict in _leaguesThisYear) {
			[aLeagueDict[@"teams"] sortUsingDescriptors:@[winsSort,lossesSort]];
		}
		// Sort by league name.
		[_leaguesThisYear sortUsingDescriptors:@[leagueSort]];
		self.sectionsForDisplay = _leaguesThisYear;
	} else {
		for (NSDictionary *aDivisionDict in _divisionsThisYear) {
			[aDivisionDict[@"teams"] sortUsingDescriptors:@[winsSort,lossesSort]];
		}
		// Sort by league then division name.
		NSSortDescriptor *divisionSort = [[NSSortDescriptor alloc] initWithKey:@"divisionName" ascending:YES];
		[_divisionsThisYear sortUsingDescriptors:@[leagueSort,divisionSort]];
		self.sectionsForDisplay = _divisionsThisYear;
	}
    [self.tableView reloadData];
}

-(void)setYear:(NSNumber *)year
{
    if (year != _year) {
        _year = year;
        if (!_sectionsForDisplay) { // Just do this the first time.
            [self prepareStandingsData];
        }
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sectionsForDisplay count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sectionsForDisplay[section][@"teams"] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StandingsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	Teams *aTeam = _sectionsForDisplay[indexPath.section][@"teams"][indexPath.row];
    cell.textLabel.text = aTeam.name;
	NSString *finalInfo=nil;
	if ([aTeam.wSWin boolValue])
		finalInfo = @"World Series winner";
	else if ([aTeam.lgWin boolValue])
		finalInfo = @"League Pennant winner";
	if ([aTeam.wCWin boolValue]) {
		if (finalInfo) {
			finalInfo = [NSString stringWithFormat:@"%@, %@",finalInfo,@"Wild Card"];
		} else {
			finalInfo = @"Wild Card";	
		}
	}
	if (!finalInfo) finalInfo = @" ";
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@ %@",aTeam.w,aTeam.l,finalInfo];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionName;
	
	if ([_divisionsThisYear count]==0) { // if before divisions were invented,
		sectionName = [StatHead leagueNameFromLeagueID:_sectionsForDisplay[section][@"leagueName"]];
	} else {
		NSString *myDivision = _sectionsForDisplay[section][@"divisionName"];
		if ([myDivision isEqualToString:@"W"]) myDivision = @"West";
		else if ([myDivision isEqualToString:@"E"]) myDivision = @"East";
		else if ([myDivision isEqualToString:@"C"]) myDivision = @"Central";
		sectionName = [NSString stringWithFormat:@"%@ %@",[StatHead leagueNameFromLeagueID:_sectionsForDisplay[section][@"leagueName"]],myDivision];
	}
	NSString *sectionNameWithYearPrefix = [NSString stringWithFormat:@"%@ - %@",self.year,sectionName];
	return sectionNameWithYearPrefix;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"standingsToRoster"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Teams *aTeam = _sectionsForDisplay[indexPath.section][@"teams"][indexPath.row];
		aTeam.yearID = _year;
        [[segue destinationViewController] setValue:aTeam forKey:@"team"];
        [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
    }
}

@end

