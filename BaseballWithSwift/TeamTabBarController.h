//
//  TeamTabBarController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/10/09.
//  Recreated by Matthew Jones in May, 2010
//  Copyright 2009-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@class Teams;

@interface TeamTabBarController : UITabBarController

@property (nonatomic, strong) Teams *team;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void) changeToTeam:(Teams *)aTeam;

@end
