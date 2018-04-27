//
//  RootTabBarController.m
//  BaseballQuery
//
//  Created by Mark Knopper on 10/31/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "RootTabBarController.h"
#import "AllTeams.h"
#import "AllPlayers.h"
#import "AllYears.h"
#import "BaseballQueryAppDelegate.h"
#import "QueryResultsViewController.h"
#import "QueryBuilderViewController.h"

@implementation RootTabBarController

//
// resetControllers - create new tab controllers because we purchased new data.
//
-(void)resetControllers
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDel.managedObjectContext;
    NSArray *tabVCs = @[[self.storyboard instantiateViewControllerWithIdentifier:@"allTeamsTVC"],[self.storyboard instantiateViewControllerWithIdentifier:@"AllPlayers"],[self.storyboard instantiateViewControllerWithIdentifier:@"allYearsTVC"],[self.storyboard instantiateViewControllerWithIdentifier:@"queryBuilderViewController"]];
    for (id aNVC in tabVCs) {
        if ([aNVC respondsToSelector:@selector(setManagedObjectContext:)])
            [aNVC setManagedObjectContext:_managedObjectContext];
    }
    /* UITabBarController viewControllers: "If you change the value of this property at runtime, the tab bar controller removes all of the old view controllers before installing the new ones. The tab bar items for the new view controllers are displayed immediately and are not animated into position. When changing the view controllers, the tab bar controller remembers the view controller object that was previously selected and attempts to reselect it. If the selected view controller is no longer present, it attempts to select the view controller at the same index in the array as the previous selection. If that index is invalid, it selects the view controller at index 0."
     */
    self.viewControllers = tabVCs;
}

-(void)viewDidLoad
{
    // Provide managedObjectContext to all controllers.
    for (id aNVC in self.viewControllers) {
        if ([aNVC respondsToSelector:@selector(setManagedObjectContext:)])
            [aNVC setManagedObjectContext:_managedObjectContext];
    }
	[super viewDidLoad];
	if (indexToSelect != nil) self.selectedIndex = [indexToSelect integerValue];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden {
    return FALSE;
}

@end

