//
//  TeamRankInYearViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/17/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

//  This is a base class for the ranking of teams, although with some effort could probably
//  be generalized for the ranking of players as well.   (major departure is the drill-through
//  and subsequent changes to the nav stack when a ranked item is selected)  This class has
//  default implementations of the methods typically overridden by the derived classes, so
//  it has the default behavior to rank the team against all of the other teams in the same
//  year.
//
//  The query to determine the roster is specified by the derived class when it overrides the predicate
//  method teamSeasonSelectionPredicateWithSource.      The method extracts the relevant values from
//  the statSource and extracts the roster of Teams appropriate for the ranking.
//
//  The string to be displayed in the tableViewCell (team name, franchise name, year, etc...) is
//  specified by the derived class in the overriden method textLabelTextForRankingObject. NOT***
//

#import "TeamRankTableViewController.h"
#import "Teams+Query.h"
#import "NSArray+BV.h"
#import "UINavigationController+BV.h"
#import "StatDescriptor.h"
#import "TeamTabBarController.h"

@implementation TeamRankTableViewController

#pragma mark -
#pragma mark Initialization

//  Set up the ranking view controller with a stat source (likely a Teams *), and a display
//  template to use for the ranking display.     Also, the descriptor index describes the specific
//  stat in the template for which the ranking is to be done.
//
//  Cache the display key (the key to send to the source to get the proper stat value displayed),
//  and initially set the roster to nil.
//
//  When it is time for the view to appear, the appropriate elements will be used to populate the
//  roster.  (all the teams in a year, all of the teams for a franchise, etc...).
//
//  If a particular stat has qualifying characteristics, show the toggle button that permits
//  the user to toggle qualification on/off.
//
//
//   This predicate selects the team seasons to consider for ranking
//   Expand the list of teams to expand the scope of the ranking
//
- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)teamToSelect {
    return [NSPredicate predicateWithFormat:@"yearID == %d", [[teamToSelect valueForKey:@"yearID"] intValue]];
}

- (void)viewDidLoad {
    NSManagedObjectContext *managedObjectContext = [_toSelect valueForKey:@"managedObjectContext"];
    NSFetchRequest *getAllTeamsForYear = [[NSFetchRequest alloc] init];
    [getAllTeamsForYear setEntity:[NSEntityDescription entityForName:@"Teams" inManagedObjectContext:managedObjectContext]];
    [getAllTeamsForYear setPredicate:[self teamSeasonSelectionPredicateWithSource:_toSelect]];
    // In an interesting turn of events, the new category attributes are not available in the context of
    // of the executeFetchRequest.   If I have @"battingAverage" in the statKey, the fetch will fail
    // if it is inserted as a sort descriptor. However, everything seems to work fine if we fetch
    // all of the teams and then do the sort post-fetch using the Teams+Query attributes.
    // strange.     The questions remains.    Should it work?    Maybe not because the category extension is
    // to the Teams class, and fetch appears to work on NSSQLEntity Teams, so may miss it somehow...
    //
    NSError *fetchError = nil;
    // only  want a single team, just take any to unnest the array
    NSArray *unsortedTeams = [managedObjectContext executeFetchRequest:getAllTeamsForYear error:&fetchError];
    StatDescriptor *statDescriptor = [_statsDisplay.statDescriptors objectAtIndex:[_descriptorIndex integerValue]];
    self.roster = [unsortedTeams sortedArrayUsingKey:statDescriptor.key ascending:statDescriptor.ascending];
    self.toSelectIndex = [self.roster indexOfObject:self.toSelect];
    _tableView.rowHeight = 44;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    //
    //  Find the player in the list and select the row the player is on.
    //  If player is in the top 20, then hilight in the top 20
    //
    NSInteger sectionToSelect = 0;
    NSInteger rowToSelect = 0;
    //
    //  If player is in the top 20, select the row the player is on in the
    //  top 20 list.   We won't have a section 1 in that case.
    //
    if (self.showRankingInUnifiedList || (self.toSelectIndex < 20)) {
        sectionToSelect = 0;
        rowToSelect = self.toSelectIndex;
    } else {
        sectionToSelect = 1;
        //                       20 to 22                RC-4 to RC-1              everything else
        rowToSelect = MIN(self.toSelectIndex-20, MIN(4-([_roster count]-_toSelectIndex),3));
    }
    if ([_roster count] > 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect inSection:sectionToSelect] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //
    // Return the number of sections.
    // If the selected player is in the top 20, we'll just have 1 section
    //
    /*
    NSInteger number_of_sections_to_return = 0;
    if (self.showRankingInUnifiedList || (self.toSelectIndex < 20)) {
        number_of_sections_to_return = 1;
    } else {
        number_of_sections_to_return = 2;
    }
    */
    NSInteger number_of_sections_to_return = (self.showRankingInUnifiedList || (self.toSelectIndex < 20)) ? 1 : 2;
    return number_of_sections_to_return;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //
    // Return the number of rows in the section.
    //
    NSInteger numberOfRows = 0;
    
    if (self.showRankingInUnifiedList) {
        numberOfRows = [_roster count];
    } else if (section == 0) {
        numberOfRows = MIN([_roster count], 20);
    } else {
        //
        //  If our item is near or at the end, we may not have the full 7 in the truncated section
        //  But there will always be at least 4 (1+3).  Maybe just nothing after or nothing before.
        //  If for some reason the roster is empty, the min needs to be 0
        //  Also, ranking could be 20th-22nd, which means there are only 4-6 items in section 1
        //
        if ([_roster count] != 0) {
            numberOfRows = MIN(self.toSelectIndex-20+4,MIN([_roster count]-self.toSelectIndex+3,7));
        }
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ Rankings for %d",[[_statsDisplay.statDescriptors objectAtIndex:[_descriptorIndex integerValue]] valueForKey:@"label"],[[_toSelect valueForKey:@"yearID"] intValue]];
}

-(NSString *)cellIdentifier
{
    return @"TeamRankCell"; // Subclasses override this.
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
    //
    //  for showAll mode, there would be no section==1 so this all works
    //  fine without having to check for showAll.   Revisit this if something
    //  changes.  Say, for example if showAll does something with multiple sections.
    //
    NSInteger rosterRow = indexPath.row; // works fine for top 20, and showAll
    if (indexPath.section == 1) {
        rosterRow += self.toSelectIndex-MIN(self.toSelectIndex-20,3);      // for the truncated second section 0 element is 3 before the selected one
    }
    Teams *team = _roster[rosterRow];
    UILabel *rankLabel = (UILabel *)[cell viewWithTag:42]; // Tag of zero can't be used.
    rankLabel.text = [NSString stringWithFormat:@"%ld",(long)rosterRow+1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = team.name;
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
    StatDescriptor *statDescriptor = [_statsDisplay.statDescriptors objectAtIndex:[_descriptorIndex integerValue]];
    valueLabel.text = [team displayStringForStat:statDescriptor.key];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:3];
    yearLabel.text = [team.yearID description];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    //   Get access to the top of the nav stack, as we might back up to a different player.
    //   TODO make this work in other contexts (for example from the Comparison)
    //
    // Is this too late to deselect? ***
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    UIViewController *backViewController = [self.navigationController backViewController];
    if ([backViewController isKindOfClass:[TeamTabBarController class]]) {
        TeamTabBarController *ttbc = (TeamTabBarController *)backViewController;
        //
        //   There are two possibilities.   Either the user has selected the "drill down" parent Team,
        //   in which case, we can just pop to the parent, or else the user has selected a different
        //   team.  If a different team, then we can manipulate the parent to set the new team, and
        //   then pop to the modified parent view controller to show the new team.
        //
        NSInteger rosterRow = indexPath.row; // works fine for top 20, and showAll
        if (indexPath.section == 1) {
            rosterRow += self.toSelectIndex-MIN(self.toSelectIndex-20,3); // for the truncated second section 0 element is 3 before the selected one
        }
        Teams *team = _roster[rosterRow];
        if (team != _toSelect) {
            [ttbc changeToTeam:team];
        }	
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

