//
//  FieldingTotals.h
//  BaseballQuery
//
//  Created by Mark Knopper on 5/29/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master;

@interface FieldingTotals : NSManagedObject

@property (nonatomic, retain) NSNumber * a;
@property (nonatomic, retain) NSNumber * cS;
@property (nonatomic, retain) NSNumber * dP;
@property (nonatomic, retain) NSNumber * e;
@property (nonatomic, retain) NSNumber * fPct;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * gS;
@property (nonatomic, retain) NSNumber * innOuts;
@property (nonatomic, retain) NSNumber * pB;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * pO;
@property (nonatomic, retain) NSNumber * sB;
@property (nonatomic, retain) NSNumber * wP;
@property (nonatomic, retain) NSNumber * zR;
@property (nonatomic, retain) Master *player;

@end
