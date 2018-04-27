//
//  PlayerRankTableViewController.m
//  BaseballWithSwift
//
//  Created by Matthew Jones on 5/17/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
#pragma mark PlayerRankTableViewController

#import "PlayerRankTableViewController.h"
#import "PlayerTabBarController.h"
#import "Master+Query.h"
#import "Batting+Query.h"
#import "BQPlayer.h"
#import "UINavigationController+BV.h"
#import "StatDescriptor.h"
#import "Teams+Query.h"
#import "NSArray+BV.h"
#import "BaseballQueryAppDelegate.h"
#import "PlayerRankOperation.h"
#import "Fielding+Query.h"
#import "StatHead.h"

@implementation PlayerRankTableViewController
// MARK: Subclasses will overide the following functions
//
//   Derived classes will overide the following functions.
//
//   This predicate selects the team seasons to consider for ranking
//   Expand the list of teams to expand the scope of the ranking
//

-(void)viewDidLoad
{
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
    [super viewDidLoad];
}

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)toSelect {
    return nil;
}

//
//  textLabelTextForRankingObject - Called from team ranking view.
//   This method returns a string label to display in the ranking list
//   Add additional information to the textLabel in the cell (if Teams
//   are multi-year, for example, you could add the year in the textLabel
//   to make things clear)
//
#pragma mark -
// MARK: test
// ???: test
// !!!: test
#pragma mark test
// TODO: test
#pragma mark - with hyphen
#pragma mark without hyphen

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidDisappear:(BOOL)animated
{
    [_fetchOpQueue cancelAllOperations];
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_fetchOpQueue cancelAllOperations]; // Might be overkill but can't hoit.
    [super viewWillDisappear:animated];
}

// We could be here for one of several tab situations.
// Examples: Take Edwin Jackson on 2010 Ari, click on wins.
// 0) Team tab. Fetch all pitchers on team to rank this pitcher in Wins category.
// 1) Season tab. Fetch all pitchers on all teams this season to rank this pitcher in Wins category.
// 2) Franchise tab. Fetch all pitchers in all teams in franchise to rank this pitcher in Wins category.
// 3) All-time tab. Fetch all 90,000 pitchers. Rank this pitcher in Wins category.

-(void)doCustomSetup
{
    // subclasses do stuff here, generally for beautiful section headers or titles.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.statCategoryName = [self.statsDisplay.statDescriptors[[self.descriptorIndex integerValue]] valueForKey:@"label"];
    if ([self.toSelect isKindOfClass:[Fielding class]]) {
        _statCategoryName = [NSString stringWithFormat:@"%@ - %@",_statCategoryName,[self.toSelect valueForKey:@"pos"]];
    }
    NSString *titleToBe = @"";
    if (self.tabBarController) {
        titleToBe = [NSString stringWithFormat:@"%@ - %@",[StatHead statNameForStatsDisplayStatType:self.statsDisplay.type], _statCategoryName];
        if (self.yearID != nil)
            titleToBe = [NSString stringWithFormat:@"%@ - %@", titleToBe, self.yearID];
    }
    // Changing title here also changes the tab label ***
    self.tabBarController.title = titleToBe; // one of these will be it.
    [self doCustomSetup];
    if (_fetchOpQueue) [_fetchOpQueue cancelAllOperations]; // Even though asynchronous, there is only one at a time.
    else {
        NSOperationQueue *fOQ = [[NSOperationQueue alloc] init];
        self.fetchOpQueue = fOQ;
    }
    // teamSeasonSelectionPredicateWithSource is overridden by subclasses.
    NSPredicate *predicate = [self teamSeasonSelectionPredicateWithSource:self.toSelect];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    PlayerRankOperation *bigOperation = [[PlayerRankOperation alloc] initWithStatsDisplay:_statsDisplay descriptorIndex:_descriptorIndex showAll:self.showAll statObj:_toSelect predicate:predicate managedObjectContext:[appDel managedObjectContext]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataIsReady:) name:@"DataIsReadyNotification" object:nil];
    [_fetchOpQueue addOperation:bigOperation];
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

-(void)subclassUserInterfaceStuffToDoWhenDataIsReady
{
    // override this.
}

-(void)userInterfaceStuffToDoWhenDataIsReady
{
    [self subclassUserInterfaceStuffToDoWhenDataIsReady];
    [self.tableView reloadData];
    [self performSelector:@selector(selectRowAtIndexPath) withObject:nil afterDelay:0];
}

// dataIsReady aka dressIsReady
//   Here when PlayerRankOperation gets all done and has data for us.
// section*Roster are arrays of objectIDs.
-(void)dataIsReady:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DataIsReadyNotification" object:nil];
    // Get the data and unpack it.
    NSDictionary *resultsFromThread = [notification userInfo];
    NSMutableArray *section0ArrayStaging = [[NSMutableArray alloc] init];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mOC = appDel.managedObjectContext;
    for (id anObject in resultsFromThread[@"section0Roster"]) {
        id thisObject = [anObject copy];
        if ([thisObject isKindOfClass:[NSManagedObjectID class]])
            thisObject = [mOC objectWithID:thisObject];
        [section0ArrayStaging addObject:thisObject];
    }
    self.section0Roster = section0ArrayStaging;
    self.section1Roster = nil;
    if ([resultsFromThread[@"section1Roster"] count] > 0) {
        NSMutableArray *section1ArrayStaging = [[NSMutableArray alloc] init];
        for (id anObject in resultsFromThread[@"section1Roster"]) {
            id thisObject = [anObject copy];
            if ([thisObject isKindOfClass:[NSManagedObjectID class]])
                thisObject = [mOC objectWithID:thisObject];
            [section1ArrayStaging addObject:thisObject];
        }
        self.section1Roster = section1ArrayStaging;
    }
    self.toSelectIndex = [resultsFromThread[@"toSelectIndex"] integerValue];
    _section1_rank_start  = [resultsFromThread[@"section1_rank_start"] integerValue];
    // Not sure if notification method is in a different thread but just in case.
    [self performSelectorOnMainThread:@selector(userInterfaceStuffToDoWhenDataIsReady) withObject:nil waitUntilDone:FALSE];
}

-(void)setShowAll:(BOOL)showCompleteRanking {
    _showAll = showCompleteRanking;
}

- (void) selectRowAtIndexPath {
    NSInteger sectionToSelect = 0;
    NSInteger rowToSelect = 0;
    //
    //  If player is in the top 20, select the row the player is on in the
    //  top 20 list.   We won't have a section 1 in that case.
    //
    if (self.showAll || (self.toSelectIndex < 20)) {
        rowToSelect = self.toSelectIndex;
    } else if (_section1Roster) {
        sectionToSelect = 1;
        //                       20 to 22                RC-4 to RC-1              everything else
        rowToSelect = MIN(_toSelectIndex-20, MIN(4-([_section1Roster count]-_toSelectIndex),3));
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect inSection:sectionToSelect] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    //
    // Return the number of sections.
    // If the selected player is in the top 20, we'll just have 1 section
    //
    NSInteger number_of_sections_to_return;
    if (self.showAll || (self.toSelectIndex < 20)) {
        number_of_sections_to_return = 1;
    } else {
        number_of_sections_to_return = 2;
    }
    return number_of_sections_to_return;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    //
    // Return the number of rows in the section.
    //
    NSInteger numberOfRows;
    if (self.showAll || section == 0) {
        numberOfRows = [_section0Roster count];
    } else {
        numberOfRows = [_section1Roster count];
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    NSString *titleToReturn = nil;
    if (section == 0) {
        titleToReturn = _section0HeaderTitle;
    }
    return titleToReturn;
}

//
// configureCell:atIndexPath - Subclasses can override this if not all values are required.
//
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //
    //  for showAll mode, there would be no section==1 so this all works
    //  fine without having to check for showAll.   Revisit this if something
    //  changes.  Say, for example if showAll does something with multiple sections.
    //
    NSArray *relevantSectionArray = (indexPath.section==0) ? _section0Roster : _section1Roster;
    id rosterItem = relevantSectionArray[indexPath.row];
    
    //
    // Fill out all of the details in the custom cell
    //
    if ([rosterItem isKindOfClass:[NSManagedObject class]])
        [[cell valueForKey:@"playerNameLabel"] setValue:[[rosterItem valueForKey:@"player"] valueForKey:@"fullName"] forKey:@"text"];
    else
        [[cell valueForKey:@"playerNameLabel"] setValue:[rosterItem  valueForKey:@"fullName"] forKey:@"text"];

    NSInteger rank_start = 0;
    if (indexPath.section == 1) {
        rank_start = _section1_rank_start;
    }
    [[cell valueForKey:@"rankLabel"] setValue:[NSString stringWithFormat:@"%ld", (long)rank_start+indexPath.row+1] forKey:@"text"];
    if (_yearID != nil) {
        [[cell valueForKey:@"yearLabel"] setValue:[[[rosterItem valueForKey:@"aTeamSeason"] valueForKey:@"yearID"] description] forKey:@"text"];
        [[cell valueForKey:@"teamNameLabel"] setValue:[[rosterItem valueForKey:@"aTeamSeason"] valueForKey:@"name"] forKey:@"text"];
    }
    StatDescriptor *statDescriptor = [_statsDisplay.statDescriptors objectAtIndex:[_descriptorIndex integerValue]];
    if ([rosterItem respondsToSelector:@selector(displayStringForStat:)])
        [[cell valueForKey:@"statLabel"] setValue:[rosterItem displayStringForStat:statDescriptor.key] forKey:@"text"];
    else [[cell valueForKey:@"statLabel"] setValue:[[rosterItem valueForKey:statDescriptor.key] description] forKey:@"text"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlayerRankCell";
    id cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    //   Get access to the top of the nav stack, as we might back up to a different player.
    //
    // Actually it could be PlayerCareerTBC here.
    PlayerTabBarController *ptbc = (PlayerTabBarController *)[self.navigationController backViewController];
    //
    //   There are two possibilities.   Either the user has selected the "drill down" parent player,
    //   in which case, we can just pop to the parent, or else the user has selected a teammate.
    //   If a teammate, then we can manipulate the parent to set the new user, and then pop to
    //   the modified parent view controller.
    //
    //   If in showAll model, we'll always be in section == 0, so this works fine
    //   without having to adjust for showAll being set.
    //
    NSArray *relevantSectionArray = (indexPath.section==0) ? _section0Roster : _section1Roster;
    id stats = relevantSectionArray[indexPath.row];
    // This could be a dictionary like this ***:
    //  {
    //fullName = "Joe Adcock";
    //playerID = adcocjo01;
    //seasons = 1;
    //  }
    if ([stats isKindOfClass:[NSManagedObjectID class]]) {
        stats = [[_toSelect valueForKey:@"managedObjectContext"] objectWithID:stats];
    }
    if (_yearID == nil) {
        // This is the career ranking list, and user tapped on a row.
        // Do segue to the career of that guy, and select the right tab on it.
        [self performSegueWithIdentifier:@"careerRankToPlayerCareer" sender:self];
        return;
    }
    // toSelect represents our guy, ie. whose stat we clicked first on to rank.
    // stats represents who we just clicked on, ie. same guy or teammate.
    if (stats != _toSelect) {
        Master *selectedPlayer = [stats valueForKey:@"player"];
        BQPlayer *teammate;
        teammate = [[BQPlayer alloc] initWithPlayer:selectedPlayer teamSeason:[stats valueForKey:@"aTeamSeason"]];
        // Go to the correct year for this player tap-through.
        teammate.year = [stats valueForKey:@"yearID"];
        ptbc.year = [stats valueForKey:@"yearID"];
        [ptbc changeToPlayer:teammate];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"careerRankToPlayerCareer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *relevantSectionArray = (indexPath.section==0) ? _section0Roster : _section1Roster;
        id stats = relevantSectionArray[indexPath.row];
        if ([stats isKindOfClass:[NSManagedObjectID class]])
            stats = [[_toSelect valueForKey:@"managedObjectContext"] objectWithID:stats];
        Master *selectedPlayer = [stats valueForKey:@"player"];
        if (!selectedPlayer) {
            selectedPlayer = [Master masterRecordWithPlayerID:[stats valueForKey:@"playerID"]];
        }
        [[segue destinationViewController] setValue:[[BQPlayer alloc] initWithPlayer:selectedPlayer teamSeason:nil] forKey:@"player"];
        NSInteger stat_type = _statsDisplay.type & StatsDisplayStatTypeMask;
        NSArray *statTypes = @[@"Batting",@"Pitching",@"Fielding",@"Managing"];
        NSString *statKindToSelect = statTypes[stat_type-1];
        // Select this tab in career TBC.
        [[segue destinationViewController] setValue:statKindToSelect forKey:@"statKindToSelect"];
    }
}

@end

