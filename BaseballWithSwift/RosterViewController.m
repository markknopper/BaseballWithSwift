//
//  RosterViewController
//  BaseballQuery
//
//  Created by Matthew Jones on 5/9/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//

/* RosterViewController displays the team roster. */

#import "TeamTabBarController.h"
#import "RosterViewController.h"
#import "StatsViewController.h"
#import "PlayerTabBarController.h"
#import "NSArray+BV.h"
#import "Batting+Query.h"
#import "Master+Query.h"
#import "Managers+Query.h"
#import "Teams+Query.h"
#import "FirstLastBoldCell.h"
#import "UIViewController+IndexLetters.h"
#import "BQPlayer.h"

@implementation RosterViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"giveMeTeamStats"]) {
        [[segue destinationViewController] setValue:_team forKey:@"team"];
        [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
        [[segue destinationViewController] setValue:_team.name forKey:@"title"];
    } else if ([[segue identifier] isEqualToString:@"rosterToPlayer"]) {
        //
        //  Because the indexLetters have rearranged the roster into sections based on first letter
        //  of last name, we tap into the indexLetters function to get to the correct player.
        //
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BQPlayer *player = (BQPlayer *)[self indexLettersObjectForIndexPath:indexPath];
        player.year = _team.yearID; // Send this all the way to StatsViewController to display year.
        [[segue destinationViewController] setValue:player forKey:@"player"];
        [[segue destinationViewController] setValue:_team forKey:@"team"];
        [[segue destinationViewController] setValue:player.year forKey:@"year"];
    } else if ([[segue identifier] isEqualToString:@"rosterToYear"]) {
        [[segue destinationViewController] setValue:_team.yearID forKey:@"year"];
        [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.roster = [_team rosterInNameOrder];
    [self computeTableIndicesFromArrayUpdatingDisplayList:_roster withKeyPath:@"nameLast"];
    UIButton *titleButt = (UIButton *)(self.navigationItem).titleView;
    [titleButt setTitle:[_team.yearID description] forState:UIControlStateNormal];
    // Probably should learn how to do modern dynamic sizing from WWDC 2014.
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Special view above table for team name. Just for context.
	self.teamNameLabel.text = self.team.name;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([_displayList count]==0) {
		return 1;
	}	
    return [_displayList count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return _indexLetters;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *initialLetter = _indexLetters[section];
	return [_displayList[initialLetter] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [_indexLetters indexOfObject:title];
}

//
// positionForPlayerID - given playerID on this team/season, return position to display for roster table.
//   This is hopefully faster than the previous [BQPlayer displayPosition] which started from Master rather than this Team.
//
-(NSString *)positionForPlayerID:(NSString *)playerID
{
    NSString *positionToReturn;
    // Return Manager if we ever managed this year.
    for (NSManagedObject *aManager in _team.managers) {
        if ([[aManager valueForKey:@"playerID"] isEqualToString:playerID]) {
            return @"Mgr";
        }
    }
    NSArray *fieldingThisPlayerThisYear = [[_team.fielders allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerID == %@",playerID]];
    if ([fieldingThisPlayerThisYear count] == 0) return nil; // Didn't field this year.
    NSSortDescriptor *decreasingG = [[NSSortDescriptor alloc] initWithKey:@"g" ascending:NO];
    NSArray *sortedFieldingByGames = [fieldingThisPlayerThisYear sortedArrayUsingDescriptors:@[decreasingG]];
    positionToReturn = [sortedFieldingByGames[0] valueForKey:@"pos"];
    if ([positionToReturn isEqualToString:@"OF"]) {
        // Special case for stupid "OF". Try to return the specific outfield position with most games.
        NSInteger i=0;
        NSArray *outfieldPositions = @[@"LF",@"CF",@"RF"];
        while (++i < [sortedFieldingByGames count]) {
            NSString *aPositionPlayedThisYear = [sortedFieldingByGames[i] valueForKey:@"pos"];
            if ([outfieldPositions containsObject:aPositionPlayedThisYear]) {
                positionToReturn = aPositionPlayedThisYear;
                break;
            }
        }
    }
    if ([positionToReturn isEqualToString:@"P"]) {
        // Get sum of all pitching wins and losses in all stints this year.
        NSSet *pitchingRecordsThisPlayerThisYear = [_team.pitchers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"playerID == %@",playerID]];
        NSInteger wins = [[pitchingRecordsThisPlayerThisYear valueForKeyPath:@"@sum.w"] intValue];
		NSInteger losses = [[pitchingRecordsThisPlayerThisYear valueForKeyPath:@"@sum.l"] intValue];
		positionToReturn = [NSString stringWithFormat:@"P %ld-%ld", (long)wins, (long)losses];
    }
    return positionToReturn;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RosterCell";
	FirstLastBoldCell *cell = (FirstLastBoldCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	BQPlayer *rosterEntry = (BQPlayer *)[self indexLettersObjectForIndexPath:indexPath];
    cell.firstNameLabel.text = rosterEntry.nameFirst;
    cell.lastNameLabel.text = rosterEntry.nameLast;
    cell.positionLabel.text = [self positionForPlayerID:rosterEntry.master.playerID];
    return cell;
}

@end

