//
//  AwardsManagers.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Managers;

@interface AwardsManagers : NSManagedObject

@property (nonatomic, retain) NSString * awardID;
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * tie;
@property (nonatomic, retain) NSString * yearID;
@property (nonatomic, retain) Managers *manager;

@end
