//
//  Managers.h
//  BaseballQuery
//
//  Created by Mark Knopper on 7/1/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Teams;

@interface Managers : NSManagedObject

@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * inseason;
@property (nonatomic, retain) NSNumber * l;
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * plyrMgr;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSNumber * w;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) NSSet *awards;
@property (nonatomic, retain) NSSet *awardsShares;
@property (nonatomic, retain) NSSet *managerHalves;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) Teams *teamSeason;
@end

@interface Managers (CoreDataGeneratedAccessors)

- (void)addAwardsObject:(NSManagedObject *)value;
- (void)removeAwardsObject:(NSManagedObject *)value;
- (void)addAwards:(NSSet *)values;
- (void)removeAwards:(NSSet *)values;

- (void)addAwardsSharesObject:(NSManagedObject *)value;
- (void)removeAwardsSharesObject:(NSManagedObject *)value;
- (void)addAwardsShares:(NSSet *)values;
- (void)removeAwardsShares:(NSSet *)values;

- (void)addManagerHalvesObject:(NSManagedObject *)value;
- (void)removeManagerHalvesObject:(NSManagedObject *)value;
- (void)addManagerHalves:(NSSet *)values;
- (void)removeManagerHalves:(NSSet *)values;

@end
