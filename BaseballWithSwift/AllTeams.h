//
//  AllTeams.h
//  BaseballWithSwift
//
//  Created by Mark Knopper on 11/1/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "BaseballQueryAppDelegate.h"

@interface AllTeams : UIViewController <UIAlertViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate, SettingsTableCalls>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *displayList;
@property (nonatomic, strong) NSMutableArray *indexLetters;
@property (nonatomic, strong) NSMutableDictionary *allTeamsDisplayList;
@property (nonatomic, strong) NSMutableArray *allTeamsIndexLetters;
@property (nonatomic, strong) NSMutableDictionary *currentTeamsDisplayList;
@property (nonatomic, strong) NSMutableArray *currentTeamsIndexLetters;
@property (nonatomic, strong) NSArray *teamsObjectsFromSearch;
@property (nonatomic, weak) IBOutlet UISegmentedControl *allCurrentSegmentedControl;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeading;

- (IBAction)openSettingsView:(id)sender;

@end
