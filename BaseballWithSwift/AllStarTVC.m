//
//  AllStarTVC.m
//  BaseballQuery
//
//  Created by Mark Knopper on 5/27/11.
//  Copyright 2011-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "AllStarTVC.h"
#import "AllstarFull.h"
#import "BaseballQueryAppDelegate.h"
//#import "GameLog.h"
#import "StatHead.h"
//#import "Park.h"
#import "AwardsPlayers.h"
#import "RetrosheetController.h"
#import "BaseballWithSwift-Bridging-Header.h"
#import "StatsFormatter.h"
#import "BaseballWithSwift-Swift.h"

/* All Star Game summary on year tab (standings, postseason, all-star game).
  AS MVP can be found in AwardsPlayers.
 Summary would be:
 page nav title:
 [Year] All Star Game 
 game header section:
 Date  xx-xx-xxxx
 Score NL 3 AL 2
 Park (using park data from retrosheet here:
 http://www.retrosheet.org/parkcode.txt )
 MVP?
 AL & NL Starting Pitchers
 AL & NL Managers
 Starting lineups. (separate sections?)
 <click on players for game info>
 */


@implementation AllStarTVC

// Class method to query for all star records and return whether there were any for requested year.
+(BOOL)allstarGamePlayedInYear:(NSNumber *)aYear;
{
    RetrosheetController *retrosheetController = [RetrosheetController sharedInstance];
    NSFetchRequest *retroFetch = [NSFetchRequest fetchRequestWithEntityName:@"GameLog"];
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    NSDate *jan1Date = [yearFormatter dateFromString:[aYear stringValue]];
    NSDate *nextJan1Date = [yearFormatter dateFromString:[NSString stringWithFormat:@"%ld",(long)[aYear integerValue]+1]];
    if (!jan1Date || !nextJan1Date) return FALSE; // Got one crash where this might have been the cause. Why??
    // Can't use BETWEEN in core data predicates, too bad.
    retroFetch.predicate = [NSPredicate predicateWithFormat:@"date > %@ AND date < %@",jan1Date, nextJan1Date];
    NSError *error = nil;
    NSUInteger gamesInYear = [retrosheetController.retrosheetManagedObjectContext countForFetchRequest:retroFetch error:&error];
    return (gamesInYear > 0);
}

-(NSManagedObjectContext *)managedObjectContext
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDel managedObjectContext];
}

//
// setYear - get relevant all-star game records from Retro db
//  and produce display array for rows. Each row is a dictionary
//  with label and value. That's it. This localizes all retro db access to this method.
//
-(void)setYear:(NSNumber *)year
{
    if (_year == year) return;
    _year = year;
    self.game1 = nil;
    self.game2 = nil;
    // Get Retrosheet all star game logs (GLAS) records for this year (one per game).
    RetrosheetController *retrosheetController = [RetrosheetController sharedInstance];
    NSFetchRequest *retroFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *GLASEntity = [NSEntityDescription entityForName:@"GameLog" inManagedObjectContext:retrosheetController.retrosheetManagedObjectContext];
    [retroFetch setEntity:GLASEntity];
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    NSDate *jan1Date = [yearFormatter dateFromString:[_year stringValue]];
    NSDate *nextJan1Date = [yearFormatter dateFromString:[NSString stringWithFormat:@"%ld",(long)[_year integerValue]+1]];
    if (!jan1Date || !nextJan1Date) return; // Got one crash where this might have been the cause. Why??
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)",jan1Date,nextJan1Date];
    [retroFetch setPredicate:predicate];
    NSError *error=nil;
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [retroFetch setSortDescriptors:@[sortByDate]];
    NSArray *rGLFY = [retrosheetController.retrosheetManagedObjectContext executeFetchRequest:retroFetch error:&error];
    // We now have the BDB data, as aSFRBGN (array of game arrays);
    // and the Retrosheet data, as rGLFY (retroGameLogsForYear). Should be parallel array to above.
    // Now produce display array for sections, each of which is an array of rows.
    // Each row entry is a dictionary with label and value keys, both strings.
    NSInteger number_of_allstar_games_this_year = [rGLFY count];
    // 3 sections per game - 0) game info, 1) AL lineup, 2) NL lineup.
    self.sectionTitles = [[NSMutableArray alloc] initWithCapacity:3*number_of_allstar_games_this_year];
    self.sectionRowStrings = [[NSMutableArray alloc] initWithCapacity:3*number_of_allstar_games_this_year];
    NSInteger gameNum = 0;
    for (GameLog *game in rGLFY) {
        // 9 rows in game info section: Date, Park, City, Score,
        // MVP (possibly 2 of these), AL Starter, NL Starter, AL Manager, NL Manager
        // Date
        if (gameNum++ == 0)
            self.game1 = game; // Save the game.
        else
            self.game2 = game;
        NSMutableArray *gameInfoSection = [[NSMutableArray alloc] initWithCapacity:10];
        NSDateFormatter *americanDate = [[NSDateFormatter alloc] init];
        [americanDate setDateStyle:NSDateFormatterLongStyle];
        NSDictionary *dateDict = @{@"label": @"Date", @"value": [NSString stringWithFormat:@"%@ (%@)", [americanDate stringFromDate:game.date], [game.dayOrNight isEqualToString:@"D"] ? @"Day" : @"Night"]};
        [gameInfoSection addObject:dateDict];
        // Park
        NSFetchRequest *parkFetch = [[NSFetchRequest alloc] init];
        // Change to using "Parks" from main database rather than "Park" from Retrosheet.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parkKey==%@",game.parkID];
        [parkFetch setPredicate:predicate];
        NSEntityDescription *parkEntity = [NSEntityDescription entityForName:@"Parks" inManagedObjectContext:self.managedObjectContext];
        [parkFetch setEntity:parkEntity];
        NSError *error = nil;
        Parks *park = [self.managedObjectContext executeFetchRequest:parkFetch error:&error][0];
        [gameInfoSection addObject:@{@"label":@"Park",@"value":park.parkName}];
        // City
        [gameInfoSection addObject:@{@"label":@"City",@"value":park.city}];
        // Score (NL 3 AL 2)
        [gameInfoSection addObject:@{@"label":@"Score",@"value":[NSString stringWithFormat:@"%@ %ld %@ %ld",[game.visitingTeamID substringToIndex:2],(long)[game.visitingScore integerValue],[game.homeTeamID substringToIndex:2],(long)[game.homeScore integerValue]]}];
        // MVP. In 1962 there were 2 games and 2 MVPs. Notes column has "1st Game" and "2nd Game".
        // Search AwardsPlayers awardsFetchfor MVP.
        NSFetchRequest *awardsFetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *awardsEntity = [NSEntityDescription entityForName:@"AwardsPlayers" inManagedObjectContext:self.managedObjectContext];
        [awardsFetch setEntity:awardsEntity];
        NSPredicate *awardsPredicate = [NSPredicate predicateWithFormat:@"yearID==%@ && awardID==\"All-Star Game MVP\"",_year];
        [awardsFetch setPredicate:awardsPredicate];
        NSArray *mvpAwards = [_managedObjectContext executeFetchRequest:awardsFetch error:&error];
        if ([mvpAwards count]>0) { // If there was an MVP,
            // In 1962 there were two games each with its own MVP.
            AwardsPlayers *mvpAward = mvpAwards[0];
            if ([mvpAwards count]>1) { // Needs to be fixed if there were more than 2 games!
                NSString *noteForGameNum = ([game.visitingTeamGameNum integerValue]==1) ? @"1st Game" : @"2nd Game";
                if (![mvpAward.notes isEqualToString:noteForGameNum])
                    mvpAward = mvpAwards[1]; // Guess it's game 2 in 1962.
            }
            NSString *mvpName = [StatHead playerNameFromPlayerID:mvpAward.playerID managedObjectContext:_managedObjectContext];
            [gameInfoSection addObject:@{@"label":@"MVP",@"value":mvpName}];
        }
        // Visiting Starter
        [gameInfoSection addObject:@{@"label":[NSString stringWithFormat:@"%@ Starter",[game.visitingTeamID substringToIndex:2]],@"value":game.visitingStartingPitcherName}];
        // Home Starter
        [gameInfoSection addObject:@{@"label":[NSString stringWithFormat:@"%@ Starter",[game.homeTeamID substringToIndex:2]],@"value":game.homeStartingPitcherName}];
        // Visiting Manager
        [gameInfoSection addObject:@{@"label":[NSString stringWithFormat:@"%@ Manager",[game.visitingTeamID substringToIndex:2]],@"value":game.visitingManagerName}];
        // Home Manager
        [gameInfoSection addObject:@{@"label":[NSString stringWithFormat:@"%@ Manager",[game.homeTeamID substringToIndex:2]],@"value":game.homeManagerName}];
        [gameInfoSection addObject:@{@"label":@"Attendance", @"value": [StatsFormatter largeNumberInCommaFormWithNSNumber: game.attendance]}];
        //[gameInfoSection addObject:@{@"label":@"Time", @"value":[game.dayOrNight isEqualToString:@"D"] ? @"Day" : @"Night"}];
        
        // gameInfoSection is now complete for this game.
        [_sectionRowStrings addObject:gameInfoSection];
        // Visiting Roster
        // Actually I think there are officially 34 players but leave room for more.
        NSMutableArray *visitingRoster = [[NSMutableArray alloc] initWithCapacity:40];
        NSString *homeOrVisiting = @"visiting";
        for (NSInteger slot=1;slot<=9;slot++) {
            NSString *nameKey = [NSString stringWithFormat:@"%@Batter%ldName",homeOrVisiting, (long)slot];
            NSString *positionKey = [NSString stringWithFormat:@"%@Batter%ldPos",homeOrVisiting, (long)slot];
            [visitingRoster addObject:@{@"label":[game valueForKey:nameKey],@"value":[StatHead positionNameFromPositionNumber:[game valueForKey:positionKey]]}];
        }
        [_sectionRowStrings addObject:visitingRoster];
        NSMutableArray *homeRoster = [[NSMutableArray alloc] initWithCapacity:40];
        homeOrVisiting = @"home";
        for (NSInteger slot=1;slot<=9;slot++) {
            NSString *nameKey = [NSString stringWithFormat:@"%@Batter%ldName",homeOrVisiting, (long)slot];
            NSString *positionKey = [NSString stringWithFormat:@"%@Batter%ldPos",homeOrVisiting, (long)slot];
            [homeRoster addObject:@{@"label":[game valueForKey:nameKey],@"value":[StatHead positionNameFromPositionNumber:[game valueForKey:positionKey]]}];
        }
        [_sectionRowStrings addObject:homeRoster];
        // sectionRowStrings is now complete. Contains all table strings for display.
        // Now generate sectionTitles.
            NSString *gameNumberString = @" ";
            if (number_of_allstar_games_this_year>1) gameNumberString = [NSString stringWithFormat:@" %@ ",[game.visitingTeamGameNum description]];
            [_sectionTitles addObject:[NSString stringWithFormat:@"All-Star Game%@@ %@",gameNumberString,[game.homeTeamID substringToIndex:2]]];
            [_sectionTitles addObject:[NSString stringWithFormat:@"%@ Starting Lineup",[game.visitingTeamID substringToIndex:2]]];
            [_sectionTitles addObject:[NSString stringWithFormat:@"%@ Starting Lineup",[game.homeTeamID substringToIndex:2]]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionRowStrings count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sectionRowStrings[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AllStarCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryView = nil;
    cell.textLabel.text = _sectionRowStrings[indexPath.section][indexPath.row][@"label"];
    cell.detailTextLabel.text = _sectionRowStrings[indexPath.section][indexPath.row][@"value"];
    // Long park name needs to be shrunk. Also had to reduce prio of horiz compression resistance for detailTextLabel.
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.detailTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:cell.textLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:5.0]];
    if ([cell.textLabel.text isEqualToString:@"Score"]) {
        UIButton *boxScoreInfoButt = [UIButton buttonWithType:UIButtonTypeInfoLight];
        boxScoreInfoButt.tag = indexPath.section == 0 ? 1 : 2; // button tag is 1 for game 1, 2 for game 2.
        [boxScoreInfoButt addTarget:self action:@selector(pressedInfoButt:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = boxScoreInfoButt;
    }
    return cell;
}

-(void)pressedInfoButt:(id)sender
{
    self.selected_game_number = ((UIButton *)sender).tag;
    [self performSegueWithIdentifier:@"allstarToWeb" sender: self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /* Retrosheet box score URL looks like: http://www.retrosheet.org/boxesetc/2016/B07120ALS2016.htm */ /* http://www.retrosheet.org/boxesetc/1962/B07100ALS1962.htm */
    NSDateFormatter *formy = [NSDateFormatter new];
    formy.dateFormat = @"MMdd";
    GameLog *selectedGame = _selected_game_number == 1 ? self.game1 : self.game2;
    NSString *urlString = [NSString stringWithFormat:@"http://www.retrosheet.org/boxesetc/%@/B%@0%@S%@.htm",self.year,[formy stringFromDate:selectedGame.date], [selectedGame.homeTeamID substringToIndex:2], self.year];
    [[segue destinationViewController] setValue:[NSURL URLWithString:urlString] forKey:@"statsURL"];
}

@end
