//
//  RootTabBarController.h
//  BaseballQuery
//
//  Created by Mark Knopper on 10/31/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

/* Implement this guy's suggestion:
 
 When you first open the App, the 3 main categories now are, All, Current, and Years. I believe it would be better if it included these instead on the first screen: Teams, Players, World Series, Years, and All-Time
 
 - If you click on Teams, you will see an option for All or Current, kind of like what you currently have on the main screen.
 - If you click on Players, you will see an alphabetical list of all the players.
 - If you click on World Series, you will see a list of all the winners.
 - If you click on All-Time, you will see various all-time stats like the Top 20 in Home Runs, etc.
 - If you click on Years, you will see what you currently show for Years.
 
 When you click on Search, you see, Team, Player, and Year. This is currently the only way to find a player, unless you find them within a particular Team. With the above structure, you could find a player without searching.

 */

#import <UIKit/UIKit.h>
#import "QueryBuilderViewController.h"

@interface RootTabBarController : UITabBarController
{
	NSNumber *indexToSelect;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(void)resetControllers;

@end
