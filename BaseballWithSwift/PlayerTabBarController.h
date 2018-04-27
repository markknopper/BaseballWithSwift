//
//  PlayerTabBarController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/10/09.
//  Recreated by Matthew Jones in May, 2010
//  Copyright 2009-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

#import "BQPlayer.h"
#import "Teams.h"
#import "StatsViewController.h"

@interface PlayerTabBarController : UITabBarController // <UITabBarControllerDelegate>
{
    BOOL isShowingLandscapeView, thisViewHasAppeared, needToShowBaseballCardView;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; // for passalong
@property (nonatomic, strong) BQPlayer *player;
@property (nonatomic, strong) Teams *team; // If !team, give stats for all teams that year.
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) StatsViewController *managerSVC;
@property (nonatomic, strong) StatsViewController *battingSVC;
@property (nonatomic, strong) StatsViewController *pitchingSVC;
@property (nonatomic, strong) StatsViewController *fieldingSVC;
@property (nonatomic, strong) StatsViewController *personalSVC;
// original view controllers from storyboard (regular ones, unsorted by batting/pitching/etc.)
@property (nonatomic, strong) NSArray *originalViewControllers;
@property (nonatomic, strong) NSArray *sortedRegularViewControllers;
@property (nonatomic, strong) NSArray *postSeasonViewControllers;
@property (nonatomic ,strong) NSString *statKindToSelect;
@property (nonatomic, strong) UISegmentedControl *regularOrPost;
@property (nonatomic, strong) StatsViewController *battingPostSVC;
@property (nonatomic, strong) StatsViewController *pitchingPostSVC;
@property (nonatomic, strong) StatsViewController *fieldingPostSVC;

- (void) changeToPlayer:(BQPlayer *)aPlayer;

@end
