//
//  BQPlayer.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 7/20/09.
//  Copyright 2009-2017 Bulbous Ventures LLC. All rights reserved.
//

#import "Master+Query.h"
#import "Teams+Query.h"
#import "StatsDisplayStatType.h"

@class PitchingTotals;

@interface BQPlayer : NSObject

@property (nonatomic) Master *master;
// We will have team, or year, or neither, but not both.
@property (nonatomic) Teams *team; // If team, get stats for this player this team this year.
@property (nonatomic) NSNumber *year; // If year, get stats for player for all teams this year.

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (unsafe_unretained, nonatomic, readonly) NSString *fullName;
@property (unsafe_unretained, nonatomic, readonly) NSString *nameFirst;
@property (unsafe_unretained, nonatomic, readonly) NSString *nameLast;

@property (nonatomic, readonly) BOOL isBatter;
@property (nonatomic, readonly) BOOL isPitcher;
@property (nonatomic, readonly) BOOL isManager;
@property (nonatomic, readonly) BOOL hasAtBats;
@property (nonatomic, readonly) BOOL hasPitched;
@property (nonatomic, readonly) BOOL hasFielded;

@property (unsafe_unretained, nonatomic, readonly) NSString *teamName;
@property (nonatomic, strong) NSArray *batting;
@property (nonatomic, strong) NSArray *fielding;
@property (nonatomic, strong) NSArray *pitching;
@property (nonatomic, strong) NSArray *managing;
@property (nonatomic, strong) NSMutableDictionary *statsCache;

//
//  Init player for a team roster
//
-(id)initWithPlayer:(Master *)aPlayer teamSeason:(Teams *)teamSeason;
-(id)initWithPlayer:(Master *)aPlayer yearID:(NSNumber *)yearID;
-(id)initWithPlayer:(Master *)aPlayer teamSeason:(Teams *)teamSeason yearID:(NSNumber *)aYearID;

-(NSMutableArray *)personalStats;
-(void)zeroOutPlayer;
-(NSString *)debutDate;
-(NSString *)finalDate;
-(NSString *)displaySalary;
-(NSDictionary *)baseballCardText;

-(BOOL) hasAtBats;
-(NSArray *)statSourcesForStatType:(StatsDisplayStatType)stat_type;
-(NSArray *)postSeasonStatSourcesForStatType:(StatsDisplayStatType)stat_type;
-(BOOL)postSeasonInfoAvailableForStatType:(StatsDisplayStatType)stat_type;

@end
