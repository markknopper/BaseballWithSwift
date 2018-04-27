//
//  StatsDisplayFactory.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/31/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "StatsDisplayFactory.h"

@implementation StatsDisplayFactory

//
// createStatsDisplayWithType
//

+(StatsDisplay *)createStatsDisplayWithType:(StatsDisplayStatType)statsDisplayType player:(BQPlayer *)player{
	StatsDisplay *display = nil;
    // statsDisplayType is set in the tag of the tab item in the storyboard.
    switch (statsDisplayType) {
#pragma mark StatsDisplayStatTypePlayerBatting // single season batting
        case (StatsDisplayStatTypeBatting|StatsDisplayStatScopePlayer):
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            /* MAKE_STAT_DESCRIPTOR and friends are defined in StatDescriptor.h */
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"aTeamSeason.name", @"Team",@"battingToTeamRoster"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aB", @"At Bats",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r", @"Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h", @"Hits",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"bA", @"Batting Average",NO,@"shouldRankForBattingAverage"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rBI", @"Runs Batted In",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oBP",@"On-Base Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sLG", @"Slugging Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oPS", @"OPS",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"doubles_2B", @"Doubles",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"triples_3B", @"Triples",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR", @"Home Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sB", @"Stolen Bases",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cS", @"Caught Stealing",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO", @"Strikeouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sH", @"Sacrifice Hits",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sF", @"Sacrifice Flies",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB", @"Intentional Walks",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gIDP", @"Grounded Into DP",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"stint", @"Stint",NO),
                nil];
            break;
#pragma mark StatsDisplayStatTypePlayerPitching
        case StatsDisplayStatTypePitching|StatsDisplayStatScopePlayer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"aTeamSeason.name", @"Team",@"pitchingToTeamRoster"),
        MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pitcherKind",@"Pitcher Kind",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w", @"Wins",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l", @"Losses",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"percentage",@"Percentage",NO),

            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"eRA", @"Earned Run Ave",YES,@"shouldRankForERA"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"wHIP", @"WHIP",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bAOpp", @"Opp Batting Ave",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sV", @"Saves",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS", @"Games Started",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iPOuts", @"Innings Pitched",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bFP", @"Batters Faced",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h", @"Hits",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r", @"Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eR", @"Earned Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO", @"Strikeouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR", @"Home Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB", @"Intentional Walks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"wP", @"Wild Pitches",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sHO", @"Shutouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cG", @"Complete Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gF", @"Games Finished",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bK", @"Balks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"stint", @"Stint",YES),
            nil];
            break;
#pragma mark StatsDisplayStatTypePlayerManaging;
        case StatsDisplayStatTypeManaging|StatsDisplayStatScopePlayer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"aTeamSeason.name", @"Team",@"managerToTeamRoster"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w", @"Wins",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l", @"Losses",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"percentage",@"Percentage",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rank", @"Rank",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"inseason", @"In Season",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"plyrMgr", @"Player-Manager?",NO),
            nil];
            break;
            
#pragma mark StatsDisplayStatTypePlayerFielding
        case StatsDisplayStatTypeFielding|StatsDisplayStatScopePlayer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"aTeamSeason.name", @"Team",@"fieldingToTeamRoster"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"pos", @"Position", NO, @"justSayNoToRanking"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS", @"Games Started",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"fPct",@"Fielding Pct",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pO", @"Putouts",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"a", @"Assists",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"e", @"Errors",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"dP", @"Double Plays",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"innOuts", @"Innings",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pB", @"Passed Balls",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"zR", @"Zone Rating",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"stint", @"Stint",YES),
                       nil];
            break;
            
#pragma mark StatsDisplayStatTypePlayerPersonal
        case StatsDisplayStatTypePersonal|StatsDisplayStatScopePlayer:
        {
            display = [StatsDisplay new];
            display.type = statsDisplayType;
            NSMutableArray *personalStatDescriptors = [player personalStats];
            display.statDescriptors = personalStatDescriptors;
        }
            break;
            
#pragma mark StatsDisplayStatTypePostBatting (player post batting)
        case (StatsDisplayStatTypeBatting|StatsDisplayStatScopePost):
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
                       // yearID,round,playerID,teamID,lgID,g,aB,r,h,doubles_2B,triples_3B,hR,rBI,sB,cS,bB,sO,iBB,hBP,sH,sF,gIDP
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"round",@"Series",@"postPlayerToSeries"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aTeamName", @"Team", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"lgID", @"League", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g",@"Games",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aB",@"At Bats",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r",@"Runs",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h",@"Hits",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"bA", @"Batting Average",NO,@"shouldRankForBattingAverage"), // ***

                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"doubles_2B",@"Doubles",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"triples_3B",@"Triples",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR",@"Home Runs",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rBI",@"Runs Batted In",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sB",@"Stolen Bases",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cS",@"Caught Stealing",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB",@"Walks",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO",@"Strikeouts",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB",@"Intentional Walks",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP",@"Hit By Pitch",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sH",@"Sacrifice Hits",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sF",@"Sacrifice Flies",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gIDP",@"Grounded Into Double Play",NO),
                       nil];
            break;
            
#pragma mark StatsDisplayStatTypePostPitching (player post pitching)
        case (StatsDisplayStatTypePitching|StatsDisplayStatScopePost):
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"round",@"Series",@"postPlayerToSeries"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aTeamName", @"Team", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"lgID", @"League", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w",@"Wins",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l",@"Losses",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g",@"Games",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"eRA", @"Earned Run Ave",YES,@"shouldRankForERA"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS",@"Games Started",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gF",@"Games Finished",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cG",@"Complete Games",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sHO",@"Shutouts",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sV",@"Saves",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iPOuts", @"Innings Pitched",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h",@"Hits",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eR",@"Earned Runs",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR",@"Home Runs",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB",@"Walks",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB", @"Intentional Walks",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO",@"Strikeouts",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bAOpp", @"Opp Batting Ave",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"wP", @"Wild Pitches",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bK", @"Balks",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bFP",@"Batters Faced",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r",@"Runs",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sH",@"Sacrifice Hits",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gIDP",@"Grounded Into Double Play",NO),
                       nil];
            break;
            
#pragma mark StatsDisplayStatTypePostFielding (player post fielding)
        case (StatsDisplayStatTypeFielding|StatsDisplayStatScopePost):
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
                       // playerID,yearID,teamID,lgID,round,POS,G,GS,InnOuts,PO,A,E,DP,TP,PB,SB,CS
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(@"round",@"Series",@"postPlayerToSeries"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aTeamName", @"Team", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"lgID", @"League", NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"pos", @"Position", NO, @"justSayNoToRanking"),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS", @"Games Started",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"innOuts", @"Innings",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"fPct",@"Fielding Pct",NO), // ***
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pO", @"Putouts",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"a", @"Assists",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"e", @"Errors",YES),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"dP", @"Double Plays",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"tP",@"Triple Plays",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pB",@"Passed Balls",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sB",@"Stolen Bases",NO),
                       MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cS",@"Caught Stealing",NO),
                       nil];
            break;
            
#pragma mark StatsDisplayStatTypeTeamInfo
        case StatsDisplayStatScopeTeam|StatsDisplayStatScopeInfo:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w", @"Wins",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l", @"Losses",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"percentage",@"Percentage",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"attendance", @"Attendance",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rank", @"Rank",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"park", @"Park",NO),
            nil];
            break;
#pragma mark StatsDisplayStatTypeTeamBatting
        case StatsDisplayStatTypeBatting|StatsDisplayStatScopeTeam:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aB", @"At Bats",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r", @"Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h", @"Hits",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"bA", @"Batting Average",NO,@"shouldRankForBattingAverage"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oBP",@"On-Base Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sLG", @"Slugging Pct",NO),MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oPS", @"OPS",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"doubles_2B", @"Doubles",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"triples_3B", @"Triples",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR", @"Home Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sB", @"Stolen Bases",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cS", @"Caught Stealing",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO", @"Strikeouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sF", @"Sacrifice Flies",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",NO),
            nil];
            break;
#pragma mark StatsDisplayStatTypeTeamPitching
        case StatsDisplayStatTypePitching|StatsDisplayStatScopeTeam:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eRA", @"Earned Run Ave",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iPOuts", @"Innings Pitched",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hA", @"Hits Allowed",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rA", @"Runs Allowed",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eR", @"Earned Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sOA", @"Strikeouts",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hRA", @"Home Runs Allowed",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"dP", @"Double Plays",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sHO", @"Shutouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sV", @"Saves",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cG", @"Complete Games",NO),
            nil];
            break;
#pragma mark StatsDisplayStatTypeTeamFielding
        case StatsDisplayStatTypeFielding|StatsDisplayStatScopeTeam:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"e", @"Errors",YES),
        MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"fPct",@"Fielding Pct",NO),
        MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"dP", @"Double Plays",NO),
            nil];
            break;
#pragma mark StatsDisplayStatTypeCareerBatting
        case StatsDisplayStatTypeBatting|StatsDisplayStatScopeCareer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"seasons",@"Seasons",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"aB", @"At Bats",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r", @"Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h", @"Hits",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(@"bA", @"Batting Average",NO,@"shouldRankForBattingAverage"),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"rBI", @"Runs Batted In",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oBP",@"On-Base Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sLG", @"Slugging Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"oPS", @"OPS",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"doubles_2B", @"Doubles",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"triples_3B", @"Triples",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR", @"Home Runs",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sB", @"Stolen Bases",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cS", @"Caught Stealing",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO", @"Strikeouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sH", @"Sacrifice Hits",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sF", @"Sacrifice Flies",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB", @"Intentional Walks",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gIDP", @"Grounded Into DP",YES),
            nil];
            break;
#pragma mark StatsDisplayStatTypeCareerPitching
        case StatsDisplayStatTypePitching|StatsDisplayStatScopeCareer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w", @"Wins",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l", @"Losses",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"percentage",@"Percentage",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"seasons",@"Seasons",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sV", @"Saves",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eRA",@"Earned Run Ave",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"wHIP", @"WHIP",YES),
                       /* OBA seems to be too esoteric to compute.
                        http://www.baseball-fever.com/showthread.php?43723-How-do-you-calculate-a-pitcher-s-batting-average-against
                        MAKE_STAT_DESCRIPTOR(@"oppBattingAve", @"Opp Batting Ave", @"displayOppBattingAve",YES),
                        */
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS", @"Games Started",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iPOuts", @"Innings Pitched",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bFP", @"Batters Faced",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"h", @"Hits",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"r", @"Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"eR", @"Earned Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bB", @"Walks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sO", @"Strikeouts",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hR", @"Home Runs",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"hBP", @"Hit By Pitch",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"iBB", @"Intentional Walks",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"wP", @"Wild Pitches",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"sHO", @"Shutouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"cG", @"Complete Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gF", @"Games Finished",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"bK", @"Balks",YES),
            nil];
            break;
#pragma mark StatsDisplayStatTypeCareerFielding
        case StatsDisplayStatTypeFielding|StatsDisplayStatScopeCareer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            // This is fielding per position, not fielding totals!!!!!!!!!!!!!
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pos", @"Position",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"seasons",@"Seasons",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"gS", @"Games Started",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"fPct",@"Fielding Pct",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pO", @"Putouts",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"a", @"Assists",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"e", @"Errors",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"dP", @"Double Plays",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"innOuts", @"Innings",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"pB", @"Passed Balls",YES),
            nil];
            break;
#pragma mark StatsDisplayStatTypeCareerManaging;
        case StatsDisplayStatTypeManaging|StatsDisplayStatScopeCareer:
            display = [[StatsDisplay alloc] initWithStatsDisplayStatType:statsDisplayType descriptors:
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"seasons",@"Seasons",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"g", @"Games",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"w", @"Wins",NO),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"l", @"Losses",YES),
            MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(@"percentage",@"Percentage",NO),
            nil];
            break;
        default:
            display = nil;
            break;
    }

	return display;
}

@end
