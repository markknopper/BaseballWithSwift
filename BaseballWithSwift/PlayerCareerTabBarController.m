//
//  PlayerCareerTabBarController.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/10/09.
//  Revised by Matthew Jones in March - May of 2010
//  Copyright 2009-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "PlayerCareerTabBarController.h"
#import "PlayerTabBarController.h"
#import "UINavigationController+BV.h"
#import "PlayerYearsController.h"
#import "Managers.h"
#import "Batting+Query.h"
#import "Fielding.h"
#import "Master+Query.h"
#import "Teams.h"
#import "BaseballQueryAppDelegate.h"
#import "ManagerTotals.h"
#import "BattingTotals.h"
#import "BaseballWithSwift-Swift.h"

@implementation PlayerCareerTabBarController

//
//  If the player changes, it may be necessary to change the parent "Years" controller so that that
//  the back button is correct.
//
- (void) changeToPlayer:(BQPlayer *)aPlayer {
	self.player = aPlayer;
	PlayerTabBarController *backViewController = (PlayerTabBarController *)[self.navigationController backViewControllerForViewController:self];
	if ([backViewController isKindOfClass:[PlayerTabBarController class]]) {
		[backViewController changeToPlayer:aPlayer];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // First check for rotation to baseball card segue.
    if ([[segue identifier] isEqualToString:@"playerToBaseballCard"])
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    else if ([[segue identifier] isEqualToString:@"careerToTransactions"])
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    else if ([[segue identifier] isEqualToString:@"careerToWeb"]) {
        // Set up for various web destinations.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [[segue destinationViewController] setValue:[_player.master fullName] forKey:@"title"];
        NSURL *externalURL = [_player.master urlOnWebSite: ((UIAlertAction *)sender).title];
        [[segue destinationViewController] setValue:externalURL forKey:@"statsURL"];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.managerSVC = nil;
    self.battingSVC = nil;
    self.pitchingSVC = nil;
    self.fieldingSVC = nil;
    self.personalSVC = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
	_player.year = nil; // Don't display year in career stat section titles.
    _player.team = nil; // Don't include per-year stats (eg. salary) in career info.
    // Retain original view controllers from storyboard.
    self.originalViewControllers = self.viewControllers;
    self.managerSVC = (self.originalViewControllers)[0];
    self.battingSVC = (self.originalViewControllers)[1];
    self.pitchingSVC = (self.originalViewControllers)[2];
    self.fieldingSVC = (self.originalViewControllers)[3];
    self.personalSVC = (self.originalViewControllers)[4];
	// Have to select viewcontrollers manually since the number
    // and order of them are variable.
	NSMutableArray *controllersForTabs = [[NSMutableArray alloc] initWithCapacity:4];
    NSInteger batting_games = 0;
    if (_player.master.battingTotals) {
        batting_games = [_player.master.battingTotals.g integerValue];
    }
    NSInteger pitching_games = 0;
    if (_player.master.pitchingTotals) {
        pitching_games = [_player.master.pitchingTotals.g integerValue];
    }
    if (pitching_games > 0) {
        _pitchingSVC.player = _player;
        _pitchingSVC.statsSources = @[_player.master.pitchingTotals];
        [controllersForTabs addObject:_pitchingSVC];
    }
    //if ([_player hasAtBats]) { // Some manager-only's have never batted.
    if (batting_games > 0) { // Some manager-only's have never batted.

        _battingSVC.player = _player;
        _battingSVC.statsSources = @[_player.master.battingTotals];
        [controllersForTabs addObject:_battingSVC];
    }
    // Switch batting and pitching if there are more batting games than pitching games and both exist.
    if (pitching_games > 0 && batting_games > 0 && batting_games > pitching_games) {
        [controllersForTabs exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    if ([_player hasFielded]) {
		_fieldingSVC.player = _player;
		_fieldingSVC.statsSources = [_player.master fieldingRecordsByPosition];
		[controllersForTabs addObject:_fieldingSVC];
    }
    if ([_player isManager]) {
        _managerSVC.player = _player;
        _managerSVC.statsSources = @[_player.master.managerTotals];
        // If more managing games than pitching or batting, put managers first.
        NSInteger manager_games = 0;
        if (_player.master.managerTotals) {
            manager_games = [_player.master.managerTotals.g integerValue];
            // So far we have Batting Pitching and Fielding, so add manager at the beginning if manager games is more than both batting and pitching, or at the end otherwise.
            if ((manager_games > batting_games) &&
                (manager_games > pitching_games)) {
                [controllersForTabs insertObject:_managerSVC atIndex:0];
            } else {
                [controllersForTabs addObject:_managerSVC];
            }
        }
    }
    // Sort controllersForTabs by Games! This is slightly difficult to do. Need to
    //  sum  games ("g" key) in the records in statsSources.
    // *** doesn't work because svc.statsSources is sometimes a totals array and sometimes an array of fielding records and in that case the fieldingtotals are actually in player.master.fieldingtotals. This seems pretty wrong and kinda broken. Can probably reorganize it and remove a bunch of code from statsviewcontroller and various places. We will hold off for now and leave this unsorted. It's really not that offensive! ***
    //[controllersForTabs sortUsingSelector:@selector(compareSumOfGames:)];
    //
    _personalSVC.player = _player;
    _personalSVC.statsSources = @[_player];
    [controllersForTabs addObject:_personalSVC];
    // There are two different personal statsviewcontrollers in the storyboard, one for individual year and one for personal. They probably could be combined into one since they look the same in storyboard. *** The difference is that personal for career has multiple entries for awards and all-star games. Note there is a segue from personal to all-star and it looks like both of them go there in the storyboard.
    // If we were given a stat kind to select, figure out which tab this is and select it.
	[self setViewControllers:controllersForTabs animated:YES];
    for (StatsViewController *aTab in controllersForTabs) {
        if ([_statKindToSelect isEqualToString:aTab.tabBarItem.title]) {
            self.selectedViewController = aTab;
            break;
        }
    }
    [super viewDidLoad];
}

#pragma mark Rotate to Baseball Card View methods

- (void)viewDidAppear:(BOOL)animated
{
	thisViewHasAppeared = TRUE;
    [self enableRotateToBaseballCard];
	if (needToShowBaseballCardView) {
		needToShowBaseballCardView = FALSE;
        [self performSegueWithIdentifier:@"playerToBaseballCard" sender:self];
	}
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	thisViewHasAppeared = FALSE;
    [self disableRotateToBaseballCard];
	[super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
	isShowingLandscapeView = NO;
    [super viewWillAppear:animated];
}

-(void)enableRotateToBaseballCard
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void)disableRotateToBaseballCard
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

// ------------------------------------------------------
//	orientationChanged:
//  Handler for the UIDeviceOrientationDidChangeNotification.
//  See also: awakeFromNib
// ------------------------------------------------------
- (void)orientationChanged:(NSNotification *)notification
{
    // A delay must be added here, otherwise the new view will be swapped in
	// too quickly resulting in an animation glitch
    [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

- (void)updateLandscapeView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
    {
        if (!thisViewHasAppeared) {
			// We are in the middle of a transition so presentModalViewController is not allowed.
			// Schedule it to be done in viewDidAppear.
			needToShowBaseballCardView = TRUE;
			return;
		}
        [self performSegueWithIdentifier:@"playerToBaseballCard" sender:self];
        isShowingLandscapeView = YES;
    } 	else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
        isShowingLandscapeView = NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // support only portrait for this view.
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [self disableRotateToBaseballCard];
}

#pragma mark Web button

- (IBAction)webButtonPressed:(id)sender {
    // Menu items here (with icons?):
    // Transactions and Trades
    // Career Stats
    // Wikipedia.com
    // BaseballReference.com
    // BaseballAlmanac.com
    // Retrosheet.org
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[_player.master fullName] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // Create the actions.
    UIAlertAction *transAction = [UIAlertAction actionWithTitle:@"Transactions/Trades" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"careerToTransactions" sender:self];
    }];
    [alertController addAction:transAction];
    UIAlertAction *wikipediaAction = [UIAlertAction actionWithTitle:@"Wikipedia" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"careerToWeb" sender:action];
    }];
    [alertController addAction:wikipediaAction];
    UIAlertAction *baseballReferenceAction = [UIAlertAction actionWithTitle:@"Baseball-Reference.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"careerToWeb" sender:action];
    }];
    [alertController addAction:baseballReferenceAction];
    UIAlertAction *baseballAlmanacAction = [UIAlertAction actionWithTitle:@"BaseballAlmanac.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"careerToWeb" sender:action];
    }];
    [alertController addAction:baseballAlmanacAction];
    // Be tolerant of missing data. There are a bunch of missing retroIDs.
    if (_player.master.retroID && ![_player.master.retroID isEqualToString:@" "]) {
        UIAlertAction *retrosheetAction = [UIAlertAction actionWithTitle:@"Retrosheet.org" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"careerToWeb" sender:action];
        }];
        [alertController addAction:retrosheetAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:cancelAction];
    // Configure the alert controller's popover presentation controller if it has one.
    UIPopoverPresentationController *popoverPresentationController = [alertController popoverPresentationController];
    if (popoverPresentationController) {
        popoverPresentationController.barButtonItem = sender;
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

@end


    


