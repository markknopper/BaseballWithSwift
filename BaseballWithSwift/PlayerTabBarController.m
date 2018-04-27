//
//  PlayerTabBarController.m
//  BaseballWithSwift
//
//  Created by Mark Knopper on 12/10/09.
//  Revised by Matthew Jones in March - May of 2010
//  Copyright 2009-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "PlayerTabBarController.h"
#import "PlayerCareerTabBarController.h"
#import "UINavigationController+BV.h"
#import "PlayerYearsController.h"
#import "Managers.h"
#import "Batting.h"
#import "Fielding.h"
#import "Master.h"
#import "BaseballWithSwift-Bridging-Header.h"  // Need this to refer to Swift classes/methods.

@implementation PlayerTabBarController

//
//  If the player changes, it may be necessary to change the parent "Years" controller so that that
//  the back button is correct.
//
- (void) changeToPlayer:(BQPlayer *)aPlayer {
	self.player = aPlayer;
	//
	//  
	//
	PlayerYearsController *backViewController = (PlayerYearsController *)[self.navigationController backViewControllerForViewController:self];
	if ([backViewController isKindOfClass:[PlayerYearsController class]]) {
		[backViewController changeToPlayer:aPlayer];
	}
    [self setupViewControllersForPlayer];
}

/* Handle the Regular/Postseason segmented control here. Our player may have postseason data for batting/pitching for this year. If so, when displaying said batting/pitching tab, display a Regular/Postseason segmented control.
Try using just one segmented control and hiding it when there is no postseason info.
 */

-(BOOL)postSeasonInfoAvailableForViewController:(UIViewController *)viewController
{
    StatsViewController *statsViewController = (StatsViewController *)viewController;
    // Ask BQPlayer if we have post season info for this year for this player for this stat_type, and return true or false.
    return [_player postSeasonInfoAvailableForStatType:statsViewController.statsDisplayStatType];
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
    // Put on the segmented control but hide it at first.
    self.regularOrPost = [[UISegmentedControl alloc] initWithItems:@[@"Regular", @"Postseason"]]; // Could be in IB but there is a weird problem with splitting the storyboard into two - this VC's nav controller is in the other storyboard so there is no navigationItem to drag the segmented control into. Luckily it only added a few lines of code.
    _regularOrPost.hidden = YES;
    self.navigationItem.titleView = _regularOrPost;
    _regularOrPost.selectedSegmentIndex = 0; // Start with Regular.
    [_regularOrPost addTarget:self action:@selector(switchRegularOrPost:) forControlEvents:UIControlEventValueChanged];
    // Retain original view controllers from storyboard.
    self.originalViewControllers = self.viewControllers;
    [self setupViewControllersForPlayer];
    [super viewDidLoad];
}

// Switched the regular/postseason control.
-(void)switchRegularOrPost:(id)sender {
    UISegmentedControl *regPostControl = (UISegmentedControl *)sender;
    // self.selectedIndex is 9223372036854775807 ************************************* !!!
    //Crashing bug!
    // Juan Pizarro 1969 didn't play in post-season but maybe it thinks he did and couldn't find the info so crashed. How could this happen? Should have hidden the segmented control (in setupViewControllersForPlayer)! Got here by switching players a bunch so maybe the control is left over from previous use of this VC? *********************
    NSUInteger selected_tab = self.selectedIndex;
    if (selected_tab > 4) // error check. One time it was a large number like notFound.
        selected_tab = 0;
    if (regPostControl.selectedSegmentIndex == 0) { // now "regular".
        self.viewControllers = _sortedRegularViewControllers;
    } else { // change to post-season sources. Could have done this in setupViewControllersForPlayer but may as well wait until the user presses the Postseason button.
        // Change all in viewcontrollers, not just selected one. This will cache them all for later, in postSeasonViewControllers.
        if ([_postSeasonViewControllers count] > 0) {
            // We have all the postSeason VCs so just get them.
            self.viewControllers = _postSeasonViewControllers;
            return;
        }
        // Need to make sure postSeasonViewControllers is populated.
        // Time to create a new StatsViewController by magic.
        NSMutableArray *allviews = [NSMutableArray new];
        for (NSInteger i=0; i<_sortedRegularViewControllers.count; i++) {
            StatsViewController *regularVC = _sortedRegularViewControllers[i];
            if ([_player postSeasonInfoAvailableForStatType:regularVC.statsDisplayStatType]) {
                // First VC name is managers, but there isn't any managersPost so it's just a placeholder.
                NSString *postVCstoryboardID = @"battingPostSVC";
                switch (regularVC.statsDisplayStatType & StatsDisplayStatTypeMask) {
                    case StatsDisplayStatTypeBatting:
                    postVCstoryboardID = @"battingPostSVC";
                    break;
                    case StatsDisplayStatTypePitching:
                    postVCstoryboardID = @"pitchingPostSVC";
                    break;
                    case StatsDisplayStatTypeFielding:
                    postVCstoryboardID = @"fieldingPostSVC";
                    break;
                    default:
                    postVCstoryboardID = @"battingPostSVC"; // won't get here but maybe it will make the Analyzer happy.
                    break;
                }
                StatsViewController *postSeasonStatsVC = [self.storyboard instantiateViewControllerWithIdentifier:postVCstoryboardID];
                postSeasonStatsVC.statsDisplayStatType = ((regularVC.statsDisplayStatType) & StatsDisplayStatTypeMask)|StatsDisplayStatScopePost;
                postSeasonStatsVC.player = _player;
                postSeasonStatsVC.statsSources = [_player postSeasonStatSourcesForStatType:regularVC.statsDisplayStatType];
                [allviews addObject:postSeasonStatsVC];
            }
        }
        self.viewControllers = allviews;
        self.postSeasonViewControllers = allviews; // Cache these.
        selected_tab = 0;
        self.selectedIndex = 0;
    }
    UITableViewController *selectedTVC = self.viewControllers[selected_tab];
    [selectedTVC.tableView reloadData];
}

-(void)setupViewControllersForPlayer
{
	// Have to select viewcontrollers manually since the number
    // and order of them are variable.
    // These will be the sorted "regular (season)" view controllers, sortedRegularViewControllers.
    // Later when we switch the segmented control switch, we will create the sorted post view controllers, postSeasonViewControllers.
	NSMutableArray *controllersForTabs = [[NSMutableArray alloc] initWithCapacity:4];
	self.title = _player.fullName;
	_player.year = _year; // Do display year in section titles.
    self.managerSVC = nil;
	if ([_player isManager]) {
        self.managerSVC = (self.originalViewControllers)[0];
		_managerSVC.player = _player;
		_managerSVC.statsSources = [_player valueForKey:@"managing"];
		[controllersForTabs addObject:_managerSVC];
	}
    self.battingSVC = nil;
    self.pitchingSVC = nil;
	if ([_player isBatter]) { // If a batter first and foremost,
		if ([_player hasAtBats]) {
            self.battingSVC = (self.originalViewControllers)[1];
			_battingSVC.player = _player;
			_battingSVC.statsSources = [_player valueForKey:@"batting"];
			[controllersForTabs addObject:_battingSVC];
		}
		if ([_player hasPitched]) {
            self.pitchingSVC = (self.originalViewControllers)[2];
			_pitchingSVC.player = _player;
			_pitchingSVC.statsSources = [_player valueForKey:@"pitching"];
			[controllersForTabs addObject:_pitchingSVC];
		}
	} else { // He is a pitcher (more pitching games than batting games).
		if ([_player hasPitched]) {
            self.pitchingSVC = (self.originalViewControllers)[2];
			_pitchingSVC.player = _player;
			_pitchingSVC.statsSources = [_player valueForKey:@"pitching"];
			[controllersForTabs addObject:_pitchingSVC];
		}
		if ([_player hasAtBats]) {
            self.battingSVC = (self.originalViewControllers)[1];
			_battingSVC.player = _player;
			_battingSVC.statsSources = [_player valueForKey:@"batting"];
			[controllersForTabs addObject:_battingSVC];
		}
	}
    self.fieldingSVC = nil;
	if ([_player hasFielded]) {
        self.fieldingSVC = (self.originalViewControllers)[3];
		_fieldingSVC.player = _player;
        // One fielding record per position, therefore one table section per position.
		_fieldingSVC.statsSources = [_player valueForKey:@"fielding"];
		[controllersForTabs addObject:_fieldingSVC];
	}
    self.personalSVC = (self.originalViewControllers)[4];
    _personalSVC.player = _player;
    _personalSVC.statsSources = @[_player];
    [controllersForTabs addObject:_personalSVC];
    self.sortedRegularViewControllers = controllersForTabs; // Save these.
	[self setViewControllers:controllersForTabs animated:YES];
    // If we were given a stat kind to select, figure out which tab this is and select it.
    for (StatsViewController *aTab in controllersForTabs) {
        if ([_statKindToSelect isEqualToString:aTab.tabBarItem.title]) {
            self.selectedViewController = aTab;
            break;
        }
    }
    [[(UITableViewController *)self.selectedViewController tableView] reloadData];
    StatsViewController *selectedSVC = (StatsViewController *)self.selectedViewController;
    _regularOrPost.hidden = ![_player postSeasonInfoAvailableForStatType:selectedSVC.statsDisplayStatType];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"playerToCareer"]) {
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    } else if ([[segue identifier] isEqualToString:@"playerToBaseballCard"]) {
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    }
}

#pragma mark Rotation

-(void)viewWillAppear:(BOOL)animated
{
    _player.year = _year; // Career may have zeroed year and we need it here (at least for post-season if not cached).
	isShowingLandscapeView = NO;
    [super viewWillAppear:animated];
}

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

-(void)enableRotateToBaseballCard
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)disableRotateToBaseballCard
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

// Code from Apple's AlternateView sample app.
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
    // support only portrait for this view. Needs to be this way because
    // rotating means rotating to a new view.
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end

