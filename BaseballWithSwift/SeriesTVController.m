//
//  SeriesTVController.m
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 2/20/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//
// Post-Season tab in YearTBC.

#import "SeriesTVController.h"
#import "SeriesPost.h"
#import "StatHead.h"
#import "AwardsPlayers.h"
#import "BaseballQueryAppDelegate.h"

@implementation SeriesTVController

#pragma mark -
#pragma mark View lifecycle

// Given seriesThisYear (or we fetch it first), produce sectionsForDisplay.
-(void)addSeries:(NSString *)seriesName abbrev:(NSString *)seriesAbbreviation
{
	NSMutableArray *seriesArray = [NSMutableArray new];
    if (!_seriesThisYear) { // Might have the series list already if coming from YearsTVC.
        // Or not if coming from StatsVC:Post.
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SeriesPost"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"yearID==%@",_year];
        NSError *error=nil;
        NSArray *seriesThisYear = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        self.seriesThisYear = seriesThisYear;
    }
    // Loop until we find our series. Then add name to sectionTitles and all of the info to seriesArray and this to sectionsForDisplay.
	for (SeriesPost *aSeriesPostRecord in _seriesThisYear) {
		if ([aSeriesPostRecord.round isEqualToString:seriesAbbreviation]) {
            // Make sectionTitles an array of dictionaries with keys name and round. name is like World Series and round is like WS.
            [_sectionTitles addObject:@{@"name":seriesName,@"round":seriesAbbreviation}];
			[seriesArray addObject:@{@"Wins": aSeriesPostRecord.wins}];
			[seriesArray addObject:@{@"Losses": aSeriesPostRecord.losses}];
			if ([aSeriesPostRecord.ties integerValue]>0) [seriesArray addObject:@{@"Ties": aSeriesPostRecord.ties}];
            NSString *teamName = [StatHead teamNameFromTeamID:aSeriesPostRecord.teamIDwinner andYear:_year managedObjectContext:_managedObjectContext];
            if (teamName)
                [seriesArray addObject:@{@"Winning Team": teamName}];
            teamName = [StatHead teamNameFromTeamID:aSeriesPostRecord.teamIDloser andYear:_year managedObjectContext:_managedObjectContext];
            if (teamName)
                [seriesArray addObject:@{@"Losing Team": teamName}];
            NSFetchRequest *mvpFetch = [NSFetchRequest fetchRequestWithEntityName:@"AwardsPlayers"];
			if ([aSeriesPostRecord.round isEqualToString:@"WS"]) {
                [seriesArray addObject:@{@"Winning League": aSeriesPostRecord.lgIDwinner}];
                [seriesArray addObject:@{@"Losing League": aSeriesPostRecord.lgIDloser}];
                // Look up WS MVP.
                mvpFetch.predicate = [NSPredicate predicateWithFormat:@"yearID == %@ AND awardID == \"World Series MVP\"",_year];
                NSError *error = nil;
                NSArray *mvpArray = [_managedObjectContext executeFetchRequest:mvpFetch error:&error];
                if (mvpArray.count > 0) {
                    AwardsPlayers *mvpAP = mvpArray[0];
                    NSString *mvpName = [StatHead playerNameFromPlayerID:mvpAP.playerID managedObjectContext:_managedObjectContext];
                    [seriesArray addObject:@{@"MVP": mvpName}];
                }
            } else if ([aSeriesPostRecord.round isEqualToString:@"ALCS"]) {
                mvpFetch.predicate = [NSPredicate predicateWithFormat:@"yearID == %@ AND awardID == \"ALCS MVP\"",_year];
                NSError *error = nil;
                NSArray *mvpArray = [_managedObjectContext executeFetchRequest:mvpFetch error:&error];
                if (mvpArray.count > 0) {
                    AwardsPlayers *mvpAP = mvpArray[0];
                    NSString *mvpName = [StatHead playerNameFromPlayerID:mvpAP.playerID managedObjectContext:_managedObjectContext];
                    [seriesArray addObject:@{@"MVP": mvpName}];
                }
            }  else if ([aSeriesPostRecord.round isEqualToString:@"NLCS"]) {
                mvpFetch.predicate = [NSPredicate predicateWithFormat:@"yearID == %@ AND awardID == \"NLCS MVP\"",_year];
                NSError *error = nil;
                NSArray *mvpArray = [_managedObjectContext executeFetchRequest:mvpFetch error:&error];
                if (mvpArray.count > 0) {
                    AwardsPlayers *mvpAP = mvpArray[0];
                    NSString *mvpName = [StatHead playerNameFromPlayerID:mvpAP.playerID managedObjectContext:_managedObjectContext];
                    [seriesArray addObject:@{@"MVP": mvpName}]; // There's a little code duplication here. Maybe it's worth doing something about later.
                }
            }
			[_sectionsForDisplay addObject:seriesArray];
			break;
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionsForDisplay = [NSMutableArray new]; // This is an array of arrays of dictionaries, with object=value and key=type.
    self.sectionTitles = [NSMutableArray new];
    BaseballQueryAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDel.managedObjectContext;
    // Do series in this order. This ends up creating parallel  "sorted" arrays sectionTitles and sectionsForDisplay.
    [self addSeries:@"World Series" abbrev:@"WS"];
    [self addSeries:@"Championship Series" abbrev:@"CS"];
    [self addSeries:@"AL Wild Card" abbrev:@"ALWC"];
    [self addSeries:@"NL Wild Card" abbrev:@"NLWC"];
    [self addSeries:@"AL Championship Series" abbrev:@"ALCS"];
    [self addSeries:@"NL Championship Series" abbrev:@"NLCS"];
    [self addSeries:@"AL East Division Series" abbrev:@"AEDIV"];
    [self addSeries:@"AL West Division Series" abbrev:@"AWDIV"];
    [self addSeries:@"NL East Division Series" abbrev:@"NEDIV"];
    [self addSeries:@"NL West Division Series" abbrev:@"NWDIV"];
    [self addSeries:@"AL Division Series 1" abbrev:@"ALDS1"];
    [self addSeries:@"AL Division Series 2" abbrev:@"ALDS2"];
    [self addSeries:@"NL Division Series 1" abbrev:@"NLDS1"];
    [self addSeries:@"NL Division Series 2" abbrev:@"NLDS2"];
}

//-(void)viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:animated];
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        if (_scrollToRound) {
        // Find section containing our round and scroll to it.
        NSUInteger round_index = [_sectionTitles indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj objectForKey:@"round"] isEqualToString:_scrollToRound]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:round_index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionTitleDict = _sectionTitles[section];
	return [NSString stringWithFormat:@"%@ %@", _year.description, sectionTitleDict[@"name"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_sectionsForDisplay count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_sectionsForDisplay[section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *rowDict = _sectionsForDisplay[indexPath.section][indexPath.row];
    static NSString *CellIdentifier = @"SeriesCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[rowDict allKeys][0] isEqualToString:@"text_only"]) {
		cell.textLabel.text = [[rowDict allValues][0] description];
    } else {
        cell.textLabel.text =  [rowDict allKeys][0];
        cell.detailTextLabel.text = [[rowDict allValues][0] description];
    }
    return cell;
}

@end

