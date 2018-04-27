//
//  Schools.h
//  BaseballQuery
//
//  Created by Mark Knopper on 1/30/15.
//  Copyright (c) 2015 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CollegePlaying;

@interface Schools : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name_full;
@property (nonatomic, retain) NSString * schoolID;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSSet *players;
@end

@interface Schools (CoreDataGeneratedAccessors)

- (void)addPlayersObject:(CollegePlaying *)value;
- (void)removePlayersObject:(CollegePlaying *)value;
- (void)addPlayers:(NSSet *)values;
- (void)removePlayers:(NSSet *)values;

@end
