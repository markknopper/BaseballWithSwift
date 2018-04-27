//
//  SeriesPost.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Teams;

@interface SeriesPost : NSManagedObject

@property (nonatomic, retain) NSString * lgIDloser;
@property (nonatomic, retain) NSString * lgIDwinner;
@property (nonatomic, retain) NSNumber * losses;
@property (nonatomic, retain) NSString * round;
@property (nonatomic, retain) NSString * teamIDloser;
@property (nonatomic, retain) NSString * teamIDwinner;
@property (nonatomic, retain) NSNumber * ties;
@property (nonatomic, retain) NSNumber * wins;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) Teams *losingTeamSeason;
@property (nonatomic, retain) Teams *winningTeamSeason;

@end
