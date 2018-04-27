//
//  UIViewController+IndexLetters.m
//  BaseballQuery
//
//  Created by Mark Knopper on 10/8/10.
//  Copyright (c) 2010-2015 Bulbous Ventures LLC. All rights reserved.
//
@import CoreData;

#import "UIViewController+IndexLetters.h"

@implementation UIViewController (IndexLetters)

-(void)computeTableIndicesFromYearArray:(NSArray *)ourArray withKeyPath:(NSString *)yearKey ascending:(BOOL)sort_order_ascending
{
	// Put little tiny indexes for decades on the right side so you don't have to scroll
	// too much.
	// indexDecades is an array of tiny indexes, eg. 1870, 1880... or if reversing, 2000, 1990...
	NSMutableArray *indexDecades = [[NSMutableArray alloc] init];
	// decadeDict is dictionary with key: decade string, value: array of year strings within decade.
	// eg. {key="1990" value=array("1990","1991"..."1999") or reversed if !ascending.
	NSMutableDictionary *decadeDict = [[NSMutableDictionary alloc] init];
	if ([ourArray count] > 10) {
		NSInteger this_decade_number, current_decade_number = 0;
		if (!sort_order_ascending) current_decade_number = 99999;
		for (NSDictionary *aTeamDict in ourArray) {
			NSString *oneYearString = [aTeamDict[@"yearID"] description];
			this_decade_number = [aTeamDict[@"yearID"] integerValue]/10;
			NSString *thisDecadeNumberKey = [NSString stringWithFormat:@"%ld",(long)this_decade_number*10];
			// Handle ascending or decending year order.
			if (((this_decade_number > current_decade_number) && sort_order_ascending) || ((this_decade_number < current_decade_number) && !sort_order_ascending)) {
				// Create new decadeDict entry for this decade, and add this year to it.
				[indexDecades addObject:thisDecadeNumberKey];
				[decadeDict setValue:[NSMutableArray arrayWithObject:oneYearString] forKey:thisDecadeNumberKey]; 			current_decade_number = this_decade_number;
			} else {
				// add this year to array for this (existing) decade.
				[decadeDict[thisDecadeNumberKey] addObject:oneYearString];
			}
		}
	}
	[self setValue:indexDecades forKey:@"indexDecades"];
	[self setValue:decadeDict forKey:@"decadeDict"];
}

-(void)updateDisplayList:(NSMutableDictionary *)newDisplayList indexLetters:(NSMutableArray *)newIndexLetters
{
	[self setValue:newDisplayList forKey:@"displayList"];
    [self setValue:newIndexLetters forKey:@"indexLetters"];
}

//
// computeTableIndicesFromArray - produce dictionary with displayList and indexLetters keys
//  from fetched players array. Assumes sorted by player name.
//
-(NSDictionary *)computeTableIndicesFromArray:(NSArray *)ourArray withKeyPath:(NSString *)firstLetterKey
{
	// Build first letter index for table.
	NSInteger i;
	NSMutableDictionary *displayList = [[NSMutableDictionary alloc] init];
	NSMutableArray *indexLetters = [[NSMutableArray alloc] init];
	NSManagedObjectContext *ourOC = [self valueForKey:@"managedObjectContext"];
    
    @autoreleasepool {
        for (i=0; i<[ourArray count];  i++) {
            id thisObj = ourArray[i]; // is NSManagedObject or NSMangedObjectID
            NSManagedObjectID *objToAdd = thisObj;
            id thisMasterLikeObject = thisObj;
            if ([thisObj isKindOfClass:[NSManagedObjectID class]]) {
                objToAdd = thisObj; // Add the ID to the displayList structures.
                thisMasterLikeObject = [ourOC objectWithID:objToAdd]; // This is a trip to the database!
            } else if ([thisObj isKindOfClass:[NSManagedObject class]]) { // it's an NSManagedObject (Master probably).
                objToAdd = [thisObj objectID];
            }
			// thisObj will sit there autoreleased so releasing the pool periodically might keep memory footprint down.
            NSString *firstLetter = [[[thisMasterLikeObject valueForKeyPath:firstLetterKey] substringToIndex:1] capitalizedString];
            if (!displayList[firstLetter]) {
                [indexLetters addObject:firstLetter];
                displayList[firstLetter] = [NSMutableArray arrayWithObject:objToAdd];
            } else {
                [displayList[firstLetter] addObject:objToAdd];
            }
        }
    }
	NSDictionary *packageToReturn = @{@"displayList": displayList,@"indexLetters": indexLetters};
	return packageToReturn;
}

-(void)computeTableIndicesFromArrayUpdatingDisplayList:(NSArray *)ourArray withKeyPath:(NSString *)firstLetterKey
{
	NSDictionary *displayListAndIndexLetters = [self computeTableIndicesFromArray:ourArray withKeyPath:firstLetterKey];
	[self updateDisplayList:displayListAndIndexLetters[@"displayList"] indexLetters:displayListAndIndexLetters[@"indexLetters"]];
}

-(id)indexLettersObjectForIndexPath:(NSIndexPath *)indexPath {
	id obj = nil;
	//
	//  If the client didn't bother to build an index yet, do not even try to
	//  find anything.
	//
	if ([self valueForKey:@"displayList"] != nil) {
		NSString *letterForSection = [self valueForKey:@"indexLetters"][indexPath.section];
		NSArray *objectsForLetter = [self valueForKey:@"displayList"][letterForSection];
        NSInteger index_path_row = indexPath.row;
        if ([objectsForLetter count]>index_path_row)
            obj = objectsForLetter[index_path_row];
	}
	return obj;
}

@end
