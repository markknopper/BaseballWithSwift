//
//  AllStarTVC.h
//  BaseballQuery
//
//  Created by Mark Knopper on 5/27/11.
//  Copyright 2011-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "GameLog.h"

@interface AllStarTVC : UITableViewController

@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *sectionRowStrings;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) GameLog *game1;
@property (nonatomic, strong) GameLog *game2;
@property NSInteger selected_game_number;

+(BOOL)allstarGamePlayedInYear:(NSNumber *)aYear;

@end
