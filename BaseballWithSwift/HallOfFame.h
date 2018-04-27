//
//  HallOfFame.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master;

@interface HallOfFame : NSManagedObject

@property (nonatomic, retain) NSNumber * ballots;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * inducted;
@property (nonatomic, retain) NSNumber * needed;
@property (nonatomic, retain) NSString * needed_note;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSString * votedBy;
@property (nonatomic, retain) NSNumber * votes;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) Master *player;

@end
