//
//  ManagerTotals.h
//  BaseballQuery
//
//  Created by Mark Knopper on 5/29/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master;

@interface ManagerTotals : NSManagedObject

@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * l;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * w;
@property (nonatomic, retain) Master *player;

@end
