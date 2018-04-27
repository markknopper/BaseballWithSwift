//
//  TeamListForYear.h, now YearTabBarController.h
//  Baseball_Stats_Core_Data, now BaseballQuery
//
//  Created by Mark Knopper on 2/20/10.
//  Copyright © 2010-2016 Bulbous Ventures LLC. All rights reserved.
//

#import "StandingsTVController.h"
#import "SeriesTVController.h"
#import "AllStarTVC.h"
#import "AllYears.h"

@interface YearTabBarController : UITabBarController

@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) StandingsTVController *standingsTVC;
@property (nonatomic, strong) SeriesTVController *seriesTVC;
@property (nonatomic, strong) AllStarTVC *allStarTVC;
@property (nonatomic, strong) NSArray *originalViewControllers;
@property (nonatomic, strong) AllYears *parentAllYearsTVC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *upDownControl;

- (IBAction)tappedUpDown:(UISegmentedControl *)sender;

@end
