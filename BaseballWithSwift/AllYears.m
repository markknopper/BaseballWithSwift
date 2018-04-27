//
//  AllYearsTVC.m
//  BaseballQuery
//
//  Created by Mark Knopper on 11/4/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

/* List of all years in history, with search. */
@import UIKit;

#import "AllYears.h"
#import "UIViewController+IndexLetters.h"
#import "YearTabBarController.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"
#import "ThisYear.h"
#import "BaseballWithSwift-Bridging-Header.h" // This apparently can't be defined in the .h file. Except sometimes.
#import "BaseballWithSwift-Swift.h"

@interface AllYears ()
@property (nonatomic, strong) AllYearsSearchResultsTableViewController *resultsTableController;
@end

@implementation AllYears

-(void)fetchYearsObjectsWithPredicate:(NSPredicate *)predicate updateIndices:(BOOL)update_indices
{
	NSError *fetchError = nil;
	[_yearsFetchRequest setPredicate:predicate]; // Get all years.
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"yearID" ascending:self.sort_order_ascending];
	NSArray *sortDescriptors = @[yearDescriptor];
	[_yearsFetchRequest setSortDescriptors:sortDescriptors];
    BaseballQueryAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSPredicate *excludeLatestPredicate = [appDel excludeLatestYear] ? [NSPredicate predicateWithFormat:@"yearID<%d",LATEST_DATA_YEAR] : [NSPredicate predicateWithValue:TRUE];
    NSPredicate *givenPredicate = predicate;
    if (predicate == nil) {
        givenPredicate = [NSPredicate predicateWithValue:TRUE];
    }
    _yearsFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[givenPredicate,excludeLatestPredicate]];
	self.displayedYearsList = [_managedObjectContext executeFetchRequest:_yearsFetchRequest error:&fetchError];
    if (update_indices)
        [self computeTableIndicesFromYearArray:_displayedYearsList withKeyPath:@"yearID" ascending:self.sort_order_ascending];
}

- (void)viewDidLoad {
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDel.managedObjectContext;
    self.sort_order_ascending = TRUE;
    self.selected_tab_in_TLFYC = 0;
    [super viewDidLoad];
    // Initial years fetch for all years.
	self.yearsFetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:_managedObjectContext];
	NSDictionary *entityProperties = [entity propertiesByName];
	[_yearsFetchRequest setResultType:NSDictionaryResultType];
	[_yearsFetchRequest setReturnsDistinctResults:YES];
	[_yearsFetchRequest setEntity:entity];
	[_yearsFetchRequest setPropertiesToFetch:@[entityProperties[@"yearID"]]];
    [self fetchYearsObjectsWithPredicate:nil updateIndices:YES];
	self.allYearsList = _displayedYearsList; // Cache this for later, ie. when clearing search.
    // Set up for searching.
    // Make search field look wider.
    //self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    // Set up UISearchController search method.
    self.resultsTableController = [AllYearsSearchResultsTableViewController new];
    _resultsTableController.managedObjectContext = _managedObjectContext;
    self.resultsTableController.tableView.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
    _searchController.searchBar.placeholder = @"Search Years";
    _searchController.searchResultsUpdater = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    _searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    _searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
}

#pragma mark -
#pragma mark Settings View management

-(void)segueToAbout {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"allYearsToAbout" sender:self];
}

-(void)segueToTips {
    _tableViewLeading.constant = 0; // Cover up settings table so back button returns without it.
    [self performSegueWithIdentifier:@"allYearsToTips" sender:self];
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

//
// reverseSort - pressed arrow button to reverse sort order in year table.
//
-(IBAction)reverseSort:(id)sender
{
	UIImage *reversedImage;
	if (self.sort_order_ascending)
		reversedImage = [UIImage imageNamed:@"down.png"];
	else 
		reversedImage = [UIImage imageNamed:@"up.png"];
	self.sort_order_ascending = !self.sort_order_ascending;
	self.navigationItem.rightBarButtonItem.image = reversedImage;
    [self fetchYearsObjectsWithPredicate:nil updateIndices:YES];
    self.allYearsList = _displayedYearsList; // Cache this for later, ie. when clearing search.
	[self.tableView reloadData];
	[self.tableView scrollRectToVisible:self.searchController.searchBar.frame animated:YES];
}

#pragma mark
#pragma mark Methods for next/previous button in child VCs

//
// pressNextPrevious - child action for next/previous button.
//  Left button is Up, right button is Down. If sort_order_ascending, this means up=previous year, 
//  down=following year. If descending, up=following year and down=previous year.
//
-(IBAction)pressedNextPrevious:(id)sender
{
	NSInteger previous_or_next = [sender selectedSegmentIndex];
	BOOL go_to_next;
	if (_sort_order_ascending)
		go_to_next = (previous_or_next!=0); 
	else 
		go_to_next = (previous_or_next==0);
	// Get current year from team list for year tab bar controller.
	id ourTLFYController = self.navigationController.topViewController;
    if ([ourTLFYController isKindOfClass:[UITabBarController class]]) {
        _selected_tab_in_TLFYC = [ourTLFYController selectedIndex];
    }
	NSInteger current_displayed_year = [[ourTLFYController valueForKey:@"year"] integerValue];
	[self.navigationController popViewControllerAnimated:NO];
	NSNumber *yearToDisplay;
	if (!go_to_next) { // previous
		yearToDisplay = @(current_displayed_year-1);
	} else { // next.
		yearToDisplay = @(current_displayed_year+1);
	}
    // Would just perform the segue but we don't want animation here.
    YearTabBarController *tLfY = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamListForYear"];
    tLfY.managedObjectContext = _managedObjectContext;
    tLfY.year = yearToDisplay;
    tLfY.parentAllYearsTVC = self;
    [tLfY setSelectedIndex:_selected_tab_in_TLFYC];
    [self.navigationController pushViewController:tLfY animated:NO];
}

-(BOOL)previousEnabled:(NSNumber *)startYear
{
	NSInteger year_coming_from = [startYear integerValue];
	NSInteger first_year_in_history = [[StatHead firstYearInHistory] integerValue];
	return (first_year_in_history < year_coming_from);	
}

-(BOOL)nextEnabled:(NSNumber *)startYear
{
	NSInteger year_coming_from = [startYear integerValue];
	NSInteger last_year_in_history = [[StatHead lastYearInHistory] integerValue];
	return (last_year_in_history > year_coming_from);	
}

-(BOOL)leftUpEnabled:(NSNumber *)startYear
{
	if (_sort_order_ascending) return [self previousEnabled:startYear];
	else return [self nextEnabled:startYear];
}

-(BOOL)rightDownEnabled:(NSNumber *)startYear
{
	if (_sort_order_ascending) return [self nextEnabled:startYear];
	else return [self previousEnabled:startYear];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger index_count = 1;
	if ([_indexDecades count] != 0) index_count = [_indexDecades count]; // Years (in search or not).
	return index_count;	
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tv 
{
	NSArray *titlesArray = nil;
	if ([_indexDecades count]>=10 && tv==self.tableView) {
		titlesArray = _indexDecades;
		NSArray *magnifyingGlassIcon = @[UITableViewIndexSearch];
		titlesArray = [magnifyingGlassIcon arrayByAddingObjectsFromArray:titlesArray];
	}
	return titlesArray; 								
}

//
// sectionForSectionIndexTitle - makes letter indices work.
//
- (NSInteger)tableView:(UITableView *)tv sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	NSInteger returned_section;
	if (title == UITableViewIndexSearch) {
		[tv scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
		returned_section = -1;
	} 
	else {
		returned_section = [_indexDecades indexOfObject:title];
	}
	return returned_section;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if ([_indexDecades count]==0) return [_displayedYearsList count];
	NSString *decadeKey = _indexDecades[section];
	// key gets array of years for that decade. Return number of years in that decade.
	rows = [_decadeDict[decadeKey] count];
	return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"YearCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if ([_indexDecades count]==0) {
		cell.textLabel.text = [_displayedYearsList[indexPath.row][@"yearID"] description];
	} else {
		// Use a key from indexDecades to obtain an array of years from decadeDict.
		NSString *theDecadeIndex = _indexDecades[indexPath.section];
		cell.textLabel.text = _decadeDict[theDecadeIndex][indexPath.row];
	}
    //cell.textLabel.backgroundColor = [UIColor clearColor];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        // Here only for click-through from search results TVC.
        NSString *yearString;
        if ([_resultsTableController.indexDecades count]==0)
            yearString = _resultsTableController.displayedYearsList[indexPath.row][@"yearID"];
        else {
            NSString *theDecadeIndex = _resultsTableController.indexDecades[indexPath.section];
            yearString = _resultsTableController.decadeDict[theDecadeIndex][indexPath.row];
        }
        [self performSegueWithIdentifier:@"allYearsToTeamListForYear" sender:[NSNumber numberWithInteger:[yearString integerValue]]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"allYearsToTeamListForYear"]) {
        NSString *yearToDisplay;
        if ([sender isKindOfClass:[NSNumber class]]) {
            yearToDisplay = [sender description];
        } else {
            if ([_indexDecades count]==0)
                yearToDisplay = _displayedYearsList[indexPath.row][@"yearID"];
            else {
                NSString *theDecadeIndex = _indexDecades[indexPath.section];
                yearToDisplay = _decadeDict[theDecadeIndex][indexPath.row];
            }
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[segue destinationViewController] setValue:_managedObjectContext forKey:@"managedObjectContext"];
        [[segue destinationViewController] setValue:@([yearToDisplay integerValue]) forKey:@"year"];
        [[segue destinationViewController] setValue:self forKey:@"parentAllYearsTVC"];
        [(YearTabBarController *)[segue destinationViewController] setSelectedIndex:_selected_tab_in_TLFYC];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // Here on every keystroke in the search field, and also clearing, I think.
    NSString *searchText = searchController.searchBar.text;
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = nil;
    if ([strippedString length]>0) {
        predicate = [NSPredicate predicateWithFormat:@"yearID contains[c] %@",strippedString];
        [_yearsFetchRequest setPredicate:predicate]; // Get all years.
    }
    [self fetchYearsObjectsWithPredicate:predicate updateIndices:NO];
    // hand over the filtered results to our search results table
    AllYearsSearchResultsTableViewController *tableController = (AllYearsSearchResultsTableViewController *)_searchController.searchResultsController;
    tableController.sort_order_ascending = _sort_order_ascending;
    tableController.displayedYearsList = _displayedYearsList;
    [tableController.tableView reloadData];
}

@end

