//
//  RosterViewController
//  BaseballQuery
//
//  Created by Matthew Jones on 5/9/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "Teams.h"

@interface RosterViewController : UITableViewController

@property (nonatomic, strong) Teams *team;
@property (nonatomic, strong) NSArray *roster;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UIView *teamNameHeaderView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *upDownSegmentedControl;
@property (nonatomic, strong) NSMutableDictionary *displayList;
@property (nonatomic, strong) NSMutableArray *indexLetters;

@end
