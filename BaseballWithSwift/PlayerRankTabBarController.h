//
//  PlayerRankTabBarController.h
//  BaseballQuery
//
//  Created by Matthew Jones on 6/5/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "StatsDisplay.h"

//
//  All state for the RankTabBarController is pass-through
//  stat.    Just used to initialize the various views.
//
@interface PlayerRankTabBarController : UITabBarController

@property (nonatomic, strong) NSNumber *yearID;
@property (nonatomic, strong) StatsDisplay *statsDisplay;
@property (nonatomic, strong) NSNumber * descriptorIndex;
@property (nonatomic, strong) id toSelect; // id of statSource item to select

@end
