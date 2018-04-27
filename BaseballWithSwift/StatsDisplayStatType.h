//
//  StatsDisplayStatType.h
//  BaseballQuery
//
//  Created by Mark Knopper on 6/10/14.
//  Copyright (c) 2014-2017 Bulbous Ventures LLC. All rights reserved.
//

/* 
 low 4 bits indicate stat type:
 0 personal / info (for team)
 1 batting
 2 pitching
 3 fielding
 4 managing
 high 4 bits indicate stat scope:
 0 n/a
 1 player
 2 career
 3 team
 // higher bits 3-5 indicate player/career/team/info
 / * Tags in storyboard tab bar items should look like this:
 player personal x410    1040 (or info)
 player batting  x411    1041
 player pitching x412    1042
 player fielding x413    1043
 player managing x414    1044
 career personal x420    1056 (not really a thing)
 career batting  x421    1057
 career pitching x422    1058
 career fielding x423    1059
 career managing x424    1060
 team info      x430     1072
 team batting   x431     1073
 team pitching  x432     1074
 team fielding  x433     1075
 team managing  x434     1076
 */

@import Foundation;

typedef NSInteger StatsDisplayStatType;

#define StatsDisplayStatTypePersonal 0
#define StatsDisplayStatTypeBatting 1
#define StatsDisplayStatTypePitching 2
#define StatsDisplayStatTypeFielding 3
#define StatsDisplayStatTypeManaging 4
#define StatsDisplayStatScopeInfo 0<<4
#define StatsDisplayStatScopePlayer 1<<4  // x10 aka single season
#define StatsDisplayStatScopeCareer 2<<4  // x20
#define StatsDisplayStatScopeTeam 3<<4    // x30
#define StatsDisplayStatScopePost 4<<4    // x40 - This is Player Post really.

#define StatsDisplayStatTypeMask 0x0f
#define StatsDisplayStatScopeMask 0xf0

