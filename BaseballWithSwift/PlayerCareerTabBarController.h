//
//  PlayerCareerTabBarController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/10/09.
//  Recreated by Matthew Jones in May, 2010
//  Copyright 2009-2015 Bulbous Ventures LLC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BQPlayer.h"
#import "StatsViewController.h"

@interface PlayerCareerTabBarController : UITabBarController <UIActionSheetDelegate>
{
    BOOL isShowingLandscapeView, thisViewHasAppeared, needToShowBaseballCardView;
}

@property (nonatomic, strong) BQPlayer *player;
@property (nonatomic, strong) StatsViewController *managerSVC;
@property (nonatomic, strong) StatsViewController *battingSVC;
@property (nonatomic, strong) StatsViewController *pitchingSVC;
@property (nonatomic, strong) StatsViewController *fieldingSVC;
@property (nonatomic, strong) StatsViewController *personalSVC;
@property (nonatomic, strong) NSArray *originalViewControllers;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *webButton;
@property (nonatomic ,strong) NSString *statKindToSelect;

- (void) changeToPlayer:(BQPlayer *)aPlayer;
- (IBAction)webButtonPressed:(id)sender;

@end
