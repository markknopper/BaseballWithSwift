//
//  Fielding.h
//  BaseballQuery
//
//  Created by Mark Knopper on 7/1/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Teams;

@interface Fielding : NSManagedObject

@property (nonatomic, retain) NSNumber * a;
@property (nonatomic, retain) NSNumber * cS;
@property (nonatomic, retain) NSNumber * dP;
@property (nonatomic, retain) NSNumber * e;
@property (nonatomic, retain) NSNumber * fPct;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * gS;
@property (nonatomic, retain) NSNumber * innOuts;
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSNumber * pB;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * pO;
@property (nonatomic, retain) NSString * pos;
@property (nonatomic, retain) NSNumber * sB;
@property (nonatomic, retain) NSNumber * stint;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSNumber * wP;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) NSNumber * zR;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) Teams *teamSeason;

@end
