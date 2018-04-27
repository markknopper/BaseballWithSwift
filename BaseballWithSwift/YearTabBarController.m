//
//  TeamListForYear.m now YearTabBarController.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 2/20/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

/* YearTBC - tab bar controller for standings, post-season and all-star game.
 */

#import "YearTabBarController.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"

@implementation YearTabBarController

- (void)viewDidLoad
{
    // Retain original view controllers from storyboard.
    self.originalViewControllers = self.viewControllers;
    // Not sure how this would happen but there was one crash where MOC was nil, so:
    BaseballQueryAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDel.managedObjectContext;
    [self.viewControllers makeObjectsPerformSelector:@selector(setManagedObjectContext:) withObject:_managedObjectContext];
    [self.viewControllers makeObjectsPerformSelector:@selector(setYear:) withObject:_year];
    self.standingsTVC = (self.originalViewControllers)[0];
    self.seriesTVC = (self.originalViewControllers)[1];
    self.allStarTVC = (self.originalViewControllers)[2];
    // Have to select viewcontrollers manually since the number
    // and order of them are variable.
    NSMutableArray *controllersForTabs = [[NSMutableArray alloc] initWithCapacity:4];
	self.title = [self.year description];
    [controllersForTabs addObject:_standingsTVC];
    // See if there are any post-season stats this year.
	NSEntityDescription *seriesPostEntity = [NSEntityDescription entityForName:@"SeriesPost" inManagedObjectContext:_managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"yearID==%@",_year];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:seriesPostEntity];
	[fetchRequest setPredicate:predicate];
	NSError *error=nil;
	NSArray *seriesThisYear = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([seriesThisYear count]>0) {
        _seriesTVC.seriesThisYear = seriesThisYear;
        [controllersForTabs addObject:_seriesTVC];
    }
    if ([AllStarTVC allstarGamePlayedInYear:_year]) {
        [controllersForTabs addObject:_allStarTVC];
    }
    [self setViewControllers:controllersForTabs animated:NO];
    [_upDownControl setEnabled:[_parentAllYearsTVC leftUpEnabled:_year] forSegmentAtIndex:0];
    [_upDownControl setEnabled:[_parentAllYearsTVC rightDownEnabled:_year] forSegmentAtIndex:1];
    [super viewDidLoad];
}

- (IBAction)tappedUpDown:(UISegmentedControl *)sender
{
    [_parentAllYearsTVC pressedNextPrevious:sender];
}

@end
