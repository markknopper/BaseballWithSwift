//
//  FranchiseTotals.h
//  BaseballQuery
//
//  Created by Mark Knopper on 7/1/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamsFranchises;

@interface FranchiseTotals : NSManagedObject

@property (nonatomic, retain) NSNumber * aB;
@property (nonatomic, retain) NSNumber * attendance;
@property (nonatomic, retain) NSNumber * bA;
@property (nonatomic, retain) NSNumber * bB;
@property (nonatomic, retain) NSNumber * bBA;
@property (nonatomic, retain) NSNumber * cG;
@property (nonatomic, retain) NSNumber * cS;
@property (nonatomic, retain) NSNumber * doubles_2B;
@property (nonatomic, retain) NSNumber * dP;
@property (nonatomic, retain) NSNumber * e;
@property (nonatomic, retain) NSNumber * eR;
@property (nonatomic, retain) NSNumber * eRA;
@property (nonatomic, retain) NSNumber * fP;
@property (nonatomic, retain) NSString * franchID;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSNumber * gHome;
@property (nonatomic, retain) NSNumber * h;
@property (nonatomic, retain) NSNumber * hA;
@property (nonatomic, retain) NSNumber * hBP;
@property (nonatomic, retain) NSNumber * hR;
@property (nonatomic, retain) NSNumber * hRA;
@property (nonatomic, retain) NSNumber * iPOuts;
@property (nonatomic, retain) NSNumber * l;
@property (nonatomic, retain) NSNumber * oBP;
@property (nonatomic, retain) NSNumber * r;
@property (nonatomic, retain) NSNumber * rA;
@property (nonatomic, retain) NSNumber * sB;
@property (nonatomic, retain) NSNumber * sF;
@property (nonatomic, retain) NSNumber * sHO;
@property (nonatomic, retain) NSNumber * sLG;
@property (nonatomic, retain) NSNumber * sO;
@property (nonatomic, retain) NSNumber * sOA;
@property (nonatomic, retain) NSNumber * sV;
@property (nonatomic, retain) NSNumber * triples_3B;
@property (nonatomic, retain) NSNumber * w;
@property (nonatomic, retain) TeamsFranchises *teamsFranchises;

@end
