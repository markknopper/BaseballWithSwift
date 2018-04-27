//
//  PlayerYearsController.m
//  Baseball_Stats_Core_Data

// List of years for player. Get here when searching for player.

//
//  Created by Mark Knopper on 12/23/09.
//  Revised by Matthew Jones in March-May 2010.
//  Copyright 2009-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "PlayerYearsController.h"
#import "PlayerTabBarController.h"
#import "PlayerCareerTabBarController.h"
#import "TransactionsTVC.h"

@implementation PlayerYearsController

- (void)loadYears {
	self.title = [self.player fullName];
    self.originalTitle = self.title;
	self.yearsInOrder = [self.player.master allYearsForPlayer];
}

- (void)changeToPlayer:(BQPlayer *)aPlayer {
	self.player = aPlayer;
	[self loadYears];
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self loadYears];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_yearsInOrder count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlayerYearsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.textLabel.text = [_yearsInOrder[indexPath.row] description];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Back button is just going to be 'back'.
    self.navigationController.topViewController.title = nil;
    if ([[segue identifier] isEqualToString:@"yearToPlayerTabs"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSNumber *thisYear = _yearsInOrder[indexPath.row];
        [_player zeroOutPlayer]; // Don't leave stale stats from other years around.
        _player.year = thisYear;
        [[segue destinationViewController] setValue:_player forKey:@"player"];
        [[segue destinationViewController] setValue:nil forKey:@"team"];
        [[segue destinationViewController] setValue:thisYear forKey:@"year"];
    } else if ([[segue identifier] isEqualToString:@"playerToBaseballCard"]) 
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    else if ([[segue identifier] isEqualToString:@"playerToCareer2"])
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    else if ([[segue identifier] isEqualToString:@"playerYearsToTransactions"])
        [[segue destinationViewController] setValue:_player forKey:@"player"];
    else if ([[segue identifier] isEqualToString:@"playerYearsToWeb"]) {
        NSURL *externalURL = [_player.master urlOnWebSite: ((UIAlertAction *)sender).title];
        [[segue destinationViewController] setValue:externalURL forKey:@"statsURL"];
    }
}

#pragma mark Rotate to Baseball Card View methods

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

-(void)viewWillAppear:(BOOL)animated
{
    self.title = _originalTitle;
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
	} /*
    else {
        if ([TransactionsTVC anyTransactionsForPlayer:_player]) {
            // Cool effect of Transactions button appearing if there are transactions.
            //_transactionsButtonItem.title = @"Transactions";
            //_transactionsButtonItem.enabled = TRUE;
        }
    } */
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	thisViewHasAppeared = FALSE;
    [self disableRotateToBaseballCard];
	[super viewDidDisappear:animated];
}

// ------------------------------------------------------
//	orientationChanged:
//  Handler for the UIDeviceOrientationDidChangeNotification.
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
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&  isShowingLandscapeView)
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

#pragma mark More button

- (IBAction)moreButtonTapped:(id)sender {
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
        [self performSegueWithIdentifier:@"playerYearsToTransactions" sender:self];
    }];
    [alertController addAction:transAction];
    UIAlertAction *careerAction = [UIAlertAction actionWithTitle:@"Career" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"playerToCareer2" sender:self];
    }];
    [alertController addAction:careerAction];
    UIAlertAction *wikipediaAction = [UIAlertAction actionWithTitle:@"Wikipedia" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"playerYearsToWeb" sender:action];
    }];
    [alertController addAction:wikipediaAction];
    UIAlertAction *baseballReferenceAction = [UIAlertAction actionWithTitle:@"Baseball-Reference.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"playerYearsToWeb" sender:action];
    }];
    [alertController addAction:baseballReferenceAction];

    UIAlertAction *baseballAlmanacAction = [UIAlertAction actionWithTitle:@"BaseballAlmanac.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"playerYearsToWeb" sender:action];
    }];
    [alertController addAction:baseballAlmanacAction];
    if (_player.master.retroID && ![_player.master.retroID isEqualToString:@" "]) {
        UIAlertAction *retrosheetAction = [UIAlertAction actionWithTitle:@"Retrosheet.org" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"playerYearsToWeb" sender:action];
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

