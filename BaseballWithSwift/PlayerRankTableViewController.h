//
//  PlayerRankTableViewController.h
//  BaseballWithSwift
//
//  Created by Matthew Jones on 6/4/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "StatsDisplay.h"
#import "StatsDisplayStatType.h"

@interface PlayerRankTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL showAll; // YES - complete ranking, NO - split into top 20 + abbrev
@property (nonatomic, strong) NSNumber *yearID;
@property (nonatomic, strong) id statsSource;
@property (nonatomic, strong) StatsDisplay *statsDisplay;
@property (nonatomic, strong) NSNumber * descriptorIndex; // Needs to be an NSNumber object for KVO
@property (nonatomic, strong) NSArray *section0Roster;
@property (nonatomic, strong) NSArray *section1Roster;
@property (nonatomic, strong) id toSelect; // id of roster item to select
@property (nonatomic, assign) NSInteger toSelectIndex; // cached index of toSelect in sorted roster
@property (nonatomic, strong) NSString *section0HeaderTitle;
@property (nonatomic, strong) NSOperationQueue *fetchOpQueue;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, assign) NSInteger section1_rank_start;
@property (nonatomic, strong) NSString *statCategoryName;

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)toSelect;
-(void)dataIsReady:(NSNotification *)notification;
-(void)subclassUserInterfaceStuffToDoWhenDataIsReady;

@end
