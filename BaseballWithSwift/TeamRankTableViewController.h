//
//  TeamRankInYearViewController.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/17/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "StatsDisplay.h"

@interface TeamRankTableViewController : UIViewController

@property (nonatomic, strong) NSArray *roster; // roster of teams
@property (nonatomic, strong) StatsDisplay *statsDisplay; // the entire display template
@property (nonatomic, assign) NSNumber * descriptorIndex; // the index of the descriptor for the ranking stat
@property (nonatomic, strong) id toSelect;
@property (nonatomic, assign) NSInteger toSelectIndex; // cached index of toSelect in sorted roster
@property (nonatomic, assign) BOOL showRankingInUnifiedList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


