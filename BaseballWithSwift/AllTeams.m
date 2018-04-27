//
//  AllTeamsTVC.m
//  BaseballQuery
//
//  Created by Mark Knopper on 11/1/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

/* List of all teams ever played, with search and all/current control. */

@import UIKit;

#import "AllTeams.h"
#import "Teams+Query.h"
#import "TeamYearsController.h"
#import "UIViewController+IndexLetters.h"
#import "InAppPurchaseController.h"
#import "ShakeNavController.h"
#import "ThisYear.h"
#import "StatHead.h"
#import "BaseballWithSwift-Bridging-Header.h"
#import "BaseballWithSwift-Swift.h"

@interface AllTeams ()
// our secondary search results table view
@property (nonatomic, strong) AllTeamsSearchResultsTableViewController *resultsTableController;
@end

@implementation AllTeams

#pragma mark -
#pragma mark Core data fetching

-(NSFetchRequest *)standardTeamsFetch
{
	// Build and return a fetch request without a predicate.
    NSFetchRequest *aFetchRequest = [NSFetchRequest new];
    NSEntityDescription *teamsEntity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
    aFetchRequest.entity = teamsEntity;
	[aFetchRequest setResultType:NSDictionaryResultType]; // Required to return distinct results.
	[aFetchRequest setReturnsDistinctResults:YES];
	NSDictionary *entityProperties = [teamsEntity propertiesByName];
	// Only fetch name, to allow distinctness based on name.
	[aFetchRequest setPropertiesToFetch:@[entityProperties[@"name"]]];
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = @[nameDescriptor];
	[aFetchRequest setSortDescriptors:sortDescriptors];
	return aFetchRequest;
}

// Do fetch or retrieve from cache, and update results in _displayList and _indexLetters.
-(void)performSyncFetchWithSearchString:(NSString *)searchString
{
    // First see if we can just return cached results.
    if (!searchString) {
        // not searching. Check for caching.
        if (_allCurrentSegmentedControl.selectedSegmentIndex>0 && [_currentTeamsDisplayList count]>0) { // Current.
            self.displayList = _currentTeamsDisplayList;
            self.indexLetters = _currentTeamsIndexLetters;
            return;
        }
        if (_allCurrentSegmentedControl.selectedSegmentIndex==0 && _allTeamsDisplayList) { // All.
            self.displayList = _allTeamsDisplayList;
            self.indexLetters = _allTeamsIndexLetters;
            return;
        }
    }
    // Couldn't return cached results. Compute the predicate, compound style.
    NSMutableArray *andSubpredicates = [NSMutableArray new];
    if ([searchString length]>0) { // if searching,
        [andSubpredicates addObject:[NSPredicate predicateWithFormat:@"name contains[c] %@",searchString]];
    }
    if (_allCurrentSegmentedControl.selectedSegmentIndex>0) { // Current
        BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
        [andSubpredicates addObject:[NSPredicate predicateWithFormat:@"yearID == %ld",(long)appDel.latest_year_in_database]];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:andSubpredicates];
    // If didn't cache, fetch.
    NSFetchRequest *teamsFetchRequest = [self standardTeamsFetch];
    [teamsFetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    // Do entire fetch once. Cache the result.
    self.teamsObjectsFromSearch = [_managedObjectContext executeFetchRequest:teamsFetchRequest error:&fetchError];
    if (!searchString) {
        [self computeTableIndicesFromArrayUpdatingDisplayList:_teamsObjectsFromSearch withKeyPath:@"name"];
        // If no searchString, this is first fetch. Populate cache.
        if (_allCurrentSegmentedControl.selectedSegmentIndex==0) {
            // Cache results for All.
            self.allTeamsDisplayList = _displayList; // cache these.
            self.allTeamsIndexLetters = _indexLetters;
        } else {
            // Cache results for Current.
            self.currentTeamsDisplayList = _displayList;
            self.currentTeamsIndexLetters = _indexLetters;
        }
    }
}

#pragma mark -
#pragma mark All/Current Segmented Control Handling

-(IBAction)setSegmentedControllerValue:(id)sender
{
    [self performSyncFetchWithSearchString:nil];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidLoad
{
    // Do fetch as early as possible.
    // Apparently there isn't an opportunity to pass the MOC here early enough from the AppDelegate so ask for it.
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDel.managedObjectContext;
    // Do initial team search.
    [self performSyncFetchWithSearchString:nil];
    // Set up nice left shadow for when table slides to the right.
    // This class method just happens to reside in LeftMenuTVC. *** Probably should be in UIView category (extension).
    [LeftMenuTVC shadowizeViewLayer:self.tableView.layer];
    //self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    // Set up UISearchController search method.
    self.resultsTableController = [AllTeamsSearchResultsTableViewController new];
    ((AllTeamsSearchResultsTableViewController *)_resultsTableController).managedObjectContext = _managedObjectContext;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
    _searchController.searchBar.placeholder = @"Search Teams";
    // Do results filtering here but display in resultsTC.
    _searchController.searchResultsUpdater = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    _searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    _searchController.searchBar.delegate = self; // so we can monitor text changes + others
    // "Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context."
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Settings View management

-(void)segueToAbout {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"teamsToAbout" sender:self];
}
    
-(void)segueToTips {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"teamsToTips" sender:self];
}

- (IBAction)openSettingsView:(id)sender {
    if (_tableViewLeading.constant == 0) {
        // If it needs to be moved over to reveal settings,
        _tableViewLeading.constant = 250; // Move it over.
        self.tableView.userInteractionEnabled = FALSE;
    } else {
        _tableViewLeading.constant = 0; // Move it back into place.
        self.tableView.userInteractionEnabled = TRUE;
    }
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)closeSettingsView {
    _tableViewLeading.constant = 0; // Cover up settings table
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated]; // This goes right to numberOfSections so do it after fetch.
        self.tableView.userInteractionEnabled = TRUE; // We turn this off while showing settings.
        // See if we have most recent stats.
        BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDel.latest_year_in_database < LATEST_DATA_YEAR) {
            UIBarButtonItem *buyButtItem =[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Buy %d",LATEST_DATA_YEAR] style:UIBarButtonItemStylePlain target:self action:@selector(inAppPurchaseQuestion:)];
            buyButtItem.tintColor = [UIColor redColor];
            self.navigationItem.rightBarButtonItem = buyButtItem;
        } else { // already have most recent stats.
            self.navigationItem.rightBarButtonItem = nil;
        }
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    // Bring up an info popup if this is the very first time we have run
    // the app on this device. Kind of a weird place but this is the first view controller that the user sees.
- (void)viewDidAppear:(BOOL)animated
    {
        // Make the name be specific to this year so the message shows once per year.
        NSString *onceFileName = [NSString stringWithFormat:@"AllTeamsOnceFile_%@",LATEST_DATA_YEAR_STRING];
        BaseballQueryAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
        NSString *onceFileNamePath = [NSString pathWithComponents:@[[appDel databaseDocumentsDirectory],onceFileName]];
        NSFileManager *fMan = [NSFileManager defaultManager];
        if (![fMan fileExistsAtPath:onceFileNamePath]) {
            // Show a nice little alert.
            NSString *title = [NSString stringWithFormat:@"Welcome to \"Baseball Statistics %d Edition\"",LATEST_DATA_YEAR+1];
            NSString *message = [NSString stringWithFormat:@"This app contains historical stats through %d. Tap \"Buy %d\" at any time to add these in. \n\nIf you have questions/problems/suggestions email me from the Info screen. --Mark",LATEST_DATA_YEAR-1,LATEST_DATA_YEAR];
            NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            // It's not really a cancel button but it's convenient.
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                // Create the file once the user has dismissed the alert.
                // Not sure if it can be null so give it a bit of data.
                NSString *content = @"User ran the app at least once!";
                NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
                [fMan createFileAtPath:onceFileNamePath contents:fileContents attributes:nil];
            }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [super viewDidAppear:animated];
    }
    
    // Buy button pressed. Farm this out to the buying system.
- (IBAction)inAppPurchaseQuestion:(id)sender
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteBuyButton" object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.navigationItem.rightBarButtonItem = nil;
        }];
        InAppPurchaseController *purchaser = [InAppPurchaseController sharedInstance];
        [purchaser startPurchase:self];
    }
    
#pragma mark -
#pragma mark Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return [_displayList count];
}
    
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tv {
    NSArray *titlesArray = nil;
    titlesArray= _indexLetters;
    // Put in a search magnifying glass.
    NSArray *magnifyingGlassIcon = @[UITableViewIndexSearch];
    titlesArray = [magnifyingGlassIcon arrayByAddingObjectsFromArray:titlesArray];
    return titlesArray;
}
    
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    return _indexLetters[section];
}
    
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    NSString *initialLetter = [self tableView:tv titleForHeaderInSection:section];
    return [_displayList[initialLetter] count];
}
    
- (NSInteger)tableView:(UITableView *)tv sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger returned_section;
    if (title == UITableViewIndexSearch) {
        // Magnifying glass.
        [tv scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
        returned_section = -1;
    }
    else {
        returned_section = [_indexLetters indexOfObject:title];
    }
    return returned_section;
}
    
-(BOOL)isCurrentTeam:(NSString *)teamName
    {
        // Please distract yourself from looking at the following statement.
        NSArray *currentTeams = @[@"Arizona Diamondbacks", @"Atlanta Braves", @"Baltimore Orioles", @"Boston Red Sox", @"Chicago Cubs", @"Chicago White Sox", @"Cincinnati Reds", @"Cleveland Indians", @"Colorado Rockies", @"Detroit Tigers", @"Florida Marlins", @"Miami Marlins", @"Houston Astros", @"Kansas City Royals", @"Los Angeles Angels of Anaheim", @"Los Angeles Dodgers", @"Milwaukee Brewers", @"Minnesota Twins", @"New York Mets", @"New York Yankees", @"Oakland Athletics", @"Philadelphia Phillies", @"Pittsburgh Pirates", @"San Diego Padres",  @"San Francisco Giants", @"Seattle Mariners", @"St. Louis Cardinals", @"Tampa Bay Rays", @"Texas Rangers", @"Toronto Blue Jays", @"Washington Nationals"];
        return  [currentTeams containsObject:teamName];
    }
    
    // Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AllTeamsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // teamObject is probably a dictionary.
    id teamObject =[self indexLettersObjectForIndexPath:indexPath];
    NSString *teamName = [teamObject valueForKey:@"name"];
    cell.textLabel.text = teamName;
    if ([StatHead isCurrentTeam:teamName]) {
        cell.textLabel.textColor = [self.tableView tintColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
        if ([[segue identifier] isEqualToString:@"teamsToTeamYears"]) {
            // Goes to TeamYearsController
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSDictionary *team =[self indexLettersObjectForIndexPath:indexPath];
            [[segue destinationViewController] setValue:[team valueForKey:@"name"] forKey:@"teamName"];
            [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
        }
    }
    
#pragma mark - UISearchResultsUpdating
    
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // Here on every keystroke in the search field, and also clearing, I think.
    NSString *searchText = searchController.searchBar.text;
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // Filter on the new string, give results to the resultsTVC and tell it to reload. The resultsTVC does not do section indexing so no displayList/indexLetters changes.
    [self performSyncFetchWithSearchString:strippedString];
    // hand over the filtered results to our search results table
    AllTeamsSearchResultsTableViewController *tableController = (AllTeamsSearchResultsTableViewController *)_searchController.searchResultsController;
    tableController.teamsObjectsFromSearch = _teamsObjectsFromSearch;
    [tableController.tableView reloadData];
}
    

@end

