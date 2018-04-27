//
//  NSArray+BV.m
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "NSArray+BV.h"
#import "StatsFormatter.h"
#import "StatHead.h"
#import "Master+Query.h"

@implementation NSArray (BV)

-(NSNumber *)sumAllExceptMissingForStat:(NSString *)statName {
    NSPredicate *allExceptMissing = [NSPredicate predicateWithFormat:@"%K != -1", statName];
    NSArray *recordsWithMissingStatRemoved = [self filteredArrayUsingPredicate:allExceptMissing];
    NSNumber *sumAll = @-1;
    if ([recordsWithMissingStatRemoved count] > 0) {
        sumAll = [recordsWithMissingStatRemoved valueForKeyPath:[NSString stringWithFormat:@"@sum.%@",statName]];
    }
    return sumAll;
}

// Weird place to put per-position fielding stat display method.
// Assume we are an array of fielding records all at the same position.
-(NSString *)displayStringForStat:(NSString *)statName
{
    // Initial assumption is that its just a regular number.
    NSString *displayStringToReturn = @"-1";
    if ([statName isEqualToString:@"fPct"]) {
        NSNumber *totalPutOuts = [self sumAllExceptMissingForStat:@"pO"];
        NSNumber *totalAssists = [self sumAllExceptMissingForStat:@"a"];
        NSNumber *totalErrors = [self sumAllExceptMissingForStat:@"e"];
        NSInteger fielding_percentage_times_1000 = [StatHead fieldingPercentageWithPutouts:totalPutOuts assists:totalAssists errors:totalErrors];
        if (fielding_percentage_times_1000 >= 0)
            // Might be -1.
            displayStringToReturn = [StatsFormatter averageInThousandForm:fielding_percentage_times_1000];
    } else if ([statName isEqualToString:@"innOuts"]) {
        displayStringToReturn = [StatsFormatter inningsInDecimalFormFromInningOuts:[[self sumAllExceptMissingForStat:statName] integerValue]];
    } else if ([statName isEqualToString:@"seasons"]) {
        // Need to look through all the fielding records for this position (ie self) and count the unique years (since there could have been multiple stints in a year).
        displayStringToReturn = [NSString stringWithFormat:@"%lu",(unsigned long)[[self valueForKeyPath:@"@distinctUnionOfObjects.yearID"] count]];
    } else if ([statName isEqualToString:@"pos"]) {
        displayStringToReturn = [self.firstObject valueForKey:@"pos"];
    } else if ([statName isEqualToString:@"pB"]) {
        if (![[self.firstObject valueForKey:@"pos"] isEqualToString:@"C"])
            displayStringToReturn = @"-1";
    } else
        displayStringToReturn = [[self sumAllExceptMissingForStat:statName] description];
    return displayStringToReturn;
}

-(NSArray *)sortedArrayUsingKey:(NSString *)ascendingSortKey {
	NSSortDescriptor *ascendingByKey = [[NSSortDescriptor alloc] initWithKey:ascendingSortKey ascending:YES];
	NSArray *descriptors = @[ascendingByKey];
	
	return [self sortedArrayUsingDescriptors:descriptors];
}

-(NSArray *)sortedArrayUsingKey:(NSString *)sortKey ascending:(BOOL)ascending {
	NSSortDescriptor *sortByKey = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
	NSArray *descriptors = @[sortByKey];
	return [self sortedArrayUsingDescriptors:descriptors];
}

//
//   Apply the selector to each element of the array and return an array of the
//   values returned by the selector
//
-(NSArray *)arrayUsingSelector:(SEL)selector {
	NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[self count]];
	for (id eachElement in self) {
		if ([eachElement respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[resultArray addObject:[eachElement performSelector:selector]];
#pragma clang diagnostic pop
		}
	}
	return resultArray;
}

// -------------------------------------------------------------------------------------------
// * binarySearchForObject:compareKey:
//  Customized binary search. Finds object in sorted array, or if it's not there returns a nice insertion index point.
// object: Object to search for
// compareKey: key to compare (within object)
// ascending: whether array is sorted ascending
//  Thanks to John A. Vink for original version of binary search code.
// -------------------------------------------------------------------------------------------
- (NSInteger) binarySearchForObject:(id)object compareKey:(NSString *)compareKey ascending:(BOOL)its_ascending
{
	NSInteger numElements = [self count];
	// if there are no items in the array, we can just return NSNotFound
	if (numElements == 0)
        return 0; // Never return NSNotFound. 0 is good because it sort of means we can insert the first item.
    id valueToCompareAgainst = [object valueForKey:compareKey];
	// searchRange is the range of items that we need to search.  We initialize it
	// to cover all the items in the array.
	NSRange searchRange = NSMakeRange(0, numElements);
	// when the length of our range hits zero, we've found the index of this item.
	while(searchRange.length > 0)
	{
		// checkIndex in the index of the item in the array that we're going to compare with
		// to find out if the item we're looking for is located before or after.  checkIndex is set
		// to be the middle of the search range.
		NSInteger checkIndex = searchRange.location + (searchRange.length / 2);
		// checkObject is the object at checkIndex
		id checkObject = self[checkIndex];
		// we call compare: on the checkObject, passing it the item we're looking for.
        NSComparisonResult order;
        if (its_ascending)
            order = [[checkObject valueForKey:compareKey] compare:valueToCompareAgainst];
        else
            order = [valueToCompareAgainst compare:[checkObject valueForKey:compareKey]];
		switch (order)
		{
			case NSOrderedAscending:
			{
				// the item we're looking for appears after the item we checked against.
				// Now, the search range starts with the item after the item we just checked, and ends
				// at the same place as the previous search range.
                
				// end point remains the same, start point moves to next element.
				unsigned int endPoint = (unsigned int)(searchRange.location + searchRange.length);
				searchRange.location = checkIndex + 1;
				searchRange.length = endPoint - searchRange.location;
				break;
			}
			case NSOrderedDescending:
			{
				// the item we're looking for appears before the item we checked against.
				// Now, the search range starts at the same place as the previous search range,
				// and ends with the item just before the item we just checked.
				// start point remains the same, end point moves to previous element
				searchRange.length = (checkIndex - 1) - searchRange.location + 1;
				break;
			}
			case NSOrderedSame:
			{
				// Key matches. Check if it is us.
                // if ([self objectAtIndex:checkIndex] == object)
                //return checkIndex;
                // Not us. Do some custom linear searching to find us.
                // First search backward to see if we are before in list.
                NSInteger backward_search = checkIndex;
                while (true)  {
                    if (self[backward_search] == object)
                        return backward_search;
                    if (backward_search==0) break;
                    if ([[self[backward_search-1] valueForKey:compareKey] compare:valueToCompareAgainst]!=NSOrderedSame) {
                        // If previous one isn't the same key, this is the first item matching.
                        break;
                    }
                    backward_search--; // Keep looking for first item with our value.
                }
                // backward_search is first item in array with our value. Now do forward search.
                NSInteger forward_search = checkIndex;
                while (true) {
                    if (self[forward_search] == object)
                        return forward_search;
                    if (forward_search == [self count]-1) break; // didn't find it. Return first occurrence.
                    if ([[self[forward_search+1] valueForKey:compareKey] compare:valueToCompareAgainst]!=NSOrderedSame)
                        break; // Got to the end and didn't find us. Return first one matching.
                    forward_search++;
                }
                return backward_search; // Return ;
				break;
			}
			default:
			{
				// we should never get here.  Freak out if we do.  It means you wrote your compare: method wrong.
				assert(0);
				break;
			}
		}
	}
	// If we reach here, we have not found the item.  Return NSNotFound. Should not get here.
    // Well maybe if we are under the threshold and our value is past the end.
    return [self count]-1;
}

@end
