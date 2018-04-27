//
//  Batting.h
//  BaseballQuery
//
//  Created by Mark Knopper on 1/30/15.
//  Copyright (c) 2015 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Teams;

@interface Batting : NSManagedObject

@property (nonatomic, retain) NSNumber * aB;
@property (nonatomic, retain) NSNumber * bA;
@property (nonatomic, retain) NSNumber * bB;
@property (nonatomic, retain) NSNumber * cS;
@property (nonatomic, retain) NSNumber * doubles_2B;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * g_batting;
@property (nonatomic, retain) NSNumber * g_old;
@property (nonatomic, retain) NSNumber * gIDP;
@property (nonatomic, retain) NSNumber * h;
@property (nonatomic, retain) NSNumber * hBP;
@property (nonatomic, retain) NSNumber * hR;
@property (nonatomic, retain) NSNumber * iBB;
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSNumber * oBP;
@property (nonatomic, retain) NSNumber * oPS;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * r;
@property (nonatomic, retain) NSNumber * rBI;
@property (nonatomic, retain) NSNumber * sB;
@property (nonatomic, retain) NSNumber * sF;
@property (nonatomic, retain) NSNumber * sH;
@property (nonatomic, retain) NSNumber * sLG;
@property (nonatomic, retain) NSNumber * sO;
@property (nonatomic, retain) NSNumber * stint;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSNumber * triples_3B;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) Master *player;
@property (nonatomic, retain) Teams *teamSeason;

@end
