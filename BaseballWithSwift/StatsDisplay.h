//
//  StatsDisplay.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/31/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//
//  StatsDisplay contains a collection of StatDescriptors, as well
//  as some attributes that can be used to determine how to label
//  titles and sections.
//
//  The array of descriptors is mutable, so that it can be "trimmed" from
//  contexts where a particular Stat is not available.    This avoids
//  empty rows and such.

#import "StatDescriptor.h"
#import "StatsDisplayFactory.h"
#import "StatsDisplayStatType.h"

@interface StatsDisplay : NSObject

@property (nonatomic) StatsDisplayStatType type;
@property (nonatomic) NSMutableArray *statDescriptors;

-(id)initWithStatsDisplayStatType:(StatsDisplayStatType)stat_type descriptors:(id)firstDescriptor, ... ;

@end
