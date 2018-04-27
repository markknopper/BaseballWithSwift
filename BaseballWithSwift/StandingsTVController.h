//
//  StandingsTVController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/7/09.
//  Copyright 2009-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@interface StandingsTVController : UITableViewController

@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISegmentedControl *upDownControl;
@property (nonatomic, strong) NSArray  *sectionsForDisplay;
@property (nonatomic, strong) NSMutableArray *divisionsThisYear;
@property (nonatomic, strong) NSMutableArray *leaguesThisYear;

@end
