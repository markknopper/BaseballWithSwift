//
//  TeamRankTabBarController.h
//  BaseballQuery
//
//  Created by Matthew Jones on 6/5/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "StatsDisplay.h"

//
//  All state for the RankTabBarController is pass-through
//  stat. Just used to initialize the various views.
//
@interface TeamRankTabBarController : UITabBarController
{
	NSString *displayKey; // cache for convenience
}

@property (nonatomic) NSNumber *yearID;
@property (nonatomic) StatsDisplay *statsDisplay;
@property (nonatomic, strong) NSNumber *descriptorIndex;
@property (nonatomic) id toSelect; // id of statSource item to select

@end
