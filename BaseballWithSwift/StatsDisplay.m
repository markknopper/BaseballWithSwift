//
//  StatsDisplay.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/31/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
#import "StatsDisplay.h"
#import "Batting+Query.h"
#import "Fielding+Query.h"
#import "Managers+Query.h"
#import "Teams+Query.h"

@implementation StatsDisplay

// This is called a lot of times from the switch/case in StatsDisplayFactory.
-(id)initWithStatsDisplayStatType:(StatsDisplayStatType)stat_type descriptors:(id)firstDescriptor, ... {
	if ((self = [super init])) {
		NSMutableArray *statDescriptors = [[NSMutableArray alloc] init];
		self.statDescriptors = statDescriptors;
		id eachDescriptor;
		va_list argumentList;
		if (firstDescriptor) { // so we'll handle it separately.
			[_statDescriptors addObject:firstDescriptor];
			va_start(argumentList, firstDescriptor); // Start scanning for arguments after firstObject.
			while ((eachDescriptor = va_arg(argumentList, id)))	// As many times as we can get an argument of type "id"
				[_statDescriptors addObject:eachDescriptor]; // that isn't nil, add it to self's contents.
			va_end(argumentList);
		}	
        self.type = stat_type;
	}
	return self;
}

@end
