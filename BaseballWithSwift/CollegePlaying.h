//
//  CollegePlaying.h
//  BaseballQuery
//
//  Created by Mark Knopper on 1/30/15.
//  Copyright (c) 2015 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master;

@interface CollegePlaying : NSManagedObject

@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSString * schoolID;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) NSManagedObject *school;

@end
