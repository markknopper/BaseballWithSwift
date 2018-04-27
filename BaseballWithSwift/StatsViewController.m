//
//  StatsViewController.m
//  BaseballWithSwift
//
//  Created by Matthew Jones on 5/9/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
// Tableviewcontroller used to display most stuff, like batting/pitching/fielding/managing for both player and team.
// New for 2017: post_season_info for batting/pitching/fielding. We are responsible for
// adding a segmented controller at the top for Regular/Postseason, supplying a separate StatsSource record,
// and managing the setting of the controller. Actually that is all done by PlayerTBC and StatsDisplayFactory.

#import "StatsViewController.h"
#import "PlayerRankTabBarController.h"
#import "TeamRankTabBarController.h"
#import "StatsDisplay.h"
#import "StatDescriptor.h"
#import "Master+Query.h"
#import "Teams+Query.h"
#import "RosterViewController.h"
#import "AllStarTVC.h"
#import "StatHead.h"
#import "Batting+Query.h"
#import "FieldingTotals+Query.h"
#import <Social/Social.h>
#import "BaseballWithSwift-Swift.h"

@implementation StatsViewController

/* Let's try a completely different approach. 6-2014
 Previously the first time displayAtIndex was called, we did
 createStatsDisplayWithType which created all the StatsDescriptors
 for the section, and left the getting of the actual stat value until
 the cellForRowAtIndexPath. There seems to be a lot of confusion
 figuring out the stat display, descriptor, sources etc stuff and debugging
 it all the time. Would be a lot better to just get the stats once.
 Now: let's just read the StatsDisplayFactory tables but don't store them,
 and instead use it as a map to get the actual stats into the display array.
 So we will have the array displaySections - one array for each section,
 each entry being an array of statDisplay objects, which have a StatDescriptor for each row generaly with final labels and values. */

- (void)viewDidLoad
{
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
    [super viewDidLoad];
}

// setStatsSources - first opportunity to populate the display text for all sections and rows of the table.
// Set up statsSources and also displaySections.
-(void)setStatsSources:(NSArray *)statsSources
{
    // Stat source type comes from tag in tab item from storyboard. Unless we are calling it from the new postseason tab in which case it is already known.
    if (_statsDisplayStatType == 0)
        _statsDisplayStatType = (int)self.tabBarItem.tag-1024; // set in storyboard.
    // Count of statsSources is number of sections for our table. Secret: one section usually except fielding is one per position played that year or career.
    self.displaySections = [NSMutableArray new];
    for (id aStatsource in statsSources) {
        StatsDisplay *statsDisplay = [StatsDisplayFactory createStatsDisplayWithType:_statsDisplayStatType player:_player];
        /* We have to do it this way. Populate all the statsDescriptors
         with real data, then prune to remove the statDescriptors that
         have missing/bogus data. Can't do it in cellForRow because that's too late to prune rows. */
        NSMutableArray *descriptorsToPrune = [NSMutableArray array];
        for (StatDescriptor *aStatDescriptor in statsDisplay.statDescriptors) {
            // This statdescriptor and the statsource gives us everything we need to generate the exact display for a row.
            if (aStatDescriptor.key) { // if no key, don't look for value.
                // E.g. personal stats have literal strings.
                    // career fielding is now an per-position array of fielding record arrays. So this source is just an
                    // array of fielding records for the same position.
                    // Probably need to sum for this stat.
                    // Use category for fielding position array.
                    // Even if this is an array, it will work.
                    // Career fielding stats use an array of fielding
                    // records as the stat source, as you know.
                    // NSArray+BV has a displayStringForStat.
                aStatDescriptor.value = [aStatsource displayStringForStat:aStatDescriptor.key];
            }
            // Any extra computing for this stat should have all been computed in displayStringForStat.
            
            // This is the pruning section. Used to be a separate
            // complicated method "pruneStatsMissingFromObject".
            // If there is something wrong with this stat, add to
            // descriptorsToPrune list.
            if ([aStatDescriptor.label isEqualToString:@" "] || [aStatDescriptor.value isEqualToString:@"-1"])
                [descriptorsToPrune addObject:aStatDescriptor];
            else {
                SEL error_check_method = aStatDescriptor.isStatMissing;
                if (error_check_method) {
                    // "performSelector may cause a leak because its selector is unknown". To you, maybe.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    // *** Don't think anything has this type of method right now. Never gets here.
                    // *** Could use it for Managers inseason (if it is 1 check the team roster to see if there are other managers this year. Don't display inseason if this is only manager. However the roster call and scan would take some time.). Also Player Manager shouldn't be displayed if false.
                    if (![[self performSelector:error_check_method withObject:aStatsource] boolValue])
                        [descriptorsToPrune addObject:aStatDescriptor];
#pragma clang diagnostic pop
                }
            }
        }
        [statsDisplay.statDescriptors removeObjectsInArray:descriptorsToPrune]; // This is changing an object that we have already added to an array (displaySections). Is that ok or should we move the addObject down here? Seems to work though. Maybe it never really has anything to prune. Need to test. There are definitely -1s in BattingPost I think. ***
        [_displaySections addObject:statsDisplay];
    }
    _statsSources = statsSources; // setter
}

#pragma mark -
#pragma mark Table view data source

// Title is a bit aesthetically determined, and changable by the members from time to time.
// For postseason, we have the batting etc. tab showing at the bottom, and the series name showing as one of the top rows, and the word Postseason in the tab, so all we need is the year and player name.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if ((_statsDisplayStatType & StatsDisplayStatScopeMask)== StatsDisplayStatScopeTeam) {
        // Use "league division" as section header for team stats.
        NSString *divisionName = [StatHead divisionNameFromDivisionID:[_statsSources[0] valueForKey:@"divID"]];
        if (!divisionName) divisionName = @" ";
        title = [NSString stringWithFormat:@"%@ %@ - %@",[StatHead leagueNameFromLeagueID:[_statsSources[0] valueForKey:@"lgID"]],divisionName,[_statsSources[0] valueForKey:@"yearID"]];
    } else
        title = [StatHead statNameForStatsDisplayStatType:_statsDisplayStatType];
	// If we can find player name, set title to "Batting - Babe Ruth".
	NSNumber *ourYear = nil;
	if (_player) {
		title = [NSString stringWithFormat:@"%@ - %@",title,_player.fullName];
		ourYear = _player.year;
	}
	// Add on the year if not Career and if not Personal.
    if (((_statsDisplayStatType & StatsDisplayStatScopeMask)!=StatsDisplayStatScopeCareer) &&
        ((_statsDisplayStatType & StatsDisplayStatTypeMask) != StatsDisplayStatTypePersonal)) {
		if (ourYear != nil) {
			title = [NSString stringWithFormat:@"%@ - %@",title,ourYear];
		}
	}
	return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_statsSources count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= [_displaySections count]) return 0; // stops a crash with changeToPlayer, only on device not simulator.
    // *** consider getting rid of changeToPlayer and just use segue etc.
    return [[_displaySections[section] valueForKey:@"statDescriptors"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // "Tag" of tableview in storyboard is the suffix for unique reuse identifier, since we have multiple
    // instances of StatsViewController in the storyboard and reuse identifiers must be unique.
    NSString *cellIdentifier = [NSString stringWithFormat:@"StatsViewCell%ld",(long)[self.tableView tag]];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    StatsDisplay *disp = _displaySections[indexPath.section];
    StatDescriptor *statDescriptor = disp.statDescriptors[indexPath.row];
    // We should have the label as label and value as value. Too late
    // to get any new values or prune any bad ones.
    cell.detailTextLabel.text = @""; // default
    /* This should be in setStatSources */
    if (!statDescriptor.label) {
        // No label. See if there is a key to use as a keypath.
        // E.g. "aTeamSeason.name"
        statDescriptor.label = [_statsSources[indexPath.section] valueForKeyPath:[(NSString *)(statDescriptor.key) description]];
    }
    if (statDescriptor.label) {
        cell.textLabel.text = statDescriptor.label; // Label is given.
    }
    // Either have value already, or get it.
    if (!statDescriptor.value) {
        if (statDescriptor.key)
        { // If no key, don't bother with value.
            // Get it from the source in the normal way.
            statDescriptor.value = [_statsSources[indexPath.section] displayStringForStat:statDescriptor.key];
        }
    }
    cell.detailTextLabel.text = statDescriptor.value; // could be null.
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

//
// Handle row taps as storyboard segues when possible, but if they are conditional we may have to
// perform the segues here in code.
// The reason we have both didSelectRowAtIndexPath and prepareForSegue is that we don't have a segue from a cell. We just have a segue from the controller, which is only triggered below by performSegue explicitly. In that case it will go to prepareForSegue. So no conflict or ambiguity or race condition.
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StatsDisplay *disp = _displaySections[indexPath.section];
    if ((disp.type & StatsDisplayStatScopeMask) == StatsDisplayStatScopeTeam) return;
    StatDescriptor *statDescriptor = disp.statDescriptors[indexPath.row];
    // This should go in the statDescriptor!
    if ([statDescriptor.key isEqualToString:@"pitcherKind"]) return;
    NSString *segueName = statDescriptor.segueName;
    if (segueName) { // eg.personalToAllStar
        [self performSegueWithIdentifier:segueName sender:self];
    } else if ((disp.type & StatsDisplayStatTypeMask)!=StatsDisplayStatTypePersonal && (disp.type & StatsDisplayStatScopeMask)!=StatsDisplayStatScopePost) {
        // It's not personal. (No click-through on personal yet.)
        // If we are career, use the regular player rank "in history" TVC.
        // Also don't rank on Post stats yet.
        if ((disp.type & StatsDisplayStatScopeMask)==StatsDisplayStatScopeCareer) {
            if ([self shouldPerformSegueWithIdentifier:@"statToCareerRank" sender:self])
                [self performSegueWithIdentifier:@"statToCareerRank" sender:self];
        }
        else {
            if ([self shouldPerformSegueWithIdentifier:@"statToPlayerRank" sender:self])
                [self performSegueWithIdentifier:@"statToPlayerRank" sender:self];
        }
    }
    // Otherwise it falls through with no action. Eg. Park in Team Stats.
    // Note team name cell has its own segue to team stats TBC.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = [segue identifier];
    UIViewController *destinationViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    id statsSource = _statsSources[indexPath.section];
    StatsDisplay *statsDisplay = _displaySections[indexPath.section];
    StatDescriptor *statsDescriptor = statsDisplay.statDescriptors[indexPath.row];
    if ([segueIdentifier isEqualToString:@"personalToAllStar"]) {
        [destinationViewController setValue:@([statsDescriptor.label integerValue]) forKey:@"year"];
    } else if ([segueIdentifier isEqualToString:@"teamInfoToTeamRank"]) {
        [destinationViewController setValue:_statsSources[indexPath.section] forKey:@"toSelect"];
        [destinationViewController setValue:[_statsSources[indexPath.section] valueForKeyPath:@"yearID"] forKey:@"yearID"];
        [destinationViewController setValue:_displaySections[indexPath.section] forKeyPath:@"statsDisplay"];
        [destinationViewController setValue:@(indexPath.row) forKey:@"descriptorIndex"];
        [destinationViewController setValue:statsDescriptor.label forKey:@"title"];
    } else if ([segueIdentifier isEqualToString:@"statToPlayerRank"]) {
        [destinationViewController setValue:[statsSource valueForKeyPath:@"aTeamSeason.yearID"] forKey:@"yearID"];
        [destinationViewController setValue:statsSource forKey:@"toSelect"];
        [destinationViewController setValue:_displaySections[indexPath.section] forKey:@"statsDisplay"];
        [destinationViewController setValue:@(indexPath.row) forKey:@"descriptorIndex"];
    } else if ([[segueIdentifier substringFromIndex:[segueIdentifier length] - 10] isEqualToString:@"TeamRoster"]) {
        // For @aTeamSeason.name in personal BPFM entries.
        //Teams *ourTeam = [statsSource valueForKey:@"teamSeason"];
        //+(Teams *)teamWithTeamID:(NSString *)teamID andYear:(NSNumber *)yearID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
        Teams *ourTeam = [Teams teamWithTeamID:[statsSource valueForKey:@"teamID"] andYear:[statsSource valueForKey:@"yearID"] inManagedObjectContext:[statsSource valueForKey:@"managedObjectContext"]];
        [destinationViewController setValue:ourTeam forKey:@"team"];
    } else if ([segueIdentifier isEqualToString:@"statToCareerRank"]) {
        if ((statsDisplay.type & StatsDisplayStatTypeMask)==StatsDisplayStatTypeFielding) {
            // Now we are all about career fielding totals for this position,
            // for this stat. There is exactly one FieldingTotals record
            // hanging off Master with this info. Should find this and pass it
            // along!
            // First get position.
            for (StatDescriptor *anSD in statsDisplay.statDescriptors) {
                if ([anSD.key isEqualToString:@"pos"]) {
                    NSString *positionName = anSD.value;
                    [destinationViewController setValue:[[_player.master.fieldingTotals filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"pos == %@",positionName]] anyObject] forKey:@"toSelect"];
                    break;
                }
            }
        } else
            [destinationViewController setValue:statsSource forKey:@"toSelect"];
        [destinationViewController setValue:_displaySections[indexPath.section] forKey:@"statsDisplay"];
        [destinationViewController setValue:@(indexPath.row) forKey:@"descriptorIndex"];
        [destinationViewController setValue:statsDescriptor.label forKey:@"title"];
    } else if ([segueIdentifier isEqualToString:@"postPlayerToSeries"]) {
        // Go to postseason series view for year and scroll to this series round.
        [destinationViewController setValue:_player.year forKey:@"year"];
        [destinationViewController setValue:statsDescriptor.value forKey:@"scrollToRound"];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSUInteger orientations_to_return = UIInterfaceOrientationMaskAllButUpsideDown;
    if (self.tabBarController)
        orientations_to_return = [self.tabBarController supportedInterfaceOrientations];
    return orientations_to_return;
}

@end

