//
//  StatsDisplayFactory.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/31/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//
//
//  The StatsDisplayFactory creates a pre-packaged set of
//  StatsDescriptors grouped together in a StatsDisplay.
//  The StatsDisplay defines the stat keys, labels, and formatted
//  output.    Each of the types in the enum StatsDisplayStatType
//  represents a package of stats to be displayed together.

#import "StatsDisplay.h"
#import "StatsDisplayStatType.h"
#import "StatDescriptor.h"
#import "BQPlayer.h"

@class StatsDisplay; // for compiler, for some reason.

@interface StatsDisplayFactory : NSObject

+(StatsDisplay *)createStatsDisplayWithType:(StatsDisplayStatType)statsDisplayType player:(BQPlayer *)player;

@end
