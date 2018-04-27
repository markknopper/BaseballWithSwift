//
//  PlayerRankOperation.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/18/11.
//  Copyright 2011-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "StatsDisplay.h"

@interface PlayerRankOperation : NSOperation {
@private
    BOOL showAll;
}

// Results need to be properties so client task can suck them out.
@property (nonatomic, strong) NSMutableArray *section0Roster; // Arrays of objectIDs.
@property (nonatomic, strong) NSMutableArray *section1Roster;
@property (nonatomic, assign) NSInteger toSelectIndex;
@property (nonatomic, assign) NSInteger section1_rank_start;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) id statsSource;
@property (nonatomic, strong) StatsDisplay *statsDisplay;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSNumber *descriptorIndex;

-(id)initWithStatsDisplay:(StatsDisplay *)statsDisp descriptorIndex:(NSNumber *)descriptor_index showAll:(BOOL)show_all statObj:(id)ourStatObject predicate:(NSPredicate *)ourPredicate managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
