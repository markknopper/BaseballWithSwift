//
//  Teams.h
//  BaseballQuery
//
//  Created by Mark Knopper on 8/1/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AllstarFull, Batting, Fielding, Managers, Pitching, Salaries, TeamsFranchises;

@interface Teams : NSManagedObject

@property (nonatomic, retain) NSNumber * aB;
@property (nonatomic, retain) NSNumber * attendance;
@property (nonatomic, retain) NSNumber * bA;
@property (nonatomic, retain) NSNumber * bB;
@property (nonatomic, retain) NSNumber * bBA;
@property (nonatomic, retain) NSNumber * bPF;
@property (nonatomic, retain) NSNumber * cG;
@property (nonatomic, retain) NSNumber * cS;
@property (nonatomic, retain) NSString * divID;
@property (nonatomic, retain) NSNumber * divWin;
@property (nonatomic, retain) NSNumber * doubles_2B;
@property (nonatomic, retain) NSNumber * dP;
@property (nonatomic, retain) NSNumber * e;
@property (nonatomic, retain) NSNumber * eR;
@property (nonatomic, retain) NSNumber * eRA;
@property (nonatomic, retain) NSNumber * fPct;
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
@property (nonatomic, retain) NSString * lgID;
@property (nonatomic, retain) NSNumber * lgWin;
@property (nonatomic, retain) NSString * logoFile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * oBP;
@property (nonatomic, retain) NSNumber * oPS;
@property (nonatomic, retain) NSString * park;
@property (nonatomic, retain) NSNumber * pPF;
@property (nonatomic, retain) NSNumber * r;
@property (nonatomic, retain) NSNumber * rA;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * sB;
@property (nonatomic, retain) NSNumber * sF;
@property (nonatomic, retain) NSNumber * sHO;
@property (nonatomic, retain) NSNumber * sLG;
@property (nonatomic, retain) NSNumber * sO;
@property (nonatomic, retain) NSNumber * sOA;
@property (nonatomic, retain) NSNumber * sV;
@property (nonatomic, retain) NSString * teamID;
@property (nonatomic, retain) NSString * teamIDBR;
@property (nonatomic, retain) NSString * teamIDlahman45;
@property (nonatomic, retain) NSString * teamIDretro;
@property (nonatomic, retain) NSNumber * triples_3B;
@property (nonatomic, retain) NSNumber * w;
@property (nonatomic, retain) NSNumber * wCWin;
@property (nonatomic, retain) NSNumber * wSWin;
@property (nonatomic, retain) NSNumber * yearID;
@property (nonatomic, retain) NSSet *allStars;
@property (nonatomic, retain) NSSet *batters;
@property (nonatomic, retain) NSSet *battingPost;
@property (nonatomic, retain) NSSet *fielders;
@property (nonatomic, retain) NSSet *fieldingPost;
@property (nonatomic, retain) TeamsFranchises *franchise;
@property (nonatomic, retain) NSSet *managerHalves;
@property (nonatomic, retain) NSSet *managers;
@property (nonatomic, retain) NSSet *pitchers;
@property (nonatomic, retain) NSSet *pitchingPost;
@property (nonatomic, retain) NSSet *postSeasonSeriesLosses;
@property (nonatomic, retain) NSManagedObject *postSeasonSeriesWins;
@property (nonatomic, retain) NSSet *salaries;
@property (nonatomic, retain) NSSet *teamHalves;
@end

@interface Teams (CoreDataGeneratedAccessors)

- (void)addAllStarsObject:(AllstarFull *)value;
- (void)removeAllStarsObject:(AllstarFull *)value;
- (void)addAllStars:(NSSet *)values;
- (void)removeAllStars:(NSSet *)values;

- (void)addBattersObject:(Batting *)value;
- (void)removeBattersObject:(Batting *)value;
- (void)addBatters:(NSSet *)values;
- (void)removeBatters:(NSSet *)values;

- (void)addBattingPostObject:(NSManagedObject *)value;
- (void)removeBattingPostObject:(NSManagedObject *)value;
- (void)addBattingPost:(NSSet *)values;
- (void)removeBattingPost:(NSSet *)values;

- (void)addFieldersObject:(Fielding *)value;
- (void)removeFieldersObject:(Fielding *)value;
- (void)addFielders:(NSSet *)values;
- (void)removeFielders:(NSSet *)values;

- (void)addFieldingPostObject:(NSManagedObject *)value;
- (void)removeFieldingPostObject:(NSManagedObject *)value;
- (void)addFieldingPost:(NSSet *)values;
- (void)removeFieldingPost:(NSSet *)values;

- (void)addManagerHalvesObject:(NSManagedObject *)value;
- (void)removeManagerHalvesObject:(NSManagedObject *)value;
- (void)addManagerHalves:(NSSet *)values;
- (void)removeManagerHalves:(NSSet *)values;

- (void)addManagersObject:(Managers *)value;
- (void)removeManagersObject:(Managers *)value;
- (void)addManagers:(NSSet *)values;
- (void)removeManagers:(NSSet *)values;

- (void)addPitchersObject:(Pitching *)value;
- (void)removePitchersObject:(Pitching *)value;
- (void)addPitchers:(NSSet *)values;
- (void)removePitchers:(NSSet *)values;

- (void)addPitchingPostObject:(NSManagedObject *)value;
- (void)removePitchingPostObject:(NSManagedObject *)value;
- (void)addPitchingPost:(NSSet *)values;
- (void)removePitchingPost:(NSSet *)values;

- (void)addPostSeasonSeriesLossesObject:(NSManagedObject *)value;
- (void)removePostSeasonSeriesLossesObject:(NSManagedObject *)value;
- (void)addPostSeasonSeriesLosses:(NSSet *)values;
- (void)removePostSeasonSeriesLosses:(NSSet *)values;

- (void)addSalariesObject:(Salaries *)value;
- (void)removeSalariesObject:(Salaries *)value;
- (void)addSalaries:(NSSet *)values;
- (void)removeSalaries:(NSSet *)values;

- (void)addTeamHalvesObject:(NSManagedObject *)value;
- (void)removeTeamHalvesObject:(NSManagedObject *)value;
- (void)addTeamHalves:(NSSet *)values;
- (void)removeTeamHalves:(NSSet *)values;

@end
