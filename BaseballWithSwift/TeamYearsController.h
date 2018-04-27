//
//  TeamYearsController.h
//
//  Created by Mark Knopper on 8/11/09.
//  Copyright 2009-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@interface TeamYearsController : UITableViewController {
	NSInteger number_of_franchises;
}

@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSString *franchise;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *cachedRosterControllers;
@property (nonatomic, strong) NSMutableArray *tableSectionData;
@property (nonatomic, strong) NSMutableArray *teamList;

-(NSInteger)yearFrom:(NSInteger)current_year plusOffset:(NSInteger)zero_or_one;

@end
