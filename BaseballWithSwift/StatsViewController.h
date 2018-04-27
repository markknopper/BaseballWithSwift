//
//  StatsViewController.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/9/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
//  Need to generalize for the Teams stats display.   For the most
//  part all of the Team stats come directly from the Teams object,
//  but the player stats come from the statKind sections 
//

@import UIKit;
#import "StatsDisplayFactory.h"
#import "BQPlayer.h"
#import "StatsDisplayStatType.h"

@interface StatsViewController : UITableViewController

	//
	// statsSources has multiple elements for a player with multiple stints,
	// and if the player plays multiple fielding positions, for example.
	// statsSources only ever has a single (Teams *) element if the StatsViewController is being used
	// to look at team stats
// Ie. statsSources is an array of either Batting, Pitching, Fielding, Managing records or a personal array of strings. For career fielding it is an array of dictionaries one per position played. StatsSources is a parallel array to displaySections.
	//
@property (nonatomic, strong) NSArray *statsSources;
// displaySections is array of statsDisplay's, each with its own statsDescriptors describing the rows for that section
@property (strong, nonatomic) NSMutableArray *displaySections;
@property (nonatomic, assign) StatsDisplayStatType statsDisplayStatType;
@property (nonatomic, strong) BQPlayer *player;

@end
