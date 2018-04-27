//
//  TeamTabBarController.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/10/09.
//  Revised by Matthew Jones in March - June of 2010
//  Copyright 2009-2014 Bulbous Ventures LLC. All rights reserved.
//

/* Team stats */

#import "TeamTabBarController.h"
#import "StatsViewController.h"

@implementation TeamTabBarController

//
//  If the team changes, it will be necessary to change the parent "Years" controller so that that
//  the back button is correct.
//
//*** This change to team may be stupid, and we should just do a push segue for anyone who wants to do this.
- (void) changeToTeam:(Teams *)aTeam {
	self.team = aTeam;
    [self setupViewControllersForTeam];
    [[(UITableViewController *)self.selectedViewController tableView] reloadData];
}

-(void)setupViewControllersForTeam
{
    self.title = _team.name;
    [self.viewControllers makeObjectsPerformSelector:@selector(setStatsSources:) withObject:@[self.team]];
}

- (void)viewDidLoad
{
    [self setupViewControllersForTeam];
    [super viewDidLoad];
}

@end

