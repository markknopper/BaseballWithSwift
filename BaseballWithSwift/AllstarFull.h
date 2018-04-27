//
//  AllstarFull.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014-2015 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Teams;

@interface AllstarFull : NSManagedObject

@property (nonatomic, retain) NSString * gameID;
@property (nonatomic, retain) NSNumber * gameNum;
@property (nonatomic, retain) NSNumber * GP;
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * startingPos;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSString * yearID;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) Teams *team;

@end
