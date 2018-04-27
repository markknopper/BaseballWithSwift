//
//  AllPlayers.h
//  BaseballQuery
//
//  Created by Mark Knopper on 11/2/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "BaseballQueryAppDelegate.h"

@interface AllPlayers : UIViewController <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SettingsTableCalls>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *displayList;
@property (nonatomic, strong) NSMutableArray *indexLetters;
@property (nonatomic, strong) NSMutableDictionary *allPlayersDisplayList;
@property (nonatomic, strong) NSMutableArray *allPlayersIndexLetters;
@property (nonatomic, strong) NSMutableDictionary *currentPlayersDisplayList;
@property (nonatomic, strong) NSMutableArray *currentPlayersIndexLetters;
@property (nonatomic, weak) IBOutlet UISegmentedControl *allCurrentSegmentedControl;
// nonSearchResults is sorted list of all Master objects. Set in very first player search.
@property (nonatomic, strong) NSArray *nonSearchResults;
@property (nonatomic, strong) NSArray *masterLetterIndices;
@property (nonatomic, strong) NSOperationQueue *fetchOpQueue;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeading;

-(IBAction)openSettingsView:(id)sender;
-(void)fetchAllPlayersInBackground;

@end
