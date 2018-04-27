//
//  NewBaseballCardViewController.m
//  BaseballQuery
//
//  Created by Mark Knopper on 12/6/13.
//  Copyright (c) 2013-2017 Bulbous Ventures LLC. All rights reserved.
//

#import "BaseballCardViewController.h"

@implementation BaseballCardViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    // Error check: if we are about to appear but device is rotated in portrait, don't allow it.
    UIDeviceOrientation ourOrientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsPortrait(ourOrientation)) {
		// WTF the thing is continuing to try to rotate.
		[self dismissViewControllerAnimated:YES completion:NULL];
    }
    // 'thisViewHasAppeared' seems to be absolutely necessary.
    thisViewHasAppeared = TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Formatting done in BQPlayer.
    self.baseballCardDictionary =  [_player baseballCardText];
    //baseballCardSectionLines returns an NSDictionary with keys
    // titles - array of titles for each section
    // lines - arrays of lines for each section
    _horizontalScroller.translatesAutoresizingMaskIntoConstraints = NO;
    // This magic line allows horizontal scrolling to wide table.
    _horizontalScroller.contentSize = _wideTableView.frame.size;
    _wideTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.title = [self.player fullName];
    self.originalTitle = self.title;
    thisViewHasAppeared = FALSE;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_baseballCardDictionary valueForKey:@"lines"] count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_baseballCardDictionary valueForKey:@"lines"] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BaseballCardLine";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseballCardLine"];
    }
    cell.textLabel.text = [[[_baseballCardDictionary valueForKey:@"lines"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section>0)  // years section with columns.
        cell.textLabel.font = [UIFont fontWithName:@"Courier-Bold" size:12];
	else // personal section, just freeform.
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_baseballCardDictionary valueForKey:@"titles"] objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (CGFloat)30; // Trim header space a bit.
}

- (void)orientationChanged:(NSNotification *)notification
{
    if (thisViewHasAppeared==TRUE)
		[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidDisappear:(BOOL)animated
{
	thisViewHasAppeared = FALSE;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[super viewDidDisappear:animated];
}

@end
