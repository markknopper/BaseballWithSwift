//
//  Salaries.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Teams;

@interface Salaries : NSManagedObject

@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * salary;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) Teams *teamSeason;

@end
