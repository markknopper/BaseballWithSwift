//
//  SeriesTVController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 2/20/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;


@interface SeriesTVController : UITableViewController

@property (nonatomic, strong) NSNumber *year;
// seriesThisYear is an array of SeriesPost core data objects.
@property (nonatomic, strong) NSArray *seriesThisYear;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
// Array of row arrays for display.
@property (nonatomic, strong) NSMutableArray  *sectionsForDisplay;
// Titles are displayed for section, like AL Championship Series
// Make sectionTitles an array of dictionaries with keys name and round. name is like World Series and round is like WS.
@property (nonatomic, strong) NSMutableArray *sectionTitles;
// Name of round to scroll to if coming from a player/year row.
@property (nonatomic, strong) NSString *scrollToRound;

@end
