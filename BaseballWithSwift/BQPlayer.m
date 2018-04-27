//
//  BQPlayer.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 7/20/09.
//  Copyright 2009-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "BQPlayer.h"
#import "Managers.h"
#import "Fielding.h"
#import "AllstarFull.h"
#import "AwardsPlayers.h"
#import "AwardsManagers.h"
#import "HallOfFame.h"
#import "Salaries.h"
#import "StatsDisplay.h"
#import "StatsFormatter.h"
#import "StatDescriptor.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"
#import "Batting+Query.h"
#import "Schools.h"
#import "BattingTotals.h"
#import "FieldingTotals.h"
#import "ManagerTotals.h"
#import "ThisYear.h"
#import "CollegePlaying.h"

#import "BaseballWithSwift-Swift.h"
//
// BQPlayer - Synthesized database object, since there really isn't a concept of a 
//	"player" in the given database. A player is a union of the master data, and 
//  batting, fielding, pitching and managing. 'teamYear' may or may not be nil
//  to indicate the context of what we are doing with this player right now.
//
//  Player object really ought to be created lazily (that is, it is initially
//  only associated with a Master record, but, when it is fully displayed it will have
//  determined (by examining of the stats attached to it) the player's position,
//  and the little tidbits necessary to display the player's name in the Roster.
//  This should permit the roster to load and display quickly.   It remains to be
//  seen if it will make the scrolling unpleasant...
//
//  In the process of determining the player's position, and whether or not he is a manager,
//  the details like what stats are available are ready, which will help any view that
//  is considering displaying the players stats.
//
//
@implementation BQPlayer

-(void)zeroOutPlayer
{
	self.batting = nil;
	self.fielding = nil;
	self.pitching = nil;
	self.managing = nil;
	self.statsCache = [[NSMutableDictionary alloc] init];
}

// it's going to call method batting, fielding or pitching.
// *** do career here
-(NSArray *)statSourcesForStatType:(StatsDisplayStatType)stat_type
{
    NSInteger stat_type_type = stat_type & StatsDisplayStatTypeMask;
    NSInteger stat_type_scope = stat_type & StatsDisplayStatScopeMask;
    NSArray *sourcesToReturn = nil;
    if (stat_type_scope == StatsDisplayStatScopePlayer) {
        switch (stat_type_type) {
            case StatsDisplayStatTypeBatting:
                sourcesToReturn = [self batting];
                break;
            case StatsDisplayStatTypePitching:
                sourcesToReturn = [self pitching];
                break;
            case StatsDisplayStatTypeFielding:
                sourcesToReturn = [self fielding];
                break;
            default:
                break; // just return nil.
        }
    }
    return sourcesToReturn;
}

-(BOOL)postSeasonInfoAvailableForStatType:(StatsDisplayStatType)stat_type
{
    BOOL post_season_info_available = FALSE;
    NSArray *throwAway = [self postSeasonStatSourcesForStatType:stat_type];
    if (throwAway) {
        if ([throwAway count] > 0)
            post_season_info_available = TRUE;
    }
    return post_season_info_available;
}

-(NSArray *)postSeasonStatSourcesForStatType:(StatsDisplayStatType)stat_type
{
    NSInteger stat_type_type = stat_type & StatsDisplayStatTypeMask;
    NSInteger stat_type_scope = stat_type & StatsDisplayStatScopeMask;
    NSArray *sourcesToReturn = nil;
    if (stat_type_scope == StatsDisplayStatScopePlayer) {
        switch (stat_type_type) {
            case StatsDisplayStatTypeBatting:
                sourcesToReturn = [self.master battingPostSeasonRecordsForYear:_year];
                break;
            case StatsDisplayStatTypePitching:
                sourcesToReturn = [self.master pitchingPostSeasonRecordsForYear:_year];
                break;
            case StatsDisplayStatTypeFielding:
                sourcesToReturn = [self.master fieldingPostSeasonRecordsForYear:_year];
                break;
            default:
                break; // just return nil.
        }
    }
    // ***  ***Actually need to total these up for now? Else we will have a bunch of separate table sections. Just postseason totals for year would be great to start.
    return sourcesToReturn;
}

-(NSArray *)batting {
	if (_batting == nil) {
		if (self.year != nil) {
			_batting = [self.master battingSeasonsForYear:self.year];
		} else {
			_batting = [self.master battingSeasonsForTeamSeason:self.team];
		}
	}
	return _batting;
}

-(NSArray *)fielding {
	if (_fielding == nil) {
		if (self.year != nil) {
			_fielding = [self.master fieldingRecordsForYear:self.year];
		} else {
			_fielding = [self.master fieldingRecordsForTeamSeason:self.team];
		}
	}
	return _fielding;
}

-(NSArray *)pitching {
	if (_pitching == nil) {
		if (self.year != nil) {
			_pitching = [self.master pitchingSeasonsForYear:self.year];
		} else {
			_pitching = [self.master pitchingSeasonsForTeamSeason:self.team];
		}
	}
	return _pitching;
}

-(NSArray *)managing {
	if (_managing == nil) {
		if (self.year != nil) {
			_managing = [self.master managerSeasonsForYear:self.year];
		} else {
			_managing = [self.master managerSeasonsForTeamSeason:self.team];
		}
	}
	return _managing;
}

-(id)initWithPlayer:(Master *)aPlayer teamSeason:(Teams *)teamSeason yearID:(NSNumber *)aYearID {
    if ((self = [super init])) {
        self.master = aPlayer;
        self.team = teamSeason;
        self.year = aYearID;
    }
    return self;
}

-(id)initWithPlayer:(Master *)aPlayer teamSeason:(Teams *)teamSeason {
    self = [super init];
    if (self) {
        self.master = aPlayer;
        self.team = teamSeason;
        [self zeroOutPlayer];
    }
	return self;
}

//
//  Initialize a player with the stats for the year (possibly multi-stint)
//
-(id)initWithPlayer:(Master *)aPlayer yearID:(NSNumber *)yearID {
    self = [super init];
    if (self) {
        self.master = aPlayer;
        self.year = yearID;
		[self zeroOutPlayer];
	}
	return self;
}

//
//   Player is considered a batter, if for this collection of stats he has more games batting than pitching
//
-(BOOL) isBatter {
    NSInteger batting_games = [self.master.battingTotals.g integerValue];
    //PitchingTotals *ourPTotals = self.master.pitchingTotals;
    NSInteger pitching_games = [self.master.pitchingTotals.g integerValue];
	return (batting_games > 0) && (batting_games > pitching_games);
}

-(BOOL) hasAtBats {
    // Some ABs might be -1 so ignore them.
    BOOL i_has_at_bats = FALSE;
    NSPredicate *evalPredicate;
    if (_year != nil) {
        evalPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(battingSeasons,$b,$b.aB >0 AND $b.yearID == %@).@count > 0",_year];
    } else {
        evalPredicate = [NSPredicate predicateWithFormat:@"ANY battingSeasons.aB > 0"];
    }
    i_has_at_bats = [evalPredicate evaluateWithObject:_master];
    return i_has_at_bats;
}

-(BOOL) isPitcher {
    return ([self.pitching count] > 0);
}

//
//   Player is manager if there exist Managers stats
//
-(BOOL) isManager {
    BOOL returned_is_he = FALSE;
    if (_year != nil) {
        NSPredicate *yearPred = [NSPredicate predicateWithFormat:@"ANY yearID == %@",_year];
        returned_is_he = [yearPred evaluateWithObject:_master.managerSeasons];
    } else {
        returned_is_he = ([_master.managerSeasons count] > 0);
    }
    return returned_is_he;
}

-(BOOL) hasPitched {
    BOOL i_has_pitched = ([[_master.pitchingSeasons valueForKeyPath:@"@sum.g"] intValue] > 0);
    if (_year && i_has_pitched) {
        if (![[NSPredicate predicateWithFormat:@"ANY yearID == %@",_year] evaluateWithObject:_master.pitchingSeasons])
            i_has_pitched = FALSE;
    }
    return i_has_pitched;
}

-(BOOL) hasFielded {
    BOOL i_has_fielded = ([[_master.fieldingRecords valueForKeyPath:@"@sum.g"] intValue] > 0);
    if (_year && i_has_fielded) {
        if (![[NSPredicate predicateWithFormat:@"ANY yearID == %@",_year] evaluateWithObject:_master.fieldingRecords])
            i_has_fielded = FALSE;
    }
    return i_has_fielded;
}

-(NSManagedObjectContext *)managedObjectContext {
    return _master.managedObjectContext;
}

-(NSString *)fullName {
    return _master.fullName;
}

-(NSString *)nameLast {
    return _master.nameLast;
}

-(NSString *)nameFirst {
    return _master.nameFirst;
}

//***debutDate and finalDate should probably be moved to Master+Query or whatever it's called.
-(NSString *)debutDate
{
    // Need to normalize dates since they are in text form, in one of two formats.
	// Date formats can be: mm/dd/yyyy or yyyy-mm-dd. No particular reason why.
	NSDateFormatter *biFormatter = [[NSDateFormatter alloc] init]; 
	NSDate *formatterDate;
	NSString *debutDateToReturn = nil;
	if (self.master.debut && ![self.master.debut isEqualToString:@" "]) {
		[biFormatter setDateFormat:@"yyyy-MM-dd"];
		formatterDate = [biFormatter dateFromString:self.master.debut];
		if (!formatterDate) {
			[biFormatter setDateFormat:@"MM/dd/yyyy"]; 
			formatterDate = [biFormatter dateFromString:self.master.debut];
		}
		if (formatterDate) {
			[biFormatter setDateFormat:@"M-d-yyyy"]; // This is the standard display format.
			debutDateToReturn = [biFormatter stringFromDate:formatterDate];
		}
	}
    return debutDateToReturn;
}

-(NSString *)finalDate
{
    NSDateFormatter *biFormatter = [[NSDateFormatter alloc] init]; 
	NSString *finalDateToReturn = nil;
    if (self.master.finalGame && ![self.master.finalGame isEqualToString:@" "]) {
		[biFormatter setDateFormat:@"yyyy-MM-dd"];
		NSDate *formatterDate = [biFormatter dateFromString:self.master.finalGame];
		if (!formatterDate) {
			[biFormatter setDateFormat:@"MM/dd/yyyy"]; 
			formatterDate = [biFormatter dateFromString:self.master.finalGame];
		}
		if (formatterDate) {
			[biFormatter setDateFormat:@"M-d-yyyy"]; // This is the standard display format.
			finalDateToReturn = [biFormatter stringFromDate:formatterDate];
		}
	}
    return finalDateToReturn;
}

// what about: displayCareerSeasonsInFranchise

#pragma mark Personal Stats
#pragma mark

-(NSString *)displaySalary
{
    NSString *salaryToDisplay = nil;
    if (self.year || self.team) { // only meaningful for single year.
        NSPredicate *predicate;
        if (self.team)
            predicate = [NSPredicate predicateWithFormat:@"playerID==%@ && yearID==%@ && teamID==%@", self.master.playerID,self.team.yearID,self.team.teamID];
        else
            predicate = [NSPredicate predicateWithFormat:@"playerID==%@ && yearID==%@",self.master.playerID,self.year];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Salaries" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
        NSError *error = nil;
		NSArray *salariesRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if ([salariesRecords count] > 0) {
            // Report total salary for year, across all teams for player that year.
            NSNumber *salaryTotal = [salariesRecords valueForKeyPath:@"@sum.salary"];
			NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
			formatter.numberStyle = NSNumberFormatterCurrencyStyle;
			formatter.maximumFractionDigits = 0;
            salaryToDisplay = [formatter stringFromNumber:salaryTotal];
		}
	}
    return salaryToDisplay;
}

//
// personalStats - Return array of StatDescriptors for display in table lines.
// We only have the StatDescriptor.label with an optional value filled in. Eg. "Hall of Fame" or label=Weight value=250.
// However in the future we can put in info to allow selecting the row for drill-down on personal stats.
//
-(NSMutableArray *)personalStats
{
	if ([self.master.playerID isEqualToString:@" "] && [self.master.nameFirst isEqualToString:@" "] && [self.master.nameLast isEqualToString:@" "]) {
		return nil; // No name -> no personal stats.
    }
	NSPredicate *predicate;
	NSEntityDescription *entity;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *error = nil;
	NSMutableArray *awardsArray = [[NSMutableArray alloc] init];
    NSInteger our_year = [self.year integerValue];
	if (![self.master.playerID isEqualToString:@" "]) { // if no playerID, skip player awards.
		// See if he was in the all star game this year (or all years if career).
		entity = [NSEntityDescription entityForName:@"AllstarFull" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		if (self.team) {
			predicate = [NSPredicate predicateWithFormat:@"playerID==%@ && yearID==%@", self.master.playerID,self.team.yearID];
        } else if (self.year != nil) {
            predicate = [NSPredicate predicateWithFormat:@"playerID==%@ && yearID==%@", self.master.playerID,self.year];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"playerID==%@", self.master.playerID];
		}
		[fetchRequest setPredicate:predicate];
        // Sort by yearID, gameNum.
        NSSortDescriptor *yearSort = [[NSSortDescriptor alloc] initWithKey:@"yearID" ascending:YES];
        NSSortDescriptor *gameNumSort = [[NSSortDescriptor alloc] initWithKey:@"gameNum" ascending:YES];
        [fetchRequest setSortDescriptors:@[yearSort,gameNumSort]];
		NSArray *allStarRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (AllstarFull *anAllStarRecord in allStarRecords) {
            NSString *allstarString = [NSString stringWithFormat:@"%@ %@ All Star Team",anAllStarRecord.yearID,anAllStarRecord.lgID];
            if ([anAllStarRecord.gameNum integerValue] > 0)
                allstarString = [NSString stringWithFormat:@"%@ Game %@",allstarString,anAllStarRecord.gameNum];
            [awardsArray addObject:allstarString];
		}
		// Check for misc. awards.
		NSMutableArray *miscAwardsArray = [[NSMutableArray alloc] init];
		// Reuse same errors, predicate and fetch request.
		entity = [NSEntityDescription entityForName:@"AwardsPlayers" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:nil]; // *** should sort now rather than later
		NSArray *awardsPlayersRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		for (AwardsPlayers *anAwardsPlayersRecords in awardsPlayersRecords) {
			NSString *tieString;
			if ([anAwardsPlayersRecords.tie boolValue]==TRUE) tieString = @"(tie)";
			else tieString=@" ";
			// note that position is in notes field in lahman database.
            if (our_year==0 || our_year==[anAwardsPlayersRecords.yearID integerValue])
                [miscAwardsArray addObject:@{@"league": anAwardsPlayersRecords.lgID,@"position": anAwardsPlayersRecords.notes,@"name": anAwardsPlayersRecords.awardID,@"year": anAwardsPlayersRecords.yearID,@"tie": tieString}];
		}
		[miscAwardsArray sortUsingDescriptors:@[yearSort]]; // reuse yearSort from above.
		for (NSDictionary *anAwardDict in miscAwardsArray) {
			[awardsArray addObject:[NSString stringWithFormat:@"%@ %@ %@ %@ %@",anAwardDict[@"year"],anAwardDict[@"league"],anAwardDict[@"position"],anAwardDict[@"name"],anAwardDict[@"tie"]]];
		}
	}
	// Manager data
    if (self.master.managerSeasons) {
		NSMutableArray *managerAwardsArray = [[NSMutableArray alloc] init];
		if (self.team) { // just one year.
			// reuse predicate from above.
            predicate = [NSPredicate predicateWithFormat:@"playerID=%@ && yearID==%@",self.master.playerID,self.team.yearID];
		} else { // all years.
            predicate = [NSPredicate predicateWithFormat:@"playerID==%@",self.master.playerID];
		}
		entity = [NSEntityDescription entityForName:@"AwardsManagers" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		[fetchRequest setPredicate:predicate];
		NSArray *awardsManagersRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		for (AwardsManagers *anAwardsManagersRecord in awardsManagersRecords) {
			NSString *tieString;
			if ([anAwardsManagersRecord.tie boolValue]==TRUE) tieString = @"(tie)";
			else tieString=@" ";
			[managerAwardsArray addObject:@{@"name": anAwardsManagersRecord.awardID,@"league": anAwardsManagersRecord.lgID,@"tie": tieString,@"year": anAwardsManagersRecord.yearID}];
		}
		NSSortDescriptor *yearSort = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
		[managerAwardsArray sortUsingDescriptors:@[yearSort]];
		 // stupid how you have to do this.
		for (NSDictionary *anAwardDict in managerAwardsArray) {
			[awardsArray addObject:[NSString stringWithFormat:@"%@ %@ %@ %@",anAwardDict[@"year"],anAwardDict[@"league"],anAwardDict[@"name"],anAwardDict[@"tie"]]];
		}
	}
	// Finished with awardsArray. Now the real personal data.
	NSMutableArray *personalArray = [[NSMutableArray alloc] init];
	// Name string is name_given name_last, 
	// else if no name_given, use name_first name_last.
	NSString *wholeName, *firstNameToUse;
	if (self.master.nameGiven) {
		if ([self.master.nameGiven isEqualToString:@" "]) self.master.nameGiven=nil;
	}
	if (self.master.nameGiven) firstNameToUse = self.master.nameGiven;
	else firstNameToUse = self.master.nameFirst;
	wholeName = [NSString stringWithFormat:@"%@ %@",firstNameToUse,self.master.nameLast];
    StatDescriptor *wholeNameDescriptor = [StatDescriptor new];
    wholeNameDescriptor.label = wholeName;
    [personalArray addObject:wholeNameDescriptor];
    // Add twitter handle.
    if (self.master.twitter) {
        StatDescriptor *twitterDescriptor = [StatDescriptor new];
        twitterDescriptor.label = @"Twitter";
        // The @ is already stored in the twitter handle.
        twitterDescriptor.value = [NSString stringWithFormat:@"%@",self.master.twitter];
        [personalArray addObject:twitterDescriptor];
    }
	// Hall of fame - do in career stats only.
    if (self.year == nil) {
        predicate = [NSPredicate predicateWithFormat:@"playerID=%@ && inducted==TRUE",self.master.playerID];
		entity = [NSEntityDescription entityForName:@"HallOfFame" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		NSArray *hallOfFameRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		for (HallOfFame *aHallOfFameRecord in hallOfFameRecords) {
            StatDescriptor *hofSD = [StatDescriptor new];
            hofSD.label = [NSString stringWithFormat:@"Hall of Fame - inducted %@",aHallOfFameRecord.yearID];
            [personalArray addObject:hofSD];
		}
	}
	// Add awards list to personal stats. Should be sorted.
    [awardsArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *oneAward in awardsArray) {
        StatDescriptor *anAwardDescriptor = [StatDescriptor new];
        anAwardDescriptor.label = oneAward;
        NSRange range_of_all_star_team = [oneAward rangeOfString:@"All Star Team"];
        if (range_of_all_star_team.location != NSNotFound) {
            // Allows selecting this row later. This is kind of weird
            // since the segue belongs to some other view controller
            // (StatsViewController). But it should work.
            anAwardDescriptor.segueName = @"personalToAllStar";
        }
        [personalArray addObject:anAwardDescriptor];
    }
	// Salary data. Needs to be a year or a team. Sum up all salaries that match.
    NSString *salaryToDisplay = [self displaySalary];
    if (salaryToDisplay) {
        StatDescriptor *salaryDescriptor = [StatDescriptor new];
        salaryDescriptor.label = @"Salary";
        if (self.year != nil)
            salaryDescriptor.label = [NSString stringWithFormat:@"Salary (%@)",self.year];
        salaryDescriptor.value = salaryToDisplay;
        salaryDescriptor.ascending = NO;
        [personalArray addObject:salaryDescriptor];
    }
	if (self.master.bats && ![self.master.bats isEqualToString:@" "]) {
        StatDescriptor *batsSD = [StatDescriptor new];
        batsSD.label = @"Bats";
        batsSD.value = self.master.bats; // master.bats heh heh
        batsSD.ascending = NO;
        [personalArray addObject:batsSD];
    }
	if (self.master.throws && ![self.master.throws isEqualToString:@" "])
    {
        StatDescriptor *throwsSD = [StatDescriptor new];
        throwsSD.label = @"Throws";
        throwsSD.value = self.master.throws;
        throwsSD.ascending = NO;
        [personalArray addObject:throwsSD];
    }
	NSString *ourHeight = [self.master heightString];
	if (ourHeight) {
        StatDescriptor *heightSD = [StatDescriptor new];
        heightSD.label = @"Height";
        heightSD.value = ourHeight;
        heightSD.ascending = NO;
        [personalArray addObject:heightSD];
    }
	if ([self.master.weight integerValue]>0)
    {
        StatDescriptor *weightSD = [StatDescriptor new];
        weightSD.label = @"Weight";
        weightSD.value = [self.master.weight description];
        weightSD.ascending = NO;
        [personalArray addObject:weightSD];
    }
    // Need to look up in CollegePlaying to find out if he went to college.
    entity = [NSEntityDescription entityForName:@"CollegePlaying" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"playerID==%@",self.master.playerID];
    [fetchRequest setPredicate:predicate];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"yearID" ascending:YES]];
    NSArray *collegePlayingRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([collegePlayingRecords count] > 0) {
        // Hope there aren't multiple records for the same school.
        // But yes there are! So, sort by year. When going through them,
        // look ahead to see the contiguous end year for the same school,
        // and mark as just one entry like Ohio University 1973-1976.
        // Otherwise just return the latest school with year.
        StatDescriptor *schoolSD = [StatDescriptor new];
        schoolSD.label = @"College";
        //schoolSD.ascending = NO; // ??
        NSNumber *startingCollegeYear = nil, *endingCollegeYear = nil;
        NSString *thisSchoolName = nil;
        NSInteger i=0;
        while (i < [collegePlayingRecords count]) {
            // For each college record.
            CollegePlaying *aCollegePlayingRecord = collegePlayingRecords[i];
            // Get school name.
            NSFetchRequest *schoolNameFetch = [NSFetchRequest fetchRequestWithEntityName:@"Schools"];
            schoolNameFetch.predicate = [NSPredicate predicateWithFormat:@"schoolID==%@",aCollegePlayingRecord.schoolID];
            NSArray *schoolRecord = [self.managedObjectContext executeFetchRequest:schoolNameFetch error:&error];
            // 6-17-2016 Fix crash when schoolRecord has no members!!
            // Should check database to see why this would happen. ***
            if (schoolRecord.count > 0) {
                Schools *aSchool = schoolRecord[0];
                thisSchoolName = aSchool.name_full;
                // Assume just one year at this college.
                startingCollegeYear = aCollegePlayingRecord.yearID;
                endingCollegeYear = aCollegePlayingRecord.yearID;
                // See if we can look ahead for matching consecutive schools.
                NSInteger college_count_minus_2 = [collegePlayingRecords count]-2; //*** why is this necessary?
                if (i<=college_count_minus_2) { // If at least one more.
                    // And if current school is same as next school.
                    if ([aCollegePlayingRecord.schoolID isEqualToString:((CollegePlaying *)collegePlayingRecords[i+1]).schoolID]) {
                        endingCollegeYear = ((CollegePlaying *)collegePlayingRecords[i+1]).yearID;
                        // See how many more there are that are the same.
                        NSInteger j = i + 2; // Start after second one.
                        // Find one that is not the same.
                        while (j<[collegePlayingRecords count]) {
                            if (![((CollegePlaying *)collegePlayingRecords[j]).schoolID isEqualToString:aCollegePlayingRecord.schoolID]) {
                                // j is too far. Use 'starting' and 'ending'.
                                i = j; // Continue outer loop with j.
                                break;
                            }
                            // Advance end year.
                            endingCollegeYear = ((CollegePlaying *)collegePlayingRecords[j]).yearID;
                            j++;
                            i = j + 1; // Advance both.
                        }
                    }
                }
            }
            i++;
        }
        if (endingCollegeYear && ![endingCollegeYear isEqualToNumber:startingCollegeYear]) {
            schoolSD.value = [NSString stringWithFormat:@"%@ %@-%@",thisSchoolName,startingCollegeYear,endingCollegeYear];
        } else {
            schoolSD.value = [NSString stringWithFormat:@"%@ %@",thisSchoolName,startingCollegeYear];
        }
        [personalArray addObject:schoolSD];
    }
    NSString *ourDebutDate = [self debutDate];
    if (ourDebutDate) {
        StatDescriptor *debutSD = [StatDescriptor new];
        debutSD.label = @"Debut";
        debutSD.value = ourDebutDate;
        debutSD.ascending = NO; // do we really need to add the ascendings?
        [personalArray addObject:debutSD];
    }
    NSString *ourFinalDate = [self finalDate];
    if (ourFinalDate) {
        StatDescriptor *finalSD = [StatDescriptor new];
        finalSD.label = @"Final";
        finalSD.value = ourFinalDate;
        finalSD.ascending = NO;
        [personalArray addObject:finalSD];
    }
	// Born field.
	// 2-5-1920 Chapel Hill NC USA, or leave  out month-date or whole date or city or state or country.
	// Can be 1920 USA for example.
    // Actually it's 2 lines: birth date, then birthplace.
    // For birth date, if player is still alive, give age, like 2-5-1920 (age 97-42d)
    // Alive if no death year, or death year == -1, and birth year != -1.
    // Give age like 42-280d
	NSString *birthDateString = [self.master birthDateString];
	if (birthDateString) {
        StatDescriptor *birthSD = [StatDescriptor new];
        birthSD.label = @"Born";
        birthSD.value = birthDateString;
        birthSD.ascending = NO;
        [personalArray addObject:birthSD];
    }
	NSString *born2 = [self.master birthPlaceString];
	if (born2) {
        StatDescriptor *born2SD = [StatDescriptor new];
        born2SD.label = born2;
        [personalArray addObject:born2SD];
    }
	// Now died field.
    // Can do 2-5-1920 aged 70-320d.
	NSString *deathDate = [self.master deathDateString];
	if (deathDate) {
        StatDescriptor *deathSD = [StatDescriptor new];
        deathSD.label = @"Died";
        deathSD.value = deathDate;
        deathSD.ascending = NO;
        [personalArray addObject:deathSD];
	}
	NSString *died2 = [self.master deathPlaceString];
	if (died2) {
        StatDescriptor *died2SD = [StatDescriptor new];
        died2SD.label = died2;
        [personalArray addObject:died2SD];
	}
    return personalArray;
}

#pragma mark Baseball Card display formatter

-(NSArray *)removeLatestYearIfNotPaidUp:(NSArray *)oneOfTheStats
{
    // Time to rewrite this. Had a crash if there were 0 or 1 of these.
    // oneOfTheStats array is sorted by year. So start with a range of
    // 0..oneOfTheStats.count-1 then loop from the end and skip back until year <= latest_year_in_database.
    if (oneOfTheStats.count==0 || oneOfTheStats==nil) return oneOfTheStats;
    NSInteger reverse_pointer = oneOfTheStats.count - 1;
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    // In the loop, if the yearID>latest_year_in_database, skip backwards.
    while (reverse_pointer >= 0) { // Stop if before the beginning.
        if ([[oneOfTheStats[reverse_pointer] valueForKey:@"yearID"] compare:[NSNumber numberWithInteger:appDel.latest_year_in_database]] == NSOrderedDescending) {
            reverse_pointer--; // continue
        } else { // found one
            break;
        }
    }
    if (reverse_pointer < 0) return oneOfTheStats;
    return [oneOfTheStats subarrayWithRange:NSMakeRange(0,reverse_pointer+1)];
}

//baseballCardSectionLines returns an NSDictionary with keys
// titles - array of titles for each section
// lines - arrays of lines for each section

-(NSDictionary *)baseballCardText
{
#pragma mark - Personal section
    // First line of personal data: height, weight, bats, throws
    // Personal section appears at the top
    // Title should be Complete Major League Batting/Pitching/Managing Record
    NSMutableArray *titlesArray = [NSMutableArray new];
    NSMutableArray *lines = [NSMutableArray new];
    [titlesArray addObject:[self fullName]];
    NSMutableArray *personalLines = [NSMutableArray new];
    NSMutableString *firstPersonalLine = [[NSMutableString alloc] init];
	NSString *ourHeightString = [self.master heightString];
	if (ourHeightString)
		[firstPersonalLine appendString:[NSString stringWithFormat:@"Height: %@    ",ourHeightString]];
	// The only thing we assume is in our Player object is a Master.
	if ([self.master.weight integerValue]>0)
		[firstPersonalLine appendString:[NSString stringWithFormat:@"Weight: %@    ",[self.master.weight description]]];
	if (self.master.bats) // heh heh
		if (![self.master.bats isEqualToString:@" "])
            [firstPersonalLine appendString:[NSString stringWithFormat:@"Bats: %@    ",self.master.bats]];
	if (self.master.throws)
		if (![self.master.throws isEqualToString:@" "])
            [firstPersonalLine appendString:[NSString stringWithFormat:@"Throws: %@",self.master.throws]];
	NSString *birthDateStringToDisplay = [self.master birthDateString];
	NSString *birthPlaceStringToDisplay = [self.master birthPlaceString];
	if (birthDateStringToDisplay || birthPlaceStringToDisplay) {
		if (!birthDateStringToDisplay) birthDateStringToDisplay = @" ";
		if (!birthPlaceStringToDisplay) birthPlaceStringToDisplay = @" ";
        [firstPersonalLine appendString:[NSString stringWithFormat:@"   Born: %@  %@",birthDateStringToDisplay,birthPlaceStringToDisplay]];
        [personalLines addObject:firstPersonalLine];
	}
	NSString *deathDateString = [self.master deathDateString];
	if (deathDateString) {
		NSMutableString *personalLine = [[NSMutableString alloc] init];
		[personalLine appendString:[NSString stringWithFormat:@"Died: %@  %@",deathDateString,[self.master deathPlaceString]]];
        [personalLines addObject:personalLine];
	}
    NSMutableString *personalLine = [NSMutableString new];
    NSString *ourDebutDate = [self debutDate];
    if (ourDebutDate)
        [personalLine appendString:[NSString stringWithFormat:@"Debut Game: %@",ourDebutDate]];
    NSString *ourFinalDate = [self finalDate];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (ourFinalDate) {
        // Go to great lengths to eliminate dates in 2013 if not paid up.
        if (!(appDel.latest_year_in_database<LATEST_DATA_YEAR && [[ourFinalDate substringFromIndex:[ourFinalDate length]-4] isEqualToString:LATEST_DATA_YEAR_STRING]))
            [personalLine appendString:[NSString stringWithFormat:@"  Final Game: %@",ourFinalDate]];
    }
    [personalLines addObject:personalLine];
    personalLine = [NSMutableString new]; // No leak with ARC, right?
    NSString *hallOfFameYear = [self.master hofInductedYear];
    if (hallOfFameYear) {
        NSString *inductionString = [NSString stringWithFormat:@"Hall of Fame inducted %@",hallOfFameYear];
        [personalLine appendString:inductionString];
        [personalLines addObject:personalLine];
    }
    [lines addObject:personalLines];
    // Next section is batting or pitching.
	// Get all batting & pitching records for all years for this player.
	NSSortDescriptor *yearSort = [[NSSortDescriptor alloc] initWithKey:@"yearID" ascending:YES];
	NSSortDescriptor *stintSort = [[NSSortDescriptor alloc] initWithKey:@"stint" ascending:YES];
	NSArray *yearAndStint = @[yearSort,stintSort];
	NSArray *allBatting = [[self.master.battingSeasons allObjects] sortedArrayUsingDescriptors:yearAndStint];
    allBatting = [self removeLatestYearIfNotPaidUp:allBatting];
	NSArray *allPitching = [[self.master.pitchingSeasons allObjects] sortedArrayUsingDescriptors:yearAndStint];
    allPitching = [self removeLatestYearIfNotPaidUp:allPitching];
	// See if he was ever a manager.
	NSArray *allManagers = [[self.master.managerSeasons allObjects] sortedArrayUsingDescriptors:@[yearSort]];
    allManagers = [self removeLatestYearIfNotPaidUp:allManagers];
	// Check if AB's are greater than IPOuts to see if batter or pitcher.
	NSInteger total_ab=0, total_ipouts=0;
	for (Batting *aBattingRecord in allBatting) {
		NSInteger our_abs = [aBattingRecord.aB integerValue];
		if (our_abs > 0) total_ab += our_abs;
	}
	for (Pitching *aPitchingRecord in allPitching) {
		NSInteger our_ipouts = [aPitchingRecord.iPOuts integerValue];
		if (our_ipouts > 0) total_ipouts += our_ipouts;
	}
    NSManagedObjectContext *moc = [(BaseballQueryAppDelegate *)([UIApplication sharedApplication].delegate) managedObjectContext];
    NSString *currentTeamID;
#pragma mark Batting
	if (total_ab>0 && total_ab >= total_ipouts) { // if a batter,
        [titlesArray addObject:@"Complete Major League Batting Record"];
        NSMutableArray *battingLines = [NSMutableArray new];
        [battingLines addObject:@"Year Team Lg    G    AB    R    H   2B  3B  HR   RBI  AVG  OBP  SLG   OPS   BB    K   SB   CS  SH   SF IBB HBP GDP"];
		NSInteger total_G=0, total_AB=0, total_R=0, total_H=0, total_2B=0, total_3B=0, total_HR=0, total_RBI=0;
        NSInteger total_BB=0, total_K=0, total_SB=0, total_CS=0, total_SH=0, total_SF=0, total_IBB=0, total_HBP=0, total_GIDP=0;
        // Can't do @sum because missing value is -1 so this would screw up totals. :(
        currentTeamID = @"";
		for (Batting *aBattingRecord in allBatting) {
            if (![aBattingRecord.teamID isEqualToString:currentTeamID]) {
                // Put team name in before years for that team.
                NSString *teamName = [StatHead teamNameFromTeamID:aBattingRecord.teamID andYear:aBattingRecord.yearID managedObjectContext:moc];
                [battingLines addObject:[NSString stringWithFormat:@"     %@",[teamName uppercaseString]]];
            }
            /* If there are -1s in the data, eg. IBB stats in each year for Cy Young, then the -1s for the year get turned into NA with format_stat. Fine, but the totals at the bottom are just counted as zero. If any of the years are NA the total should be NA I guess. Right? How about creating a macro to do this. Make the total -1 if there are any -1s in the list.
             
             
                It should be like this:
                total_G = tally_with_na_check(total_G, [aBattingRecord.g integerValue])
             and what tally_with_na_check should do is check that total_G and the value aren't -1. If either of them are, return -1. Else do the addition and return the sum.
             Then at the end for the totals you have format_stat_int or whatever that checks for total of -1s.
             */
            total_G = tally_with_na_check(total_G, aBattingRecord.g);
            total_AB = tally_with_na_check(total_AB, aBattingRecord.aB);
            total_H = tally_with_na_check(total_H, aBattingRecord.h);
            total_R = tally_with_na_check(total_R, aBattingRecord.r);
            total_2B = tally_with_na_check(total_2B, aBattingRecord.doubles_2B);
            total_3B = tally_with_na_check(total_3B, aBattingRecord.triples_3B);
            total_HR = tally_with_na_check(total_HR, aBattingRecord.hR);
            total_RBI = tally_with_na_check(total_RBI, aBattingRecord.rBI);
            total_BB = tally_with_na_check(total_BB, aBattingRecord.bB);
            total_K = tally_with_na_check(total_K, aBattingRecord.sO);
            total_SB = tally_with_na_check(total_SB, aBattingRecord.sB);
            total_CS = tally_with_na_check(total_CS, aBattingRecord.cS);
            total_SH = tally_with_na_check(total_SH, aBattingRecord.sH);
            total_SF = tally_with_na_check(total_SF, aBattingRecord.sF);
            total_IBB = tally_with_na_check(total_IBB, aBattingRecord.iBB);
            total_HBP = tally_with_na_check(total_HBP, aBattingRecord.hBP);
            total_GIDP = tally_with_na_check(total_GIDP, aBattingRecord.gIDP);
            
            NSString *aBattingString = [NSString stringWithFormat:@"%@ %@  %@ %@ %@ %@ %@  %@ %@ %@  %@ %@ %@ %@ %@ %@ %@ %@ %@ %@  %@ %@ %@ %@",aBattingRecord.yearID,aBattingRecord.teamID,aBattingRecord.lgID,format_stat(aBattingRecord.g,4),format_stat(aBattingRecord.aB,5),format_stat(aBattingRecord.r,4),format_stat(aBattingRecord.h,4),format_stat(aBattingRecord.doubles_2B,3),format_stat(aBattingRecord.triples_3B,3),format_stat(aBattingRecord.hR,3),format_stat(aBattingRecord.rBI,4),[aBattingRecord displayStringForStat:@"bA"],[aBattingRecord displayStringForStat:@"oBP"],[aBattingRecord displayStringForStat:@"sLG"],[StatsFormatter averageInThousandFormForNSNumberPaddedToFiveChars:aBattingRecord.oPS],format_stat(aBattingRecord.bB,4),format_stat(aBattingRecord.sO,4),format_stat(aBattingRecord.sB,4),format_stat(aBattingRecord.cS,4),format_stat(aBattingRecord.sH,3),format_stat(aBattingRecord.sF,3),format_stat(aBattingRecord.iBB,3),format_stat(aBattingRecord.hBP,3),format_stat(aBattingRecord.gIDP,3)];
			[battingLines addObject:aBattingString];
            currentTeamID = aBattingRecord.teamID;
		}
		// Total batting calcs.
		NSInteger total_batting_average = (1000.0*(((float)total_H/(float)total_AB)+.0005));
		NSString *battingTotalsLine = [NSString stringWithFormat:@"Totals       %@ %@ %@ %@  %@ %@ %@  %@ .%03ld .%03ld %@  %@ %@ %@ %@ %@ %@  %@ %@ %@ %@",format_stat_int(total_G,4),format_stat_int(total_AB,5),format_stat_int(total_R,4),format_stat_int(total_H,4),format_stat_int(total_2B,3),format_stat_int(total_3B,3),format_stat_int(total_HR,3),format_stat_int(total_RBI,4),(long)total_batting_average,(long)[self on_BasePct],[self displaySluggingPct],[self displayOPS],format_stat_int(total_BB,4),format_stat_int(total_K,4),format_stat_int(total_SB,4),format_stat_int(total_CS,4),format_stat_int(total_SH,3),format_stat_int(total_SF,3),format_stat_int(total_IBB,3),format_stat_int(total_HBP,3),format_stat_int(total_GIDP,3)];
		[battingLines addObject:battingTotalsLine];
        [lines addObject:battingLines];
	} //else
    if (total_ipouts>0) { // Put in both batting and pitching if both exist.
#pragma mark - Pitching
        [titlesArray addObject:@"Complete Major League Pitching Record"];
        NSMutableArray *pitchingLines = [NSMutableArray new];
		[pitchingLines addObject:@"Year Tm   G   IP   W   L   Pct    H    R   ER   SO   BB   ERA  WHIP  SV  GS    BF HBP IBB  WP  SHO   CG   GF   BK"];
		NSInteger total_G=0, total_IP=0, total_W=0, total_L=0, total_H=0, total_R=0, total_ER=0, total_SO=0, total_BB=0;
        NSInteger total_SV=0, total_GS=0, total_BF=0, total_HBP=0, total_IBB=0, total_WP=0, total_SHO=0, total_CG=0, total_GF=0, total_BK=0;

        currentTeamID = @"";
		for (Pitching *aPitchingRecord in allPitching) {
            if (![aPitchingRecord.teamID isEqualToString:currentTeamID]) {
                // Put team name in before years for that team.
                NSString *teamName = [StatHead teamNameFromTeamID:aPitchingRecord.teamID andYear:aPitchingRecord.yearID managedObjectContext:moc];
                [pitchingLines addObject:[NSString stringWithFormat:@"     %@",[teamName uppercaseString]]];
            }
            total_G  = tally_with_na_check(total_G, aPitchingRecord.g);
            total_W = tally_with_na_check(total_W, aPitchingRecord.w);
            total_L = tally_with_na_check(total_L, aPitchingRecord.l);
            total_H = tally_with_na_check(total_H, aPitchingRecord.h);
            total_R = tally_with_na_check(total_R, aPitchingRecord.r);
            total_ER = tally_with_na_check(total_ER, aPitchingRecord.eR);
            total_SO = tally_with_na_check(total_SO, aPitchingRecord.sO);
            total_BB = tally_with_na_check(total_BB, aPitchingRecord.bB);
            total_SV = tally_with_na_check(total_SV, aPitchingRecord.sV);
            total_GS = tally_with_na_check(total_GS, aPitchingRecord.gS);
            total_BF = tally_with_na_check(total_BF, aPitchingRecord.bFP);
            total_HBP = tally_with_na_check(total_HBP, aPitchingRecord.hBP);
            total_IBB = tally_with_na_check(total_IBB, aPitchingRecord.iBB);
            total_WP = tally_with_na_check(total_WP, aPitchingRecord.wP);
            total_SHO = tally_with_na_check(total_SHO, aPitchingRecord.sHO);
            total_CG = tally_with_na_check(total_CG, aPitchingRecord.cG);
            total_GF = tally_with_na_check(total_GF, aPitchingRecord.gF);
            total_BK = tally_with_na_check(total_BK, aPitchingRecord.bK);
            
			NSInteger outs_pitched = [aPitchingRecord.iPOuts integerValue];
			NSInteger innings_pitched = ((float)outs_pitched/(float)3)+.5;
			total_IP += innings_pitched;
			float wins = [aPitchingRecord.w floatValue];
			float losses = [aPitchingRecord.l floatValue];
			NSInteger win_loss_percentage = 0;
			if (wins+losses > 0) win_loss_percentage = (1000.0*((wins/(wins+losses))+.0005));
            NSString *aPitchingString = [NSString stringWithFormat:@"%@ %@%@ %4ld %@ %@ %@ %@  %@  %@ %@  %@ %@ %@  %@ %@  %@ %@ %@ %@ %@  %@  %@ %@",aPitchingRecord.yearID,aPitchingRecord.teamID,format_stat(aPitchingRecord.g,3),(long)innings_pitched,format_stat(aPitchingRecord.w,3),format_stat(aPitchingRecord.l,3),[StatsFormatter percentagePaddedToFiveChars:win_loss_percentage],format_stat(aPitchingRecord.h,4),format_stat(aPitchingRecord.r,3),format_stat(aPitchingRecord.eR,3),format_stat(aPitchingRecord.sO,4),format_stat(aPitchingRecord.bB,3),[self eRAPaddedToFiveCharacters:[NSString stringWithFormat:@"%1.2f",[aPitchingRecord.eRA doubleValue]]],[StatsFormatter averageInThousandFormForNSNumberPaddedToFiveChars:aPitchingRecord.wHIP],format_stat(aPitchingRecord.sV,2),format_stat(aPitchingRecord.gS,3),format_stat(aPitchingRecord.bFP,4),format_stat(aPitchingRecord.hBP,3),format_stat(aPitchingRecord.iBB,3),format_stat(aPitchingRecord.wP,3),format_stat(aPitchingRecord.sHO,4),format_stat(aPitchingRecord.cG,3),format_stat(aPitchingRecord.gF,3),format_stat(aPitchingRecord.bK,4)];

			[pitchingLines addObject:aPitchingString];
            currentTeamID = aPitchingRecord.teamID;
		}
		// Do pitching totals calcs.
		NSInteger total_percentage = 0;
		if (total_W + total_L > 0) total_percentage = (1000.0*(((float)total_W/((float)total_W+(float)total_L))+.0005));
		float total_ERA = 9 * (float)total_ER / (float)total_IP;
		NSString *pitchingTotalsLine = [NSString stringWithFormat:@"Totals %@ %@ %@ %@ %@ %@ %@ %@ %@ %@  %1.2f %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",format_stat_int(total_G,4),format_stat_int(total_IP,4),format_stat_int(total_W,3),format_stat_int(total_L,3),[StatsFormatter percentagePaddedToFiveChars:total_percentage],format_stat_int(total_H,4),format_stat_int(total_R,4),format_stat_int(total_ER,4),format_stat_int(total_SO,4),format_stat_int(total_BB,4),total_ERA,[self displayWHIP],format_stat_int(total_SV,3),format_stat_int(total_GS,3),format_stat_int(total_BF,5),format_stat_int(total_HBP,3),format_stat_int(total_IBB,3),format_stat_int(total_WP,3),format_stat_int(total_SHO,4),format_stat_int(total_CG,4),format_stat_int(total_GF,4),format_stat_int(total_BK,4)];
		[pitchingLines addObject:pitchingTotalsLine];
        [lines addObject:pitchingLines];
	}
	// Do table section at the bottom for managing.
	if (allManagers) {
		if ([allManagers count] > 0) {
            [titlesArray addObject:@"Complete Major League Managing Record"];
            NSMutableArray *managingLines = [NSMutableArray new];
			[managingLines addObject:@"Year   Team Lg     G    W    L   Pct"];
			NSInteger total_G=0, total_W=0, total_L=0;
            currentTeamID = @"";
			for (Managers *aManagersRecord in allManagers) {
                if (![aManagersRecord.teamID isEqualToString:currentTeamID]) {
                    NSString *teamName = [StatHead teamNameFromTeamID:aManagersRecord.teamID andYear:aManagersRecord.yearID managedObjectContext:moc];
                    [managingLines addObject:[NSString stringWithFormat:@"     %@",[teamName uppercaseString]]];
                }
                total_G = tally_with_na_check(total_G, aManagersRecord.g);
                total_W = tally_with_na_check(total_W, aManagersRecord.w);
                total_L = tally_with_na_check(total_L, aManagersRecord.l);
				float wins = [aManagersRecord.w floatValue];
				float losses = [aManagersRecord.l floatValue];
				NSInteger win_loss_percentage = 0;
				if (wins+losses > 0) win_loss_percentage = (1000.0*((wins/(wins+losses))+.0005));
				NSString *aManagerString = [NSString stringWithFormat:@"%@   %@  %@  %@ %@ %@  .%03ld",aManagersRecord.yearID,aManagersRecord.teamID,aManagersRecord.lgID,format_stat(aManagersRecord.g,4),format_stat(aManagersRecord.w,4),format_stat(aManagersRecord.l,4),(long)win_loss_percentage];
				[managingLines addObject:aManagerString];
                currentTeamID = aManagersRecord.teamID;
			}
			// Do managers totals calcs.
			NSInteger total_percentage = 0;
			if (total_W + total_L > 0) total_percentage = (1000.0*(((float)total_W/((float)total_W+(float)total_L))+.0005));
			NSString *managersTotalsLine = [NSString stringWithFormat:@"Totals          %@ %@ %@  .%03ld",format_stat_int(total_G,4),format_stat_int(total_W,4),format_stat_int(total_L,4),(long)total_percentage];
			[managingLines addObject:managersTotalsLine];
            [lines addObject:managingLines];
		}
	}
    NSDictionary *textDictionaryToReturn = @{@"titles":titlesArray,@"lines":lines};
    return textDictionaryToReturn;
}

-(NSString *)eRAPaddedToFiveCharacters:(NSString *)eRAString
{
    // So like it's "0.666" then make it " 0.666".
    NSString *eraStringToReturn = eRAString;
    if ([eRAString length]==4)
        eraStringToReturn = [NSString stringWithFormat:@" %@",eraStringToReturn];
    return  eraStringToReturn;
}

#pragma mark Stat display methods for use by baseball card method

-(NSInteger)on_BasePct
{
    NSNumber *totalHits = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"h" statKind:@"Batting"];
    NSNumber *totalAtBats = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"aB" statKind:@"Batting"];
    NSNumber *totalWalks = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"bB" statKind:@"Batting"];
    NSNumber *totalHitByPitch = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"hBP" statKind:@"Batting"];
    NSNumber *totalSacFlies = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"sF" statKind:@"Batting"];
    NSInteger on_base_percentage = [StatHead on_BasePctWithHits:totalHits atBats:totalAtBats walks:totalWalks hitByPitch:totalHitByPitch sacFlies:totalSacFlies];
    return on_base_percentage;
}

// Can't use *Totals record if user has not paid for latest year.
-(NSNumber *)careerTotalWithoutLatestYearIfNotPaidForStat:(NSString *)statName statKind:(NSString *)statKind
{
    if ([statName isEqualToString:@"Managers"]) statName = @"Manager";
    NSString *totalsEntityName = [NSString stringWithFormat:@"%@Totals",statKind]; // ie. BattingTotals, or Pitching*, Fielding*, Manager(s)*
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *latestYearTotalForStat = @0;
    if ([appDel excludeLatestYear]) {
        NSString *statArrayName = [statKind lowercaseString];
        if ([statArrayName isEqualToString:@"manager"])
            statArrayName = @"managing";
        NSArray *statArray = [self valueForKey:statArrayName];
        NSPredicate *latestYearPred = [NSPredicate predicateWithFormat:@"yearID = %d",LATEST_DATA_YEAR];
        NSArray *latestYearStats = [statArray filteredArrayUsingPredicate:latestYearPred];
        latestYearTotalForStat = [latestYearStats valueForKeyPath:[NSString stringWithFormat:@"@sum.%@",statName]];
    }
    // But need first character to be lower case.
    NSString *totalsRelationshipName = [totalsEntityName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[totalsEntityName substringToIndex:1] lowercaseString]];
    NSNumber *totalIncludingLatestYear = [[self.master valueForKey:totalsRelationshipName] valueForKey:statName];
    NSInteger total_including_latest_year = [totalIncludingLatestYear integerValue];
    NSInteger latest_year_total_for_stat = [latestYearTotalForStat integerValue]; // 0 if paid.
    NSInteger total_subtracting_latest_year_if_not_paid = total_including_latest_year - latest_year_total_for_stat;
    return [NSNumber numberWithInteger:total_subtracting_latest_year_if_not_paid];
}

-(NSInteger)sluggingPercentage
{
    NSNumber *totalHits = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"h" statKind:@"Batting"];
    NSNumber *totalAtBats = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"aB" statKind:@"Batting"];
    NSNumber *totalDoubles = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"doubles_2B" statKind:@"Batting"];
    NSNumber *totalTriples = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"triples_3B" statKind:@"Batting"];
    NSNumber *totalHomeRuns = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"hR" statKind:@"Batting"];
    NSInteger slugging_percentage = [StatHead sluggingPctWithHits:totalHits atBats:totalAtBats doubles:totalDoubles triples:totalTriples homeRuns:totalHomeRuns];
    return  slugging_percentage;
}

-(NSString *)displaySluggingPct
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel excludeLatestYear]) {
        return [StatsFormatter averageInThousandForm:[self sluggingPercentage]];
    }
    else
        return [StatsFormatter averageInThousandFormForNSNumber:self.master.battingTotals.sLG];
}

-(NSInteger)OPS {
    return [self on_BasePct]+[self sluggingPercentage];
}

-(NSString *)displayOPS
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel excludeLatestYear]) {
        return [StatsFormatter averageInThousandForm:[self OPS]];
    } else
        return [StatsFormatter averageInThousandFormForNSNumber:self.master.battingTotals.oPS];
}

-(NSString *)displayWHIP
{    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDel excludeLatestYear]) {
        NSNumber *totalWalks = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"bB" statKind:@"Pitching"];
        NSNumber *totalHits = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"h" statKind:@"Pitching"];
        NSNumber *outsPitched = [self careerTotalWithoutLatestYearIfNotPaidForStat:@"iPOuts" statKind:@"Pitching"];
        CGFloat whip = 1000.0*([totalWalks floatValue] + [totalHits floatValue]) / ([outsPitched floatValue] / 3.0) + .0005;
        return [StatsFormatter averageInThousandFormPaddedToFiveChars:whip];
        
    } else
        return [StatsFormatter averageInThousandFormForNSNumberPaddedToFiveChars:self.master.pitchingTotals.wHIP];
}

@end
