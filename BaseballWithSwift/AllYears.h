//
//  AllYearsTVC.h
//  BaseballQuery
//
//  Created by Mark Knopper on 11/4/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
@import CoreData;
#import "BaseballQueryAppDelegate.h"

@interface AllYears : UIViewController <UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate, SettingsTableCalls>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *displayedYearsList;
@property (nonatomic, strong) NSArray *allYearsList;
@property (nonatomic, strong) NSMutableArray *indexDecades;
@property (nonatomic, strong) NSMutableDictionary *decadeDict;
@property (nonatomic, assign) BOOL sort_order_ascending;
@property (nonatomic, strong) NSFetchRequest *yearsFetchRequest;
// Selected Tab in TeamListForYearController
@property (nonatomic, assign) NSInteger selected_tab_in_TLFYC;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeading;

-(IBAction)openSettingsView:(id)sender;
-(void)pressedNextPrevious:(id)sender;
-(BOOL)leftUpEnabled:(NSNumber *)previousYear;
-(BOOL)rightDownEnabled:(NSNumber *)nextYear;


@end
