//
//  Master.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/9/15.
//  Copyright (c) 2015-2018 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AllstarFull, Batting, BattingTotals, Fielding, FieldingTotals, ManagerTotals, Managers, Pitching, PitchingTotals, Salaries;


@interface Master : NSManagedObject

@property (nonatomic, retain) NSString * bats;
@property (nonatomic, retain) NSString * bbrefID;
@property (nonatomic, retain) NSString * birthCity;
@property (nonatomic, retain) NSString * birthCountry;
@property (nonatomic, retain) NSNumber * birthDay;
@property (nonatomic, retain) NSNumber * birthMonth;
@property (nonatomic, retain) NSString * birthState;
@property (nonatomic, retain) NSNumber * birthYear;
@property (nonatomic, retain) NSString * deathCity;
@property (nonatomic, retain) NSString * deathCountry;
@property (nonatomic, retain) NSNumber * deathDay;
@property (nonatomic, retain) NSNumber * deathMonth;
@property (nonatomic, retain) NSString * deathState;
@property (nonatomic, retain) NSNumber * deathYear;
@property (nonatomic, retain) NSString * debut;
@property (nonatomic, retain) NSString * finalGame;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * nameFirst;
@property (nonatomic, retain) NSString * nameGiven;
@property (nonatomic, retain) NSString * nameLast;
@property (nonatomic, retain) NSNumber * playedInLatestYear;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSString * retroID;
@property (nonatomic, retain) NSNumber * startedInLatestYear;
@property (nonatomic, retain) NSString * throws;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *allStarGames;
@property (nonatomic, retain) NSSet *appearances;
@property (nonatomic, retain) NSSet *awards;
@property (nonatomic, retain) NSSet *awardShares;
@property (nonatomic, retain) NSSet *battingPostSeasons;
@property (nonatomic, retain) NSSet *battingSeasons;
@property (nonatomic, retain) BattingTotals *battingTotals;
@property (nonatomic, retain) NSSet *fieldingOFSeasons;
@property (nonatomic, retain) NSSet *fieldingPostSeasons;
@property (nonatomic, retain) NSSet *fieldingRecords;
@property (nonatomic, retain) NSSet *fieldingTotals;
@property (nonatomic, retain) NSSet *hallOfFameSeasons;
@property (nonatomic, retain) NSSet *managerSeasons;
@property (nonatomic, retain) ManagerTotals *managerTotals;
@property (nonatomic, retain) NSSet *pitchingPostSeasons;
@property (nonatomic, retain) NSSet *pitchingSeasons;
@property (nonatomic, retain) PitchingTotals *pitchingTotals;
@property (nonatomic, retain) NSSet *salarySeasons;
@property (nonatomic, retain) NSSet *schools;
@end

@interface Master (CoreDataGeneratedAccessors)

- (void)addAllStarGamesObject:(AllstarFull *)value;
- (void)removeAllStarGamesObject:(AllstarFull *)value;
- (void)addAllStarGames:(NSSet *)values;
- (void)removeAllStarGames:(NSSet *)values;

- (void)addAppearancesObject:(NSManagedObject *)value;
- (void)removeAppearancesObject:(NSManagedObject *)value;
- (void)addAppearances:(NSSet *)values;
- (void)removeAppearances:(NSSet *)values;

- (void)addAwardsObject:(NSManagedObject *)value;
- (void)removeAwardsObject:(NSManagedObject *)value;
- (void)addAwards:(NSSet *)values;
- (void)removeAwards:(NSSet *)values;

- (void)addAwardSharesObject:(NSManagedObject *)value;
- (void)removeAwardSharesObject:(NSManagedObject *)value;
- (void)addAwardShares:(NSSet *)values;
- (void)removeAwardShares:(NSSet *)values;

- (void)addBattingPostSeasonsObject:(NSManagedObject *)value;
- (void)removeBattingPostSeasonsObject:(NSManagedObject *)value;
- (void)addBattingPostSeasons:(NSSet *)values;
- (void)removeBattingPostSeasons:(NSSet *)values;

- (void)addBattingSeasonsObject:(Batting *)value;
- (void)removeBattingSeasonsObject:(Batting *)value;
- (void)addBattingSeasons:(NSSet *)values;
- (void)removeBattingSeasons:(NSSet *)values;

- (void)addFieldingOFSeasonsObject:(NSManagedObject *)value;
- (void)removeFieldingOFSeasonsObject:(NSManagedObject *)value;
- (void)addFieldingOFSeasons:(NSSet *)values;
- (void)removeFieldingOFSeasons:(NSSet *)values;

- (void)addFieldingPostSeasonsObject:(NSManagedObject *)value;
- (void)removeFieldingPostSeasonsObject:(NSManagedObject *)value;
- (void)addFieldingPostSeasons:(NSSet *)values;
- (void)removeFieldingPostSeasons:(NSSet *)values;

- (void)addFieldingRecordsObject:(Fielding *)value;
- (void)removeFieldingRecordsObject:(Fielding *)value;
- (void)addFieldingRecords:(NSSet *)values;
- (void)removeFieldingRecords:(NSSet *)values;

- (void)addFieldingTotalsObject:(FieldingTotals *)value;
- (void)removeFieldingTotalsObject:(FieldingTotals *)value;
- (void)addFieldingTotals:(NSSet *)values;
- (void)removeFieldingTotals:(NSSet *)values;

- (void)addHallOfFameSeasonsObject:(NSManagedObject *)value;
- (void)removeHallOfFameSeasonsObject:(NSManagedObject *)value;
- (void)addHallOfFameSeasons:(NSSet *)values;
- (void)removeHallOfFameSeasons:(NSSet *)values;

- (void)addManagerSeasonsObject:(Managers *)value;
- (void)removeManagerSeasonsObject:(Managers *)value;
- (void)addManagerSeasons:(NSSet *)values;
- (void)removeManagerSeasons:(NSSet *)values;

- (void)addPitchingPostSeasonsObject:(NSManagedObject *)value;
- (void)removePitchingPostSeasonsObject:(NSManagedObject *)value;
- (void)addPitchingPostSeasons:(NSSet *)values;
- (void)removePitchingPostSeasons:(NSSet *)values;

- (void)addPitchingSeasonsObject:(Pitching *)value;
- (void)removePitchingSeasonsObject:(Pitching *)value;
- (void)addPitchingSeasons:(NSSet *)values;
- (void)removePitchingSeasons:(NSSet *)values;

- (void)addSalarySeasonsObject:(Salaries *)value;
- (void)removeSalarySeasonsObject:(Salaries *)value;
- (void)addSalarySeasons:(NSSet *)values;
- (void)removeSalarySeasons:(NSSet *)values;

- (void)addSchoolsObject:(NSManagedObject *)value;
- (void)removeSchoolsObject:(NSManagedObject *)value;
- (void)addSchools:(NSSet *)values;
- (void)removeSchools:(NSSet *)values;

@end
