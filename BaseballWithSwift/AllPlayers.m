//
//  AllPlayers.m
//  BaseballQuery
//
//  Created by Mark Knopper on 11/2/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

/* List of all players who ever played, with search. */

#import "AllPlayers.h"
#import "UIViewController+IndexLetters.h"
#import "Master+Query.h"
#import "FirstLastBoldCell.h"
#import "StatHead.h"
#import "PlayerYearsController.h"
#import "BQPlayer.h"
#import "RootTabBarController.h"
#import "MasterLetterIndex.h"
#import "InAppPurchaseController.h"
#import "ThisYear.h"
#import "BaseballWithSwift-Bridging-Header.h"  // Need this to call Swift methods.
#import "BaseballWithSwift-Swift.h"

@interface AllPlayers ()
// our secondary search results table view
@property (nonatomic, strong) AllPlayersSearchResultsTableViewController *resultsTableController;
@end

@implementation AllPlayers

-(void)fetchAllPlayersInBackground
{
    // New modern approach using NSOperation.
    if (_fetchOpQueue) [_fetchOpQueue cancelAllOperations]; // Even though asynchronous, there is only one at a time.
    else {
        self.fetchOpQueue = [[NSOperationQueue alloc] init];
        [_fetchOpQueue setMaxConcurrentOperationCount:1];
    }
    NSBlockOperation* theOp = [NSBlockOperation blockOperationWithBlock: ^{
        [_managedObjectContext performBlock:^{
            NSPersistentStoreCoordinator *psc = [_managedObjectContext persistentStoreCoordinator];
            NSFetchRequest *asyncFetchRequest = [self standardPlayerFetchWithSearchString:nil];
            [asyncFetchRequest setPredicate:nil];
            [asyncFetchRequest setFetchLimit:0];
            ///// *
            self.nonSearchResults = nil; // release if we had one.
            NSError *error = nil;
            // The big one!
            NSArray *tempNonSearchResults = [_managedObjectContext executeFetchRequest:asyncFetchRequest error:&error];
            // Some time later.
            NSPersistentStoreCoordinator *newPSC = [_managedObjectContext persistentStoreCoordinator];
            // If main thread happened to buy the data and did installNewDatabaseAtPath,
            // need to give up on this.
            if (newPSC != psc) return; // Exit stage left.
            self.nonSearchResults = tempNonSearchResults;
            NSDictionary *displayListAndIndexLetters = [self computeTableIndicesFromArray:tempNonSearchResults withKeyPath:@"nameLast"];
            self.allPlayersDisplayList = displayListAndIndexLetters[@"displayList"]; // cache these.
            self.allPlayersIndexLetters = displayListAndIndexLetters[@"indexLetters"];
            self.displayList = _allPlayersDisplayList;
            self.indexLetters = _allPlayersIndexLetters;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // By this time we've already done viewWillAppear hopefully.
                [self.tableView reloadData];
            }]; // addOperationWithBlock
        }]; //performBlock
    }]; // blockOperationWithBlock
    [_fetchOpQueue addOperation:theOp];
}

#pragma mark -
#pragma mark Fetch Request Setup

-(NSFetchRequest *)standardPlayerFetchWithSearchString:(NSString *)searchString
{
    // Build and return a fetch request without a predicate.
    NSFetchRequest *aFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Master"];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameLast" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    // Doing case insensitive compare is the right thing to do, because
    // it sorts "de la Rosa" with the D's.
    NSSortDescriptor *firstNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameFirst" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[lastNameDescriptor,firstNameDescriptor];
    [aFetchRequest setSortDescriptors:sortDescriptors];
    [aFetchRequest setResultType:NSManagedObjectIDResultType]; // It's always on a separate thread.
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    //
    // computedPredicate - Compute predicate for all/current and/or search filter.
    // Hokay. What we want is:
    // An AND compound predicate.
    // First AND term: playedInLatestYear==true (only if "Current").
    // Second AND term: startedInLatestYear==false (only if not paid)
    // Third AND term (only if any typed string):
    //     If 1 term: match first OR match last;
    //     If >1 term: (match first term to first name, rest of terms to last name) OR (match whole string including spaces to last name)
    
    //name(s) match which is either an OR compound pred, or an AND compound pred.
    
    // blank or no search string - just first & second, no name match
    // one word: match last or first name.
    // two words: match first=first & last=last [for further study: last first].
    NSMutableArray *andSubpredicates = [NSMutableArray new];
    if ([_allCurrentSegmentedControl selectedSegmentIndex]>0)
        [andSubpredicates addObject:[NSPredicate predicateWithFormat:@"playedInLatestYear==TRUE"]];
    if (![appDel allowNewInLatestYear])
        [andSubpredicates addObject:[NSPredicate predicateWithFormat:@"startedInLatestYear==FALSE"]];
    if ([searchString length]>0) {
        NSString *fixedSearchString = searchString;
        // Trim leading and trailing spaces but leave spaces in the middle.
        fixedSearchString = [fixedSearchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // Break up names.
        NSArray *typedWords = [fixedSearchString componentsSeparatedByString:@" "];
        NSPredicate *predLast = [NSPredicate predicateWithFormat:@"nameLast beginswith[c] %@", typedWords[0]];
        NSPredicate *predFirst = [NSPredicate predicateWithFormat:@"nameFirst beginswith[c] %@", typedWords[0]];
        if ([typedWords count]==1) { //     //     If 1 term: match first OR match last;
            [andSubpredicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:@[predLast, predFirst]]];
        } else if ([typedWords count]>1) { // If there were zero don't add an AND term so it would give all players. Probably doesn't happen so this could just be Else.
            //     If >1 term: (match first term to first name, rest of terms to last name) OR (match whole string including spaces to last name)
            NSPredicate *matchFirstTermToFirstName = [NSPredicate predicateWithFormat:@"nameFirst beginswith[c] %@", typedWords[0]];
            NSArray *termsStaringWithSecond = [typedWords subarrayWithRange:NSMakeRange(1, typedWords.count - 1)];
            NSString *secondThroughLastWithSpaces = [termsStaringWithSecond componentsJoinedByString:@" "];
            NSPredicate *matchRestOfTermsToLastName = [NSPredicate predicateWithFormat:@"nameLast beginswith[c] %@", secondThroughLastWithSpaces];
            NSCompoundPredicate *matchFirstAndMatchRest = [NSCompoundPredicate andPredicateWithSubpredicates:@[matchFirstTermToFirstName, matchRestOfTermsToLastName]];
            NSString *allWordsStringIgnoringDoubleSpaces = [typedWords componentsJoinedByString:@" "]; // Be nice and ignore double spaces.
            NSCompoundPredicate *matchFirstAndMatchRestOrMatchWholeString = [NSCompoundPredicate orPredicateWithSubpredicates: @[matchFirstAndMatchRest, [NSPredicate predicateWithFormat:@"nameLast beginswith[c] %@", allWordsStringIgnoringDoubleSpaces]]];
            [andSubpredicates addObject:matchFirstAndMatchRestOrMatchWholeString];
        }
    }
    aFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:andSubpredicates];
    return aFetchRequest;
}

// Do fetch or retrieve from cache, and update results in _displayList and _indexLetters.
-(void)performSyncFetchWithSearchString:(NSString *)searchString
{
    // First see if we can just return cached results.
    if (!searchString) {
        // not searching. Check for caching.
        if (_allCurrentSegmentedControl.selectedSegmentIndex>0 && [_currentPlayersDisplayList count]>0) {
            self.displayList = _currentPlayersDisplayList;
            self.indexLetters = _currentPlayersIndexLetters;
            return;
        }
        if (_allCurrentSegmentedControl.selectedSegmentIndex==0 && [_allPlayersDisplayList count]>0) {
            self.displayList = _allPlayersDisplayList;
            self.indexLetters = _allPlayersIndexLetters;
            return;
        }
    }
    // Couldn't return cached results. Compute the predicate, compound style. Then do a fetch. Cache the result if no search string.
    NSFetchRequest *playersFetchRequest = [self standardPlayerFetchWithSearchString:searchString];
    if ([searchString length]==0) playersFetchRequest.fetchBatchSize = 10;
    NSError *fetchError = nil;
    NSArray *playerResults = [_managedObjectContext executeFetchRequest:playersFetchRequest error:&fetchError];
    [self computeTableIndicesFromArrayUpdatingDisplayList:playerResults withKeyPath:@"nameLast"];
    if (!searchString) {
        // If no searchString, this is first fetch. Populate cache.
        // *** How much memory does it require to leave this stuff around anyway?
        if (_allCurrentSegmentedControl.selectedSegmentIndex==0) {
            // Cache results for All.
            self.allPlayersDisplayList = _displayList; // cache these.
            self.allPlayersIndexLetters = _indexLetters;
        } else {
            // Cache results for Current.
            self.currentPlayersDisplayList = _displayList;
            self.currentPlayersIndexLetters = _indexLetters;
        }
    }
}

#pragma mark -
#pragma mark All/Current Segmented Control Handling

-(IBAction)allCurrentSegmentedControllerClicked:(id)sender
{
    // Will retrieve search from cache and reload, or
    // this might be first time Current was clicked so it will do the full search in that case and cache the Current results.
    [self performSyncFetchWithSearchString:nil];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.tableView.userInteractionEnabled = TRUE;
	// See if we have most recent stats.
	BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDel.latest_year_in_database < LATEST_DATA_YEAR) {
        UIBarButtonItem *buyButtItem =[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Buy %d",LATEST_DATA_YEAR] style:UIBarButtonItemStylePlain target:self action:@selector(inAppPurchaseQuestion:)];
        buyButtItem.tintColor = [UIColor redColor];
		self.navigationItem.rightBarButtonItem = buyButtItem;
	} else { // already have most recent stats.
		self.navigationItem.rightBarButtonItem = nil;
	}
}

// Action for Buy 20XX button on top.
// Buy button pressed. Farm this out to the buying system.
- (IBAction)inAppPurchaseQuestion:(id)sender
{
    InAppPurchaseController *purchaser = [InAppPurchaseController sharedInstance];
    [purchaser startPurchase:self];
}

//
// viewDidLoad - Could be first time or could be here after didReceiveMemoryWarning. 
//
- (void)viewDidLoad {
    self.tableView.rowHeight = 44; // Custom dynamic cell defaulted to row height of -1 !
    // fetchAllPlayersInBackground is now done from app delegate right at app startup.
    if (!_masterLetterIndices) {
        NSFetchRequest *masterLetterIndicesFetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MasterLetterIndex" inManagedObjectContext:_managedObjectContext];
        NSSortDescriptor *letterSort = [NSSortDescriptor sortDescriptorWithKey:@"letter" ascending:YES];
        [masterLetterIndicesFetch setSortDescriptors:@[letterSort]];
        [masterLetterIndicesFetch setEntity:entity];
        NSError *error = nil;
        self.masterLetterIndices = [_managedObjectContext executeFetchRequest:masterLetterIndicesFetch error:&error];
    }
    // No need to explicitly compute letter indices for All, since we have MasterLetterIndices table.
    // Also nothing to cache. Well except how about generating allPlayersIndexLetters, which should be
    // quick.
    self.allPlayersIndexLetters = [[NSMutableArray alloc] init];
    for (MasterLetterIndex *mLI in _masterLetterIndices) {
        [_allPlayersIndexLetters addObject:mLI.letter]; // Will stay sorted.
    }
    if ([_allCurrentSegmentedControl selectedSegmentIndex]==0) { // if seg set to all,
        self.indexLetters = _allPlayersIndexLetters;
    }
    // Set up UISearchController search method.
    self.resultsTableController = [AllPlayersSearchResultsTableViewController new];
    ((AllPlayersSearchResultsTableViewController *)_resultsTableController).managedObjectContext = _managedObjectContext;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
    _searchController.searchBar.placeholder = @"Search Players";
    _searchController.delegate = self;
    // Do results filtering here but display in resultsTC.
    _searchController.searchResultsUpdater = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    _searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    _searchController.searchBar.delegate = self; // so we can monitor text changes + others
    // "Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context."
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    // Now we are a regular UITableViewController.
    [self.tableView registerNib:[UINib nibWithNibName:@"FirstLastBoldCell" bundle:nil] forCellReuseIdentifier:@"FirstLastBoldCell"];
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Slide-out for settings
    
-(void)segueToAbout {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"playersToAbout" sender:self];
}
    
-(void)segueToTips {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"playersToTips" sender:self];
}

- (IBAction)openSettingsView:(id)sender {
    if (_tableViewLeading.constant == 0) {
        // If it needs to be moved over to reveal settings,
        _tableViewLeading.constant = 250; // Move it over.
        self.tableView.userInteractionEnabled = FALSE;
    } else {
        _tableViewLeading.constant = 0; // Move it back into place.
        self.tableView.userInteractionEnabled = FALSE;
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
    NSInteger returned_number_of_rows = 0;
    if ([_allCurrentSegmentedControl selectedSegmentIndex]==0) { // if seg set to all,
        // All results are in nonSearchResults, and we have masterLetterIndices.
        // Take row number index of next section, and subtract row num index of this section.
        // or if we are at last section, use total player count for first value.
        NSInteger this_section_index = [[_masterLetterIndices[section] valueForKey:@"index"] integerValue];
        NSInteger next_section_index;
        if (section == [_masterLetterIndices count]-1) {
            next_section_index = [_nonSearchResults count];
        } else {
            next_section_index = [[_masterLetterIndices[section+1] valueForKey:@"index"] integerValue];
        }
        returned_number_of_rows = next_section_index - this_section_index;
    }
    else if (_displayList) {
        NSString *initialLetter = [self tableView:tv titleForHeaderInSection:section];
        returned_number_of_rows = [_displayList[initialLetter] count];
    }
    return returned_number_of_rows;
}

- (NSInteger)tableView:(UITableView *)tv sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSInteger returned_section;
	if (title == UITableViewIndexSearch) { // magnifying glass in index column.
		[tv scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
		returned_section = -1;
	} 
	else {
		returned_section = [_indexLetters indexOfObject:title];
	}
	return returned_section;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"FirstLastBoldCell";
    FirstLastBoldCell *cell = (FirstLastBoldCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.firstNameLabel.text = nil;
    cell.lastNameLabel.text = nil;
    cell.positionLabel.text = nil;
	id yesMaster = nil; // Maybe a dictionary if we did setPropertiesToFetch to optimize.
		if ([_allCurrentSegmentedControl selectedSegmentIndex]==0) { // if seg set to all,
			NSInteger section_base_index = [[_masterLetterIndices[indexPath.section] valueForKey:@"index"] integerValue];
			NSInteger index_into_full_results = section_base_index + indexPath.row;
			yesMaster = _nonSearchResults[index_into_full_results];
		}
		else if (_displayList) {
			/*
			// Now we have a special data model table for masterLetterIndices, where the attributes
			// are: letter index, and index into sorted data to start of this letter.
			// eg. @"L", 24002. This would be a prepopulated table in the database with only 26 entries.
			// Instead of saving displayList, we would save the sorted 'results' array.
			 // There would be no 'computeTableIndicesFromArray' method to waste a lot of time and space.
			 // indexLetters, an array of letters A-Z but with any missing where there is no
			 // data for that letter, would be built at startup from the letterIndicesToData.
			// So when passed an indexPath with section and row, to get the data we would look in
			// letterIndicesToData for the section and get the index. Then index into 'results' to 
			 // get the player master object. Seems way faster and cleaner.
			 */
			yesMaster = [self indexLettersObjectForIndexPath:indexPath];
		} 
	//}
	if ([yesMaster isKindOfClass:[NSManagedObjectID class]])
		yesMaster = [_managedObjectContext objectWithID:yesMaster];
    // Following works if yesMaster is an NSDictionary
	cell.firstNameLabel.text = [yesMaster valueForKey:@"nameFirst"];
	cell.lastNameLabel.text = [yesMaster valueForKey:@"nameLast"];
    cell.positionLabel.text = [yesMaster debutFinalYearsString];
    //[self debutFinalYearsString:yesMaster];
    if ([(Master *)yesMaster checkIfPlayedInLatestYear]) {
        cell.firstNameLabel.textColor = [self.tableView tintColor];
        cell.lastNameLabel.textColor = [self.tableView tintColor];
	} else {
		cell.firstNameLabel.textColor = [UIColor blackColor];
		cell.lastNameLabel.textColor = [UIColor blackColor];
	}
	return cell;
}

-(Master *)masterForSelectedRow
{
    id yesMaster = nil; // This will be our guy, whether dictionary or Master object.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([_allCurrentSegmentedControl selectedSegmentIndex]==0) { // if seg set to all,
        NSInteger section_base_index = [[_masterLetterIndices[indexPath.section] valueForKey:@"index"] integerValue];
        NSInteger index_into_full_results = section_base_index + indexPath.row;
        yesMaster = _nonSearchResults[index_into_full_results];
    } else if (_displayList)
        yesMaster = [self indexLettersObjectForIndexPath:indexPath];
    if ([yesMaster isKindOfClass:[NSManagedObjectID class]]) {
        yesMaster = [_managedObjectContext objectWithID:yesMaster];
    }
    if ([yesMaster isKindOfClass:[NSDictionary class]])
        yesMaster = [Master masterRecordWithPlayerID:[yesMaster valueForKey:@"playerID"]];
    return yesMaster;
}

// Now that we have a custom cell, it doesn't have an automatic segue.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"allPlayersToPlayerYears" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"allPlayersToPlayerYears"] || [[segue identifier] isEqualToString:@"allPlayersToBaseballCard"]) {
        Master *yesMaster = [self masterForSelectedRow];
        BQPlayer *yesPlayer = [[BQPlayer alloc] initWithPlayer:yesMaster teamSeason:nil yearID:nil];
        [[segue destinationViewController] setValue:yesPlayer forKey:@"player"];
    }
}

#pragma mark Little Tiny amount of code for SearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strippedString length]==0) return; // Don't get whole list again. It's too slow. Seems to have whole list from before search entered.
   NSFetchRequest *fetchRequest = [self standardPlayerFetchWithSearchString:strippedString];
    NSError *error = nil;
    NSArray *searchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    // Calling Swift is transparent!
    AllPlayersSearchResultsTableViewController *resultsTableController = (AllPlayersSearchResultsTableViewController *)_searchController.searchResultsController;
    resultsTableController.masterObjectsFromSearch = searchResults;
    [resultsTableController.tableView reloadData];
}

@end
